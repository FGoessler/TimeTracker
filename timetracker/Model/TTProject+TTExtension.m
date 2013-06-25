//
//  TTProject+TTExtension.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTProject+TTExtension.h"


@implementation TTProject (TTExtension)

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
	TTIssue *newIssue = [NSEntityDescription insertNewObjectForEntityForName:MOBJ_TTIssue inManagedObjectContext:self.managedObjectContext];
	
	newIssue.name = name;
	newIssue.parentProject = self;
	
	return [self.managedObjectContext save:err];
}

@end
