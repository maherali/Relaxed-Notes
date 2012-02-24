@interface DomainModel : ISModel

@property (nonatomic, retain) CouchDocument     *document;

- (void) setAttributesFromDocument:(CouchDocument*) doc;
+ (DomainModel*) domainModelFromDocument:(CouchDocument*) doc;

@end
