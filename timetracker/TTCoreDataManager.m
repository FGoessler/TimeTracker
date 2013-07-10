//
//  TTCoreDataManager.m
//  timetracker
//
//  Created by Florian Goessler on 06.07.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTCoreDataManager.h"

#define TT_ICLOUD_TOKEN_KEY @"TT_ICLOUD_TOKEN_KEY"

@interface TTCoreDataManager ()
@property (nonatomic, strong) id currentUbiquityToken;
@end

@implementation TTCoreDataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Singleton

+(TTCoreDataManager *)defaultManager {
	static TTCoreDataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
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

#pragma mark - Core Data Stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		
        [moc performBlockAndWait:^{
            [moc setPersistentStoreCoordinator: coordinator];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
        }];
        _managedObjectContext = moc;
    }
	
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"timetracker" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{	
	if((_persistentStoreCoordinator != nil)) {
        return _persistentStoreCoordinator;
    }
	
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    NSPersistentStoreCoordinator *psc = _persistentStoreCoordinator;
	
    // Set up iCloud in another thread:
	
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
								
        NSURL *iCloudBaseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
		self.currentUbiquityToken = [[NSUserDefaults standardUserDefaults] valueForKey:TT_ICLOUD_TOKEN_KEY];		
		
		BOOL useFallbackStore = NO;
        if (iCloudBaseURL) {
			
			NSLog(@"iCloud is working");
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:TT_ICLOUD_INITATION_NOTIFICATION object:self userInfo:nil];
			});
			
            NSLog(@"iCloud = %@", iCloudBaseURL);
						
            NSLog(@"tokens equal?:%d \n saved token: %@ \n new token:%@", [self.currentUbiquityToken isEqual: [[NSFileManager defaultManager] ubiquityIdentityToken]],self.currentUbiquityToken, [[NSFileManager defaultManager] ubiquityIdentityToken]);
			
			self.currentUbiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
			[[NSUserDefaults standardUserDefaults] setValue:[[NSFileManager defaultManager] ubiquityIdentityToken] forKey:TT_ICLOUD_TOKEN_KEY];
			
            NSDictionary *options = @{
									NSMigratePersistentStoresAutomaticallyOption: @YES,
									NSInferMappingModelAutomaticallyOption: @YES ,
									NSPersistentStoreUbiquitousContentNameKey: @"timetracker",
									NSPersistentStoreUbiquitousContentURLKey: [NSURL fileURLWithPath:[[iCloudBaseURL path] stringByAppendingPathComponent:@"Logs"]]
									};
			
            [psc lock];
			
			NSError *error = nil;
            if(![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self iCloudStoreURL] options:options error:&error]) {
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				useFallbackStore = YES;
			}
			
            [psc unlock];

        } else {
			useFallbackStore = YES;
		}
		
		if(useFallbackStore) {
            NSLog(@"iCloud is NOT working - using a local store");
			
			NSURL *localStore = [[NSURL URLWithString:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"timetracker.sqlite"];
			
            NSDictionary *options = @{
									NSMigratePersistentStoresAutomaticallyOption: @YES,
									NSInferMappingModelAutomaticallyOption: @YES
									};
			
            [psc lock];
			
			NSError *error = nil;
            if(![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:localStore options:options error:&error]) {
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				abort();
			}
            [psc unlock];
			
        }
		
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:TT_MODEL_CHANGED_NOTIFICATION object:self userInfo:nil];
        });
    });
	
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

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
    
    iCloudStoreURL = [iCloudStoreURL URLByAppendingPathComponent:@"timetracker.sqlite"];
    return iCloudStoreURL;
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

// Returns the URL to the application's Documents directory.
- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
