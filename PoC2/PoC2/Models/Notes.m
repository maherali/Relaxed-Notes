#import "Notes.h"
#import "Note.h"
#import "NotesSync.h"

@implementation Notes

-(Class) modelClass{
    return [Note class];
}

- (NSString*) path{
    return @"/notes";
}

+ (Class) syncClass{
    return [NotesSync class];    
}

@end
