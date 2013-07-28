//
//  TTCoreDataManager.h
//  timetracker
//
//  Created by Florian Goessler on 06.07.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TT_MODEL_CHANGED_NOTIFICATION @"TT_MODEL_CHANGED_NOTIFICATION"

#define CLOUD_FILE_NAME @"de.floriangoessler.timetracker.f1234"
#define LOCAL_FILE_NAME @"CoreDataLocalFile"

typedef BOOL (^TTErrorHandler)(NSError*);

@interface TTCoreDataManager : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) UIManagedDocument *document;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFileCoordinator* coordinator;


//Use this method to get a singleton instance of this manager
+(TTCoreDataManager*)defaultManager;


- (BOOL)saveContext;
//Saves the context but executes the given handler if an error occurs. The handler should return true if he could solve or react on the error. If the handler is nil or returns false the default routine will try to solve the error or kill the app if the error could not been solved.
- (BOOL)saveContextWithErrorHandler:(TTErrorHandler)handler;

-(BOOL)isReady;

-(void)initCoreData;
@end
