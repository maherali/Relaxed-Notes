#import "AppFacadeService.h"
#import "Notes.h"
#import "DomainCollectionSync.h"

static AppFacadeService     *singleton      = nil;
static CouchEmbeddedServer  *theServer      = NULL;

@implementation AppFacadeService

@synthesize navigationController, observers;

+ (void) serverWithSuccessBlock:(CouchSyncSuccess) success failure:(CouchSyncFailure) failure{
    if(!theServer){
        theServer  = [[CouchEmbeddedServer alloc] init];
        [theServer start: ^{  
            if (theServer.error) {
                failure(theServer.error);
                [theServer release];
                theServer = nil;
                return;
            }
            success(theServer);
        }];
    }else{
        success(theServer);
    }
}

- (id) intWithOptions:(NSDictionary*) options{
    self = [super init];
    self.observers = $marray();
    NSString *baseURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"REMOTE_COUCH__URL"];
    [ISCollection   setBaseUrl:baseURL];
    [ISModel        setBaseUrl:baseURL];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:[[[UIViewController alloc] init] autorelease]] autorelease];
    UIWindow *window = [options objectForKey:@"window"];
	[window addSubview:navigationController.view];
    
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notes.png"]] autorelease];
    [window addSubview:imageView];
    [window makeKeyAndVisible];
    __block AppFacadeService *this = self;
    
    [[self class] serverWithSuccessBlock:^(CouchEmbeddedServer *server) {
        [NSTimer scheduledTimerWithTimeInterval:1 target:this selector:@selector(removeFlashScreen:) userInfo:$dict(@"imageView", imageView) repeats:NO];
        $navigate(@"/notes", $dict(@"title", @"Relaxed Notes"));
    } failure:^(NSError *error){  
    }];
    return self;
}

- (void) removeFlashScreen:(NSTimer*) t{
    UIImageView *imageView = (UIImageView*)[t.userInfo valueForKey:@"imageView"];
    [imageView removeFromSuperview];
}

+ (void) startWithOptions:(NSDictionary*) options{
    singleton = singleton ? singleton : [[self alloc] intWithOptions:options];
}

+ (void) load{
    __block Class this = self;
    $register(@"app");
}

+ (CouchEmbeddedServer*) server{
    return theServer;    
}

- (void) dealloc{
    __block AppFacadeService *this = self;
    $unwatch();
    self.observers              =   nil;
    self.navigationController   =   nil;
    [super dealloc];
}

@end
