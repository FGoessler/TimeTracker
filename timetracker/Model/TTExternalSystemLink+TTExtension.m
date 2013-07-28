//
//  TTExternalSystemLink+TTExtension.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTGitHubAPI.h"

@implementation TTExternalSystemLink (TTExtension)

+ (NSSet *)getAllSystemLinkTypes {
	return [NSSet setWithArray:@[TT_SYS_TYPE_GITHUB]];
}

+ (TTExternalSystemLink *)createNewExternalSystemLinkOfType:(NSString *)type {
	NSManagedObjectContext *context = [TTCoreDataManager defaultManager].managedObjectContext;

	//create new project
	TTExternalSystemLink *newSysLink = [NSEntityDescription insertNewObjectForEntityForName:MOBJ_TTExternalSystemLink inManagedObjectContext:context];
	newSysLink.type = type;

	[[TTCoreDataManager defaultManager] saveContext];

	return newSysLink;
}

+ (id <TTExternalSystemInterface>)externalSystemInterfaceForType:(NSString *)type {
	if ([type isEqualToString:TT_SYS_TYPE_GITHUB]) {
		return [[TTGitHubAPI alloc] init];
	}
	return nil;
}


@end
