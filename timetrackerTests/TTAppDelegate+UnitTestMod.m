//
//  TTAppDelegate+UnitTestMod.m
//  timetracker
//
//  Created by Florian Goessler on 23.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTAppDelegate+UnitTestMod.h"

@implementation TTAppDelegate (UnitTestMod)

-(NSManagedObjectContext *)managedObjectContext {
	if(testManagedObjectContext) {
		return testManagedObjectContext;
	} else {
		
	}
	
	return nil;
}

@end
