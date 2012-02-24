typedef void(^CouchSyncSuccess)(CouchEmbeddedServer *server);
typedef void(^CouchSyncFailure)(NSError *error);

@interface DomainCollectionSync : ISBasicSync


@property (nonatomic, retain) CouchDatabase                 *database;
@property (nonatomic, retain) CouchReplication              *replication;
@property (nonatomic, retain) CouchQuery                    *query;
@property (nonatomic, retain) CouchPersistentReplication    *pull;
@property (nonatomic, retain) CouchPersistentReplication    *push;
@property (nonatomic, retain) SyncHandler                   successHandler;
@property (nonatomic, retain) SyncHandler                   failureHandler;
@property (nonatomic, retain) NSURL                         *remoteDBURL;

- (CouchQuery*) setupQuery;

@end
