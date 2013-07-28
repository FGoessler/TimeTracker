//
//  TTIssue+TTExtension.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

@implementation TTIssue (TTExtension)

- (TTLogEntry *)latestLogEntry {
	TTLogEntry *latestLogEntry = nil;
	for (TTLogEntry *logEntry in self.childLogEntries) {
		if (latestLogEntry == nil || [latestLogEntry.startDate compare:logEntry.startDate] == NSOrderedAscending) {
			latestLogEntry = logEntry;
		}
	}

	return latestLogEntry;
}

- (TTLogEntry *)createNewUnsavedLogEntry {
	TTLogEntry *newLogEntry = [NSEntityDescription insertNewObjectForEntityForName:MOBJ_TTLogEntry inManagedObjectContext:self.managedObjectContext];
	newLogEntry.parentIssue = self;

	return newLogEntry;
}

- (BOOL)startTracking:(NSError **)err {
	if (self.latestLogEntry.startDate != nil && self.latestLogEntry.endDate == nil) {    //do not allow to start tracking while a log entry is still active
		*err = [NSError errorWithDomain:@"TTModelError" code:TTLOG_ENTRY_STILL_ACTIVE userInfo:nil];
		return false;
	}

	//create new log entry
	TTLogEntry *newLogEntry = [self createNewUnsavedLogEntry];
	newLogEntry.startDate = [NSDate date];

	return [[TTCoreDataManager defaultManager] saveContext];
}

- (BOOL)stopTracking:(NSError **)err {
	if (self.latestLogEntry.endDate != nil) {    //do not allow to stop tracking when no log entry has been started and not yet stopped
		*err = [NSError errorWithDomain:@"TTModelError" code:TTLOG_ENTRY_NOT_ACTIVE userInfo:nil];
		return false;
	}

	//update log entry
	self.latestLogEntry.endDate = [NSDate date];

	return [[TTCoreDataManager defaultManager] saveContext];
}

- (TTIssue *)clone {
	TTIssue *newIssue = [NSEntityDescription insertNewObjectForEntityForName:MOBJ_TTIssue inManagedObjectContext:self.managedObjectContext];

	newIssue.name = self.name;
	newIssue.shortText = self.shortText;

	for (TTLogEntry *logEntry in self.childLogEntries) {
		[newIssue addChildLogEntriesObject:[logEntry clone]];
	}

	return newIssue;
}
@end
