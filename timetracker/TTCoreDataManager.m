//
//  TTCoreDataManager.m
//  timetracker
//
//  Created by Florian Goessler on 06.07.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTCloudHelper.h"
#import "TTProjectsVC.h"

typedef void (^TTAlertViewHandler)(NSInteger selectedButtonIndex);

@interface TTCoreDataManager ()
@property(nonatomic, strong) TTAlertViewHandler alertViewHandler;
@end

@implementation TTCoreDataManager

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (self.alertViewHandler) {
		self.alertViewHandler(buttonIndex);
		self.alertViewHandler = nil;
	}
}

#pragma mark - Singleton

+ (TTCoreDataManager *)defaultManager {
	static TTCoreDataManager *sharedMyManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedMyManager = [[self alloc] init];
	});
	return sharedMyManager;
}

- (void)dealloc {
	if (self.document.documentState != UIDocumentStateClosed) {
		[self.document closeWithCompletionHandler:^(BOOL success) {
			NSLog(@"closed file - success:%d", success);
		}];
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Save Methods

- (BOOL)saveContext {
	return [self saveContextWithErrorHandler:nil];
}

- (BOOL)saveContextWithErrorHandler:(TTErrorHandler)handler {
	NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
	if (managedObjectContext != nil) {
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			if (handler != nil) {
				if (handler(error)) {
					return false;    //return false to indicate that an error happened
				}
			}


			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();     //kill the app if the error could not been handled
		} else {
			//save document
			[self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting
				   completionHandler:^(BOOL success) {
					   NSLog(@"Saved document - success:%d", success);
				   }];
		}
	}
	return true;    //return true to indicate that no error happened
}

- (BOOL)isReady {
	return self.managedObjectContext != nil;
}

- (void)initCoreData {
	if (![TTCloudHelper hasUserBeenAskedForICloudUsage] && [TTCloudHelper ubiquityDataURL] != nil) {
		self.alertViewHandler = ^(NSInteger buttonIndex) {
			if (buttonIndex == 0) {
				[TTCloudHelper setUsersStoredICloudChoice:@(NO)];
			} else {
				[TTCloudHelper setUsersStoredICloudChoice:@(YES)];
			}
			[self initDocument];
		};
		[[[UIAlertView alloc] initWithTitle:@"Use iCloud?"
									message:@"Do you want to use iCloud? (At the moment you won't be able to change "
													"this setting without reinstallation!)"
								   delegate:self
						  cancelButtonTitle:@"No"
						  otherButtonTitles:@"Yes", nil] show];
	} else {
		[self initDocument];
	}
}

- (void)initDocument {

	NSURL *localURL = [TTCloudHelper localFileURL:LOCAL_FILE_NAME];
	NSURL *cloudURL = [TTCloudHelper ubiquityDataFileURL:CLOUD_FILE_NAME];

	NSLog(@"local URL:%@", localURL);
	NSLog(@"cloud URL:%@", cloudURL);

	// create the document in the local sandbox
	self.document = [[UIManagedDocument alloc] initWithFileURL:localURL];

	NSDictionary *options;
	if ([TTCloudHelper ubiquityDataURL] != NULL && [TTCloudHelper isICloudWishedByUser]) {
		// set the persistent store options to support iCloud
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

	// register as presenter
	self.coordinator = [[NSFileCoordinator alloc]
			initWithFilePresenter:self.document];
	[NSFileCoordinator addFilePresenter:self.document];

	// check if the file already exists
	if ([TTCloudHelper isLocal:LOCAL_FILE_NAME]) {
		NSLog(@"Attempting to open existing file");
		[self.document openWithCompletionHandler:^(BOOL success) {
			if (!success) {
				NSLog(@"Error opening file");
				return;
			}
			NSLog(@"File opened");

			self.managedObjectContext = self.document.managedObjectContext;

			NSLog(@"Loaded File - going to fire notification...");
			NSNotification *refreshNotification = [NSNotification notificationWithName:TT_MODEL_CHANGED_NOTIFICATION
																				object:self
																			  userInfo:nil];
			[[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
		}];
	}
	else {
		NSLog(@"Creating file.");
		// 1. save it out, 2. close it, 3. read it back in.
		[self.document saveToURL:localURL
				forSaveOperation:UIDocumentSaveForCreating
			   completionHandler:^(BOOL success) {
				   if (!success) {
					   NSLog(@"Error creating file");
					   return;
				   }
				   NSLog(@"File created");
				   [self.document closeWithCompletionHandler:^(BOOL success) {
					   NSLog(@"Closed new file: %@", success ?
							   @"Success" : @"Failure");
					   [self.document openWithCompletionHandler:^(BOOL success) {
						   if (!success) {
							   NSLog(@"Error opening file for reading.");
							   return;
						   }
						   NSLog(@"File opened for reading.");

						   self.managedObjectContext = self.document.managedObjectContext;

						   NSLog(@"Created file - going to fire notification...");
						   NSNotification *refreshNotification = [NSNotification notificationWithName:TT_MODEL_CHANGED_NOTIFICATION
																							   object:self
																							 userInfo:nil];
						   [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
					   }];
				   }];
			   }];
	}

	// Register to be notified of changes to the persistent store
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(documentStateChanged:)
												 name:UIDocumentStateChangedNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(documentContentsDidUpdate:)
												 name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
											   object:nil];
	// Register for changes of the iCloud account on the device
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(iCloudUserChanged:)
												 name:NSUbiquityIdentityDidChangeNotification
											   object:nil];
}

//When notified about a iCloud user change - remove any existing CoreData stuff and go back to the initial view controller
- (void)iCloudUserChanged:(NSNotification *)notification {
	NSLog(@"iCloud user changed...");

	if ([TTCloudHelper isICloudWishedByUser]) {
		//existing data was stored in cloud -> delete all local data and work like a "clean app"
		[TTCloudHelper setUsersStoredICloudChoice:nil];
		[self resetUsersData];
	} else if ([TTCloudHelper ubiquityDataURL] != nil) {
		//existing data was only local -> if iCloud is available now ask the user if he wants to switch to it
		self.alertViewHandler = ^(NSInteger buttonIndex) {
			if (buttonIndex == 1) {
				[TTCloudHelper setUsersStoredICloudChoice:@(YES)];
				[self resetUsersData];
			}
		};

		[[[UIAlertView alloc] initWithTitle:@"Use iCloud?"
									message:@"Do you want to use iCloud? (At the moment you won't be able to change this setting without reinstallation and any existing data will be lost!)"
								   delegate:self
						  cancelButtonTitle:@"No"
						  otherButtonTitles:@"Yes", nil] show];
	}
	// if data was only local and and iCloud isn't available now, we have nothing to do here
}

- (void)resetUsersData {
	[self.document closeWithCompletionHandler:^(BOOL success) {
		NSError *err;
		[[NSFileManager defaultManager] removeItemAtURL:self.document.fileURL error:&err];

		if (err) {
			NSLog(@"error removing file at %@ \n %@", self.document.fileURL, err);
		}

		[[NSNotificationCenter defaultCenter] removeObserver:self];

		self.document = nil;
		self.managedObjectContext = nil;
		self.coordinator = nil;

		[self initCoreData];

		UINavigationController *rootVC = (UINavigationController *) [UIApplication sharedApplication].delegate.window.rootViewController;
		[rootVC dismissViewControllerAnimated:NO completion:nil];
		[rootVC popToRootViewControllerAnimated:NO];

		[((TTProjectsVC *) rootVC.topViewController) showICloudMessage];
	}];
}


// When notified about a cloud update, start merging changes
- (void)documentContentsDidUpdate:(NSNotification *)notification {
	NSLog(@"Cloud has been updated.");
	[self.managedObjectContext performBlock:^{
		[self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];

		[self saveContext];

		NSLog(@"Cloud update - going to fire notification...");

		dispatch_async(dispatch_get_main_queue(), ^() {
			NSNotification *refreshNotification = [NSNotification notificationWithName:TT_MODEL_CHANGED_NOTIFICATION
																				object:self
																			  userInfo:nil];
			[[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
		});
	}];
}

- (void)documentStateChanged:(NSNotification *)notification {
	NSLog(@"Document state change: %@", [TTCloudHelper documentState:self.document.documentState]);

	UIDocumentState documentState = self.document.documentState;
	if (documentState & UIDocumentStateInConflict) {
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