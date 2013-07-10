//
//  TTCoreDataManager+Debug.h
//  timetracker
//
//  Created by Florian Goessler on 10.07.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTCoreDataManager.h"

@interface TTCoreDataManager (Debug)

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
