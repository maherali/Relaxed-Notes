#import "DomainCollectionSync.h"
#import "AppFacadeService.h"

@interface ISBasicSync(INTERNAL)
- (void) _callBack:(id) block;
@end

@interface DomainCollectionSync()

- (void) hookExternalDatabase;

@end

@implementation DomainCollectionSync

@synthesize database, replication, query, pull, push;
@synthesize successHandler, failureHandler, remoteDBURL;

- (id<ISSyncProtocol>)  initWithOptions:(NSDictionary*) options{
    self = [super initWithOptions:options];
    return self;
}

- (NSDictionary*) callbackArgs{
    if(!self.database){
        return [super callbackArgs];
    }else{
        NSMutableDictionary *dict   = [[[super callbackArgs] mutableCopy] autorelease];
        NSMutableDictionary *md     = [dict objectForKey:SYNC_META_DATA_ARG_KEY];
        [md setObject:$object(YES) forKey:SYNC_CONTINUES_KEY];
        return dict;
    }
}

- (void) forgetSync {
    [self.pull removeObserver: self forKeyPath: @"completed"];
    self.pull = nil;
    [self.push removeObserver: self forKeyPath: @"completed"];
    self.push = nil;
}

- (void) hookExternalDatabase{
    if (!self.database){
        return;
    }
    [self forgetSync];
    NSArray* repls = [self.database replicateWithURL:self.remoteDBURL exclusively:YES];
    self.pull = [repls objectAtIndex: 0];
    self.push = [repls objectAtIndex: 1];
    [self.pull addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
    [self.push addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
}

- (void) loadEntriesFrom: (CouchQueryEnumerator*)rows {
    self.data = (NSMutableData*)rows;
    [self _callBack:self.successHandler];
}

- (void)observeValueForKeyPath: (NSString*)keyPath ofObject: (id)object change: (NSDictionary*)change context: (void*)context {
    if (object == self.query) {
        [self loadEntriesFrom: self.query.rows];
    }else if (object == self.pull || object == self.push) {
        unsigned completed = self.pull.completed + self.push.completed;
        unsigned total = self.pull.total + self.push.total;
        NSLog(@"SYNC progress: %u / %u", completed, total);
        if (total > 0 && completed < total) {
            database.server.activityPollInterval = 0.5;
        } else {
            database.server.activityPollInterval = 2.0;
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [query removeObserver: self forKeyPath: @"rows"];
    [self forgetSync];
    self.database       =   nil;
    self.replication    =   nil;
    self.query          =   nil;
    self.successHandler =   nil;
    self.failureHandler =   nil;
    self.remoteDBURL    =   nil;    
    [super dealloc];
}

- (CouchQuery*) setupQuery{
    CouchQuery  *theQuery = [[self.database getAllDocuments] asLiveQuery];
    theQuery.descending = YES;
    theQuery.prefetch = YES;
    [theQuery start];
    return theQuery;
}

+ (id<ISSyncProtocol>) syncWithOptions:(NSDictionary*) _options{
    NSString    *method = [_options objectForKey:METHOD_KEY];
    if ([method isEqualToString:METHOD_READ]){
        DomainCollectionSync *couchSync = [[[[self class] alloc] initWithOptions:_options] autorelease];
        couchSync.successHandler = [_options objectForKey:SYNC_SUCCESS_HANDLER_KEY];
        couchSync.failureHandler = [_options objectForKey:SYNC_FAILURE_HANDLER_KEY];
        couchSync.remoteDBURL    = [NSURL URLWithString:[_options objectForKey:URL_KEY]];
        CouchEmbeddedServer *server = [AppFacadeService server];
        if(server){
            CouchDatabase *theDatabase = [server databaseNamed:[_options objectForKey:@"db"]];
            NSError* error = nil;
            if (![theDatabase ensureCreated:&error]) {
                couchSync.database = nil;
                [couchSync _callBack:couchSync.failureHandler];
                return nil;
            }
            couchSync.database = theDatabase;
            couchSync.database.tracksChanges = YES;
            couchSync.query = [couchSync setupQuery];
            [couchSync.query addObserver:couchSync forKeyPath:@"rows" options:0 context:NULL];
            [couchSync hookExternalDatabase];   
        }else{
            couchSync.database = nil;
            [couchSync _callBack:couchSync.failureHandler];
        }
        return couchSync;
    }		
    return nil;
}

@end
