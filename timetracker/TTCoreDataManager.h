//
//  TTCoreDataManager.h
//  timetracker
//
//  Created by Florian Goessler on 06.07.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^TTErrorHandler)(NSError*);

@interface TTCoreDataManager : NSObject
//Use this method to get a singleton instance of this manager
+(TTCoreDataManager*)defaultManager;

//Do NOT assign something to this property from an other class - unless for test cases!
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (BOOL)saveContext;
//Saves the context but executes the given handler if an error occurs. The handler should return true if he could solve or react on the error. If the handler is nil or returns false the default routine will try to solve the error or kill the app if the error could not been solved.
- (BOOL)saveContextWithErrorHandler:(TTErrorHandler)handler;
- (NSURL *)applicationDocumentsDirectory;

@end
