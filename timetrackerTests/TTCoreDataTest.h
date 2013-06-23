//
//  TTCoreDataTest.h
//  timetracker
//
//  Created by Florian Goessler on 23.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

//This test class which sets up a local ManagedObjectContext and its dependencies for each test. This ManagedObjectContext is injected into the TTAppDelegate by a category, so that every time some class under test asks the AppDelegate for a ManagedObjectContext it will get this prepared local ManagedObjectContext.  
@interface TTCoreDataTest : SenTestCase
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
