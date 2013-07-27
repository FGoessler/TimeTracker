//
//  TTCoreDataManager.m
//  timetracker
//
//  Created by Florian Goessler on 06.07.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTCloudHelper.h"

@implementation TTCoreDataManager

#pragma mark - Singleton

@synthesize testThat;

+(TTCoreDataManager *)defaultManager {
	static TTCoreDataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)dealloc {
	if(self.document.documentState != UIDocumentStateClosed) {
		[self.document closeWithCompletionHandler:^(BOOL success) {
			NSLog(@"closed file - success:%d", success);
		}];
	}
	
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
        } else {
			//save document
			[self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
				NSLog(@"Saved document - success:%d", success);
			}];
		}
    }
	return true;	//return true to indicate that no error happened
}

-(BOOL)isReady {
	return self.managedObjectContext != nil;
}

- (void) initCoreData
{

	NSURL *localURL = [TTCloudHelper localFileURL:LOCAL_FILE_NAME];
    NSURL *cloudURL = [TTCloudHelper ubiquityDataFileURL:CLOUD_FILE_NAME];
	
	NSLog(@"local URL:%@", localURL);
	NSLog(@"cloud URL:%@", cloudURL);
	
    // Create the document pointing to the local sandbox
    self.document = [[UIManagedDocument alloc] initWithFileURL:localURL];
	
	NSDictionary *options;
	if ([TTCloudHelper ubiquityDataURL] != NULL) {
		// Set the persistent store options to point to the cloud
		options = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				CLOUD_FILE_NAME,
				   NSPersistentStoreUbiquitousContentNameKey,
				   cloudURL,
				   NSPersistentStoreUbiquitousContentURLKey,
				   [NSNumber numberWithBool:YES],
				   NSMigratePersistentStoresAutomaticallyOption,
				   [NSNumber numberWithBool:YES],
				   NSInferMappingModelAutomaticallyOption,
				   nil];
	} else {
		options = [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSNumber numberWithBool:YES],
                   NSMigratePersistentStoresAutomaticallyOption,
                   [NSNumber numberWithBool:YES],
                   NSInferMappingModelAutomaticallyOption, nil];
	}
    
    self.document.persistentStoreOptions = options;
	
    // Register as presenter
    self.coordinator = [[NSFileCoordinator alloc]
						initWithFilePresenter:self.document];
    [NSFileCoordinator addFilePresenter:self.document];
	
    // Check at the local sandbox
    if ([TTCloudHelper isLocal:LOCAL_FILE_NAME])
    {
		NSLog(@"Attempting to open existing file");
        [self.document openWithCompletionHandler:^(BOOL success){
            if (!success) {NSLog(@"Error opening file"); return;}
            NSLog(@"File opened");
			
			self.managedObjectContext = self.document.managedObjectContext;
			
				NSLog(@"Loaded File - going to fire notification...");
            NSNotification* refreshNotification = [NSNotification notificationWithName:TT_MODEL_CHANGED_NOTIFICATION object:self userInfo:nil];
			[[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
        }];
	}
	else
	{
        NSLog(@"Creating file.");
        // 1. save it out, 2. close it, 3. read it back in.
        [self.document saveToURL:localURL
				forSaveOperation:UIDocumentSaveForCreating
			   completionHandler:^(BOOL success){
				   if (!success) { NSLog(@"Error creating file"); return; }
				   NSLog(@"File created");
				   [self.document closeWithCompletionHandler:^(BOOL success){
					   NSLog(@"Closed new file: %@", success ?
							 @"Success" : @"Failure");
					   [self.document openWithCompletionHandler:^(BOOL success){
						   if (!success) {
							   NSLog(@"Error opening file for reading.");
							   return;}
						   NSLog(@"File opened for reading.");
						   
						   self.managedObjectContext = self.document.managedObjectContext;
						   
						   	NSLog(@"Created file - going to fire notification...");
						   NSNotification* refreshNotification = [NSNotification notificationWithName:TT_MODEL_CHANGED_NOTIFICATION object:self userInfo:nil];
						   [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
					   }];
				   }];
			   }];
	}
	
	// Register to be notified of changes to the persistent store
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(documentStateChanged:)
		name: UIDocumentStateChangedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentContentsDidUpdate:)
		name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
}


// When notified about a cloud update, start merging changes
- (void) documentContentsDidUpdate: (NSNotification *) notification
{
	NSLog(@"Cloud has been updated.");
	[self.managedObjectContext performBlock:^{
		[self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];

		[self saveContext];
		
		NSLog(@"Cloud update - going to fire notification...");

		dispatch_async(dispatch_get_main_queue(), ^(){
			NSNotification* refreshNotification = [NSNotification notificationWithName:TT_MODEL_CHANGED_NOTIFICATION object:self userInfo:nil];
			[[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
		});
	}];
}

- (void)documentStateChanged: (NSNotification *)notification
{
	NSLog(@"Document state change: %@", [TTCloudHelper documentState:self.document.documentState]);

	UIDocumentState documentState = self.document.documentState;
	if (documentState & UIDocumentStateInConflict)
	{
		// This application uses a basic newest version wins conflict resolution strategy
		NSURL *documentURL = self.document.fileURL;
		NSArray *conflictVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:documentURL];
		for (NSFileVersion *fileVersion in conflictVersions) {
			fileVersion.resolved = YES;
		}
		[NSFileVersion removeOtherVersionsOfItemAtURL:documentURL error:nil];
	}
}

@end