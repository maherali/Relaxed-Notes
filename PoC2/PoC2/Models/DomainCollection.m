#import "DomainCollection.h"
#import "DomainCollectionSync.h"
#import "DomainModel.h"

@implementation DomainCollection

+ (Class) modelClass{
    return [[[self new] autorelease] modelClass];
}

+ (Class) syncClass{
    return [DomainCollectionSync class];    
}

- (NSMutableArray*) parse:(NSData*) data{
    if([data isKindOfClass:[CouchQueryEnumerator class]]){
        CouchQueryEnumerator *queryEnum = (CouchQueryEnumerator*) data;
        NSMutableArray *arr = [NSMutableArray array];
        for(CouchQueryRow *row in queryEnum){
            [arr addObject:[[self modelClass] domainModelFromDocument:row.document]];
        }
        return arr; 
    }else{
        return [super parse:data];
    }
}

@end
