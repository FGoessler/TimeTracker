//
//  TTProject+TTExtension.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTProject+TTExtension.h"
#import "TTIssue+TTExtension.h"
#import "TTLogEntry+TTExtension.h"


@implementation TTProject (TTExtension)

+(TTProject*)createNewProjectWithName:(NSString*)name {
	NSManagedObjectContext *context = [TTCoreDataManager defaultManager].managedObjectContext;
	
	//create new project
    TTProject *newProject = [NSEntityDescription insertNewObjectForEntityForName:MOBJ_TTProject inManagedObjectContext:context];
    newProject.name = name;
	
	//create a new issue as the default issue
	TTIssue *defaultIssue = [NSEntityDescription insertNewObjectForEntityForName:MOBJ_TTIssue inManagedObjectContext:context];
	defaultIssue.name = @"Default Issue";
	
	newProject.defaultIssue = defaultIssue;
	[newProject addChildIssuesObject:defaultIssue];
	[newProject addChildIssuesObject:defaultIssue];
	
	[[TTCoreDataManager defaultManager] saveContext];
	
	return newProject;
}

-(TTIssue*)currentIssue {
	TTIssue *mostCurrentIssue = self.defaultIssue;
	for (TTIssue *issue in self.childIssues) {
		if([mostCurrentIssue.latestLogEntry.startDate compare:issue.latestLogEntry.startDate] == NSOrderedAscending) {
			mostCurrentIssue = issue;
		}
	}
	
	return mostCurrentIssue;
}

-(BOOL)addIssueWithName:(NSString *)name andError:(NSError**)err {	
	return [self addIssueWithName:name shortText:nil externalUID:nil andErrorIndicator:err];
}

-(BOOL)addIssueWithName:(NSString *)name shortText:(NSString *)text externalUID:(NSString *)uid andErrorIndicator:(NSError**)err {
	TTIssue *newIssue = [NSEntityDescription insertNewObjectForEntityForName:MOBJ_TTIssue inManagedObjectContext:self.managedObjectContext];
	
	newIssue.name = name;
	newIssue.shortText = text;
	newIssue.externalSystemUID = uid;
	newIssue.parentProject = self;
	
	return [self.managedObjectContext save:err];
}

@end
