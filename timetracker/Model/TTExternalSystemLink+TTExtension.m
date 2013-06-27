//
//  TTExternalSystemLink+TTExtension.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTExternalSystemLink+TTExtension.h"
#import "TTAppDelegate.h"

@implementation TTExternalSystemLink (TTExtension)

+(NSSet*)getAllSystemLinkTypes {
	return [NSSet setWithArray:@[TT_SYS_TYPE_GITHUB]];
}

+(TTExternalSystemLink*)createNewExternalSystemLinkOfType:(NSString*)type {
	TTAppDelegate *appDelegate =   [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;
	
	//create new project
    TTExternalSystemLink *newSysLink = [NSEntityDescription insertNewObjectForEntityForName:MOBJ_TTExternalSystemLink inManagedObjectContext:context];
    newSysLink.type = type;
	
	[appDelegate saveContext];
	
	return newSysLink;
}

@end
