#import "DomainModel.h"
#import "DomainModelSync.h"

@implementation DomainModel

@synthesize document;

- (id) copyWithZone:(NSZone*) zone{
    return [self retain];
}

+ (Class) syncClass{
    return [DomainModelSync class];    
}

- (NSString*) id{
    if(self.document){
        if(self.document.documentID){
            return self.document.documentID;
        }else{
            return @"dummy";
        }
    }else{
        return @"_id";
    }
}

- (void) setAttributesFromDocument:(CouchDocument*) doc {
    NSDictionary *attrs = [doc userProperties];
    [self set:attrs withOptions:$dict(SILENT_KEY, $object(YES))];
}

+ (DomainModel*) domainModelFromDocument:(CouchDocument*) doc{
    DomainModel *model = nil;
    if(doc.modelObject){
        model = doc.modelObject;
        [model setAttributesFromDocument:doc];
        model.document = doc;
        [model change];
    }else{
        model = [[[self alloc] initWithAttributes:nil andOptions:nil] autorelease];
        [model setAttributesFromDocument:doc];    
        model.document = doc;
        doc.modelObject = model;
    }
    return model;
}

- (BOOL) isNew{
    return self.document == nil; 
}

- (void)dealloc {
    self.document   =   nil;
    [super dealloc];
}

@end
