#import "NotesSync.h"

@implementation NotesSync

+ (id<ISSyncProtocol>) syncWithOptions:(NSDictionary*) _options{
    NSMutableDictionary *myOptions = [[_options mutableDeepCopy] autorelease];
    [myOptions setValue:@"notes" forKey:@"db"];
    return [super syncWithOptions:myOptions];
}

@end
