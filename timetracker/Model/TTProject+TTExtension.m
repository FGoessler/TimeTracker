//
//  TTProject+TTExtension.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//


@implementation TTProject (TTExtension)

+ (TTProject *)createNewProjectWithName:(NSString *)name {
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

- (TTIssue *)currentIssue {
	TTIssue *mostCurrentIssue = self.defaultIssue;
	for (TTIssue *issue in self.childIssues) {
		if ([mostCurrentIssue.latestLogEntry.startDate compare:issue.latestLogEntry.startDate] == NSOrderedAscending) {
			mostCurrentIssue = issue;
		}
	}

	return mostCurrentIssue;
}

- (BOOL)addIssueWithName:(NSString *)name andError:(NSError **)err {
	return [self addIssueWithName:name shortText:nil externalUID:nil andErrorIndicator:err];
}

- (BOOL)addIssueWithName:(NSString *)name shortText:(NSString *)text externalUID:(NSString *)uid andErrorIndicator:(NSError **)err {
	TTIssue *newIssue = [NSEntityDescription insertNewObjectForEntityForName:MOBJ_TTIssue inManagedObjectContext:self.managedObjectContext];

	newIssue.name = name;
	newIssue.shortText = text;
	newIssue.externalSystemUID = uid;
	newIssue.parentProject = self;

	return [[TTCoreDataManager defaultManager] saveContext];
}

- (TTProject *)clone {
	NSManagedObjectContext *context = [TTCoreDataManager defaultManager].managedObjectContext;

	//create new project
	TTProject *newProject = [NSEntityDescription insertNewObjectForEntityForName:MOBJ_TTProject inManagedObjectContext:context];
	newProject.name = [self.name stringByAppendingString:@" (Cloned)"];

	//clone all issues
	for (TTIssue *issue in self.childIssues) {
		[newProject addChildIssuesObject:[issue clone]];
	}

	//set the default issue
	for (TTIssue *issue in newProject.childIssues) {
		if ([issue.name isEqualToString:self.defaultIssue.name]) {
			newProject.defaultIssue = issue;
			break;
		}
	}

	[[TTCoreDataManager defaultManager] saveContext];

	return newProject;
}

@end
