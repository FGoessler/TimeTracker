//
//  TTCoreDataManager.m
//  timetracker
//
//  Created by Florian Goessler on 06.07.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTCoreDataManager.h"
#import "TTAppDelegate.h"

NSString * kiCloudPersistentStoreFilename = @"iCloudStore.sqlite";
NSString * kFallbackPersistentStoreFilename = @"fallbackStore.sqlite"; //used when iCloud is not available

static NSOperationQueue *_presentedItemOperationQueue;

@implementation TTCoreDataManager {
    NSLock *_loadingLock;
    NSURL *_presentedItemURL;
}

#pragma mark - Singleton

+(TTCoreDataManager *)defaultManager {
	static TTCoreDataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

+ (void)initialize {
    if (self == [TTCoreDataManager class]) {
        _presentedItemOperationQueue = [[NSOperationQueue alloc] init];
    }
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _loadingLock = [[NSLock alloc] init];
    _ubiquityURL = nil;
    _currentUbiquityToken = nil;
    _presentedItemURL = nil;
    
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:_psc];
    
    _currentUbiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    //subscribe to the change notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iCloudAccountChanged:)
                                                 name:NSUbiquityIdentityDidChangeNotification
                                               object:nil];
	
	 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:_psc];
		
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Save Methods

- (BOOL)saveContext
{
    return [self saveContextWithErrorHandler:nil];
}
- (BOOL)saveContextWithErrorHandler:(TTErrorHandler)handler {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			if(handler != nil) {
				if(handler(error)) {
					return false;	//return false to indicate that an error happened
				}
			}
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();	 //kill the app if the error could not been handled
        }
    }
	return true;	//return true to indicate that no error happened
}

#pragma mark - React on Events

- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
	
	NSLog(@"Merging in changes from iCloud...");
	
    NSManagedObjectContext* moc = [self managedObjectContext];
	
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:notification];
		
        NSNotification* refreshNotification = [NSNotification notificationWithName:TT_MODEL_CHANGED_NOTIFICATION
                                                                            object:self
                                                                          userInfo:[notification userInfo]];
        [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    }];
}

- (void)applicationResumed {
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if (self.currentUbiquityToken != token) {
        if (NO == [self.currentUbiquityToken isEqual:token]) {
            [self iCloudAccountChanged:nil];
        }
    }
}

- (void)iCloudAccountChanged:(NSNotification *)notification {
    //tell the UI to clean up while we re-add the store
    [self dropStores];
    
    // update the current ubiquity token
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    _currentUbiquityToken = token;
    
    //reload persistent store
    [self loadPersistentStore];
}

#pragma mark - Managing the Persistent Stores

- (BOOL)iCloudAvailable {
    return (self.currentUbiquityToken != nil);
}

- (void)loadPersistentStore {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        BOOL locked = NO;
        @try {
            [_loadingLock lock];
            locked = YES;
            [self asyncLoadPersistentStore];
        } @finally {
            if (locked) {
                [_loadingLock unlock];
                locked = NO;
            }
			
			[self.managedObjectContext performBlock:^{
				NSNotification* refreshNotification = [NSNotification notificationWithName:TT_MODEL_CHANGED_NOTIFICATION object:self userInfo:nil];				
				[[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
			}];
        }
    });
	
}

- (void)asyncLoadPersistentStore {
    NSError *error = nil;
    
    //if iCloud is available, add the persistent store
    //if iCloud is not available, or the add call fails, fallback to local storage
    BOOL useFallbackStore = NO;
    if ([self iCloudAvailable]) {
        if ([self loadiCloudStore:&error]) {
            NSLog(@"Added iCloud Store");
            
            //check to see if we need to migrate data from the fallback store
            NSFileManager *fm = [[NSFileManager alloc] init];
            if ([fm fileExistsAtPath:[[self fallbackStoreURL] path]]) {
                //TODO: migrate data from the fallback store to the iCloud store
            }
        } else {
            NSLog(@"Unable to add iCloud store: %@", error);
            useFallbackStore = YES;
        }
    } else {
        useFallbackStore = YES;
    }
    
    if (useFallbackStore) {
        if ([self loadFallbackStore:&error]) {
            NSLog(@"Added fallback store: %@", self.fallbackStore);
        } else {
            NSLog(@"Unable to add fallback store: %@", error);
            abort();
        }
    }
}

- (BOOL)loadiCloudStore:(NSError * __autoreleasing *)error {
    BOOL success = YES;
    NSError *localError = nil;
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    _ubiquityURL = [fm URLForUbiquityContainerIdentifier:nil];
    
    NSURL *iCloudStoreURL = [self iCloudStoreURL];
    NSURL *iCloudDataURL = [self.ubiquityURL URLByAppendingPathComponent:@"iCloudData"];
	
	NSLog(@"iCloudStoreURL: %@", iCloudStoreURL);
	NSLog(@"iCloudDataURL: %@", iCloudDataURL);
	
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption: @YES,
							   NSInferMappingModelAutomaticallyOption: @YES,
							   NSPersistentStoreUbiquitousContentNameKey : @"iCloudStore",
							   NSPersistentStoreUbiquitousContentURLKey : iCloudDataURL };
    _iCloudStore = [self.psc addPersistentStoreWithType:NSSQLiteStoreType
                                          configuration:nil
                                                    URL:iCloudStoreURL
                                                options:options
                                                  error:&localError];
    success = (self.iCloudStore != nil);
    if (success) {
        //set up the file presenter
        _presentedItemURL = iCloudDataURL;
        [NSFileCoordinator addFilePresenter:self];
    } else {
        if (localError  && (error != NULL)) {
            *error = localError;
        }
    }
    
    return success;
}

- (BOOL)loadFallbackStore:(NSError * __autoreleasing *)error {
    BOOL success = YES;
    NSError *localError = nil;
    
    if (_fallbackStore) {
        return YES;
    }
    NSURL *storeURL = [self fallbackStoreURL];
    _fallbackStore = [self.psc addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:@"CloudConfig"
                                                  URL:storeURL
                                              options:nil
                                                error:&localError];
    success = (_fallbackStore != nil);
    if (NO == success) {
        if (localError  && (error != NULL)) {
            *error = localError;
        }
    }
    
    return success;
}

- (void)dropStores {
    NSError *error = nil;
    
    if (self.fallbackStore) {
        if ([self.psc removePersistentStore:self.fallbackStore error:&error]) {
            NSLog(@"Removed fallback store");
            _fallbackStore = nil;
        } else {
            NSLog(@"Error removing fallback store: %@", error);
        }
    }
    
    if (self.iCloudStore) {
        _presentedItemURL = nil;
        [NSFileCoordinator removeFilePresenter:self];
        if ([self.psc removePersistentStore:self.iCloudStore error:&error]) {
            NSLog(@"Removed iCloud Store");
            _iCloudStore = nil;
        } else {
            NSLog(@"Error removing iCloud Store: %@", error);
        }
    }
}

#pragma mark - Directory/URL Getters

- (NSString *)folderForUbiquityToken:(id)token {
    NSURL *tokenURL = [[self applicationSandboxStoresDirectory] URLByAppendingPathComponent:@"TokenFoldersData"];
    NSData *tokenData = [NSData dataWithContentsOfURL:tokenURL];
    NSMutableDictionary *foldersByToken = nil;
    if (tokenData) {
        foldersByToken = [NSKeyedUnarchiver unarchiveObjectWithData:tokenData];
    } else {
        foldersByToken = [NSMutableDictionary dictionary];
    }
    NSString *storeDirectoryUUID = [foldersByToken objectForKey:token];
    if (storeDirectoryUUID == nil) {
        NSUUID *uuid = [[NSUUID alloc] init];
        storeDirectoryUUID = [uuid UUIDString];
        [foldersByToken setObject:storeDirectoryUUID forKey:token];
        tokenData = [NSKeyedArchiver archivedDataWithRootObject:foldersByToken];
        [tokenData writeToFile:[tokenURL path] atomically:YES];
    }
    return storeDirectoryUUID;
}

- (NSURL *)iCloudStoreURL {
    NSURL *iCloudStoreURL = [self applicationSandboxStoresDirectory];
    NSAssert1(self.currentUbiquityToken, @"No ubiquity token? Why you no use fallback store? %@", self);
    
    NSString *storeDirectoryUUID = [self folderForUbiquityToken:self.currentUbiquityToken];
    
    iCloudStoreURL = [iCloudStoreURL URLByAppendingPathComponent:storeDirectoryUUID];
    NSFileManager *fm = [[NSFileManager alloc] init];
    if (NO == [fm fileExistsAtPath:[iCloudStoreURL path]]) {
        NSError *error = nil;
        BOOL createSuccess = [fm createDirectoryAtURL:iCloudStoreURL withIntermediateDirectories:YES attributes:nil error:&error];
        if (NO == createSuccess) {
            NSLog(@"Unable to create iCloud store directory: %@", error);
        }
    }
    
    iCloudStoreURL = [iCloudStoreURL URLByAppendingPathComponent:kiCloudPersistentStoreFilename];
    return iCloudStoreURL;
}

- (NSURL *)fallbackStoreURL {
    NSURL *storeURL = [[self applicationSandboxStoresDirectory] URLByAppendingPathComponent:kFallbackPersistentStoreFilename];
    return storeURL;
}

- (NSURL *)applicationSandboxStoresDirectory {
    NSURL *storesDirectory = [NSURL fileURLWithPath:[self applicationDocumentsDirectory]];
    storesDirectory = [storesDirectory URLByAppendingPathComponent:@"SharedCoreDataStores"];
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    if (NO == [fm fileExistsAtPath:[storesDirectory path]]) {
        //create it
        NSError *error = nil;
        BOOL createSuccess = [fm createDirectoryAtURL:storesDirectory
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:&error];
        if (createSuccess == NO) {
            NSLog(@"Unable to create application sandbox stores directory: %@\n\tError: %@", storesDirectory, error);
        }
    }
    return storesDirectory;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark NSFilePresenter

- (NSURL *)presentedItemURL {
    return _presentedItemURL;
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return _presentedItemOperationQueue;
}

- (void)accommodatePresentedItemDeletionWithCompletionHandler:(void (^)(NSError *))completionHandler {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self iCloudAccountChanged:nil];
    });
    completionHandler(NULL);
}

#pragma mark -

@end

