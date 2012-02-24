#import "DomainModelSync.h"
#import "DomainModel.h"

@implementation DomainModelSync

+ (id<ISSyncProtocol>) syncWithOptions:(NSDictionary*) _options{
    return [super syncWithOptions:_options];
}

- (void) initiateSync{
    NSString    *method     = [self.options objectForKey:METHOD_KEY];
    if ([method isEqualToString:METHOD_CREATE] || [method isEqualToString:METHOD_UPDATE]){
        DomainModel     *model = [self.options objectForKey:@"model"];    
        RESTOperation* op = [model.document putProperties:[self.options objectForKey:DATA_KEY]];
        [op onCompletion: ^{
            [super finish]; 
        }];
        [op start];
    }
    else if([method isEqualToString:METHOD_DELETE]){
        DomainModel     *model = [self.options objectForKey:@"model"];
        [model.document.database deleteDocuments:$array(model.document)];
        [super finish];
    }
}

@end
