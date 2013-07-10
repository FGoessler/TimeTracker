//
//  TTCoreDataManager.h
//  timetracker
//
//  Created by Florian Goessler on 06.07.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TT_MODEL_CHANGED_NOTIFICATION @"TT_MODEL_CHANGED_NOTIFICATION"
#define TT_ICLOUD_INITATION_NOTIFICATION @"TT_ICLOUD_INITATION"

typedef BOOL (^TTErrorHandler)(NSError*);

@interface TTCoreDataManager : NSObject <NSFilePresenter>
//Use this method to get a singleton instance of this manager
+(TTCoreDataManager*)defaultManager;

- (BOOL)saveContext;
//Saves the context but executes the given handler if an error occurs. The handler should return true if he could solve or react on the error. If the handler is nil or returns false the default routine will try to solve the error or kill the app if the error could not been solved.
- (BOOL)saveContextWithErrorHandler:(TTErrorHandler)handler;


@property (nonatomic, readonly) NSPersistentStoreCoordinator *psc;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSPersistentStore *iCloudStore;
@property (nonatomic, readonly) NSPersistentStore *fallbackStore;

@property (nonatomic, readonly) NSURL *ubiquityURL;
@property (nonatomic, readonly) id currentUbiquityToken;

/*
 Called by the AppDelegate whenever the application becomes active.
 We use this signal to check to see if the container identifier has
 changed.
 */
- (void)applicationResumed;

/*
 Load all the various persistent stores
 - The iCloud Store / Fallback Store if iCloud is not available
 - The persistent store used to store local data
 
 Also:
 - Seed the database if desired (using the SEED #define)
 - Unique
 */
- (void)loadPersistentStores;

#pragma mark Debugging Methods
/*
 Copy the entire contents of the application's iCloud container to the Application's sandbox.
 Use this on iOS to copy the entire contents of the iCloud Continer to the application sandbox
 where they can be downloaded by Xcode.
 */
- (void)copyContainerToSandbox;

/*
 Delete the contents of the ubiquity container, this method will do a coordinated write to
 delete every file inside the Application's iCloud Container.
 */
- (void)nukeAndPave;

@end
