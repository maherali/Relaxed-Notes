#import "Note.h"
#import "DomainModelSync.h"
#import "DomainCollectionSync.h"
#import "AppFacadeService.h"

@implementation Note

- (NSString*) description{
    return [[self get:@"title"] isEqual:[NSNull null]] ? @"" : [self get:@"title"];
}

- (NSData*) dataToSave{
    NSMutableDictionary *dict = [self performSelector:@selector(attributes)];
    if(self.document.currentRevisionID){
        [dict setObject:self.document.currentRevisionID forKey:@"_rev"];
    }
    return (NSData*)dict;
}

- (NSArray*) validate:(NSDictionary*) attrs{
    NSString    *title = [attrs objectForKey:@"title"];
    NSMutableArray  *arr = $marray();
    if(title && [title length] < 5){
        [arr addObject:@"Title cannot be less than 5 characters"];
    }
    return arr;
}

- (NSMutableDictionary*) addSelfToOptions:(NSDictionary*) _options{
    NSMutableDictionary *theOptions = _options ? [[_options mutableDeepCopy] autorelease] : $mdict();
    [theOptions setValue:self forKey:@"model"];
    return theOptions;
}

- (void) destroy:(NSDictionary*) _options{
    [super destroy:[self addSelfToOptions:_options]];
}

- (void) save:(NSDictionary*) _options{
    [super save:[self addSelfToOptions:_options]];
}

- (void) initializeWithAttributes:(NSDictionary*) attrs andOptions:(NSDictionary*) options{
    CouchEmbeddedServer *server = [AppFacadeService server];
    if(server){
        CouchDatabase *theDatabase = [server databaseNamed:@"notes"];  
        self.document = [theDatabase untitledDocument];
        self.document.modelObject = self;
    }
}

@end
