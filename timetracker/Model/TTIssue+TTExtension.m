//
//  TTIssue+TTExtension.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTIssue+TTExtension.h"

@implementation TTIssue (TTExtension)

-(TTLogEntry*)latestLogEntry {
	TTLogEntry *latestLogEntry = nil;
	for (TTLogEntry *logEntry in self.childLogEntries) {
		if(latestLogEntry == nil || [latestLogEntry.startDate compare:logEntry.startDate] == NSOrderedAscending) {
			latestLogEntry = logEntry;
		}
	}
	
	return latestLogEntry;
}

-(BOOL)startTracking:(NSError**)err {
	if (self.latestLogEntry.startDate != nil && self.latestLogEntry.endDate == nil) {	//do not allow to start tracking while a log entry is still active
		*err = [NSError errorWithDomain:@"TTModelError" code:TTLOG_ENTRY_STILL_ACTIVE userInfo:nil];
		return false;
	}
	
	//create new log entry
	TTLogEntry *newLogEntry = [NSEntityDescription insertNewObjectForEntityForName:MOBJ_TTLogEntry inManagedObjectContext:self.managedObjectContext];
	newLogEntry.startDate = [NSDate date];
	newLogEntry.parentIssue = self;

	return [self.managedObjectContext save:err];
}

-(BOOL)stopTracking:(NSError**)err {
	if (self.latestLogEntry.endDate != nil) {	//do not allow to stop tracking when no log entry has been started and not yet stoped
		*err = [NSError errorWithDomain:@"TTModelError" code:TTLOG_ENTRY_NOT_ACTIVE userInfo:nil];
		return false;
	}
	
	//update log entry
	self.latestLogEntry.endDate = [NSDate date];
	
	return [self.managedObjectContext save:err];
}

@end
