//
//  TTCloudHelper.h
//  timetracker
//
//  Created by Florian Goessler on 23.07.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTCloudHelper : NSObject

+ (NSString *) documentState: (int) state;

+ (BOOL)isICloudWishedByUser;

+ (BOOL)hasUserBeenAskedForICloudUsage;

+ (void)setUsersStoredICloudChoice:(NSNumber *)useICloud;

// URLs
+ (NSString *) localDocumentsPath;
+ (NSURL *) localDocumentsURL;
+ (NSURL *) ubiquityDataURLForContainer: (NSString *) container;
+ (NSURL *) ubiquityDataURL;

// Files URLs
+ (NSURL *) localFileURL: (NSString *) filename;
+ (NSURL *) ubiquityDataFileURL: (NSString *) filename;

// Testing Files
+ (BOOL) isLocal: (NSString *) filename;

@end
