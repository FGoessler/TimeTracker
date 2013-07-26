//
//  TTLogEntryDataManager.m
//  timetracker
//
//  Created by Florian Goessler on 24.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTLogEntriesDataSource.h"

@interface TTLogEntriesDataSource()
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *sortedChildLogEntries;

@property (nonatomic) NSInteger restrictedSection;
@property (nonatomic, strong) id<UITableViewDataSource> secondDataSource;
@end
@implementation TTLogEntriesDataSource

-(id)initWithIssue:(TTIssue*)issue asDataSourceOfTableView:(UITableView*)tableView {
	self = [super init];
	
	if(self != nil) {
		self.restrictedSection = 0;

		self.issue = issue;
		[self createSortedChildLogEntries];
		
		//register for changes on the childLogEntries property
		[self.issue addObserver:self forKeyPath:@"childLogEntries" options:0 context:nil];
		
		self.tableView = tableView;
		self.tableView.dataSource = self;
	}
	
	return self;
}

-(void)dealloc {
	[self removeDateChangedObserverForAllIssues];
	[self.issue removeObserver:self forKeyPath:@"childLogEntries"];
}

-(void)restrictToSection:(NSInteger)section andSetSecondHandDataSource:(id<UITableViewDataSource>)dataSource {
	self.restrictedSection = section;
	self.secondDataSource = dataSource;
}

-(TTLogEntry*)logEntryAtIndexPath:(NSIndexPath*)indexPath {
	if(self.sortedChildLogEntries.count > 0 && ((TTLogEntry*)self.sortedChildLogEntries[0]).endDate == nil) {
		return self.sortedChildLogEntries[indexPath.row+1];		//do not show the currently running log entry
	} else {
		return self.sortedChildLogEntries[indexPath.row];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	//handle changes of the childLogEntries property of the issue
	if([keyPath isEqualToString:@"childLogEntries"] && object == self.issue) {
		[self createSortedChildLogEntries];		//recreate the sorted list
		[self.tableView reloadData];
		return;
	} else if(([keyPath isEqualToString:@"startDate"] || [keyPath isEqualToString:@"endDate"])&& [object isKindOfClass:[TTLogEntry class]]) {
		[self.tableView reloadData];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

//creates a sorted list of the log entries (sorted by startDate)
- (void)createSortedChildLogEntries {
	[self removeDateChangedObserverForAllIssues];

	self.sortedChildLogEntries = [[self.issue.childLogEntries allObjects] sortedArrayUsingComparator:^NSComparisonResult(TTLogEntry *obj1, TTLogEntry *obj2){
		return [obj2.startDate compare:obj1.startDate];
	}];

	[self registerDateChangedObserverForAllIssues];
}

-(void)registerDateChangedObserverForAllIssues {
	for (TTLogEntry *logEntry in self.sortedChildLogEntries) {
		[logEntry addObserver:self forKeyPath:@"startDate" options:0 context:nil];
		[logEntry addObserver:self forKeyPath:@"endDate" options:0 context:nil];
	}
}

-(void)removeDateChangedObserverForAllIssues {
	for (TTLogEntry *logEntry in self.sortedChildLogEntries) {
		[logEntry removeObserver:self forKeyPath:@"startDate"];
		[logEntry removeObserver:self forKeyPath:@"endDate"];
	}
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(self.secondDataSource && [self.secondDataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
		return [self.secondDataSource numberOfSectionsInTableView:tableView];
	} else {
		return 1;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if(self.secondDataSource && [self.secondDataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
		return [self.secondDataSource tableView:tableView titleForFooterInSection:section];
	} else {
		return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(self.secondDataSource && [self.secondDataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
		return [self.secondDataSource tableView:tableView titleForHeaderInSection:section];
	} else {
		return nil;
	}
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	if(section == self.restrictedSection) {
		if(self.sortedChildLogEntries.count > 0 && ((TTLogEntry*)self.sortedChildLogEntries[0]).endDate == nil) {
			rows = self.sortedChildLogEntries.count - 1;	//do not show the currently running log entry
		} else {
			rows = self.sortedChildLogEntries.count;
		}
	} else {
		if(self.secondDataSource && [self.secondDataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
			rows = [self.secondDataSource tableView:tableView numberOfRowsInSection:section];
		}
	}
	return rows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	if(indexPath.section == self.restrictedSection) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"TrackingCell"];

		//configure cell
		TTLogEntry *logEntry = [self logEntryAtIndexPath:indexPath];
		cell.textLabel.text = [NSString stringWithNSTimeInterval:logEntry.timeInterval];
		if(logEntry.endDate == nil) {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - now",[NSString stringWithNSDate:logEntry.startDate]];
		} else {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",[NSString stringWithNSDate:logEntry.startDate], [NSString stringWithNSDate:logEntry.endDate]];
		}
	} else {
		if(self.secondDataSource && [self.secondDataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
			cell = [self.secondDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
		}
	}
	return cell;
}

//Allow swipe to delete for all rows.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL result = NO;
	if(self.restrictedSection == indexPath.section) {
		result = YES;
	} else {
		if(self.secondDataSource && [self.secondDataSource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
			result = [self.secondDataSource tableView:tableView canEditRowAtIndexPath:indexPath];
		}
	}
	return result;
}

//Handle deletions.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.restrictedSection == indexPath.section) {
		if (editingStyle == UITableViewCellEditingStyleDelete) {
			TTLogEntry *logEntry = [self logEntryAtIndexPath:indexPath];
			TTIssue *parentIssue = logEntry.parentIssue;
			[[TTCoreDataManager defaultManager].managedObjectContext deleteObject:logEntry];
			[[TTCoreDataManager defaultManager]saveContext];

			[[TTExternalSystemLink externalSystemInterfaceForType:parentIssue.parentProject.parentSystemLink.type] syncTimelogEntriesOfIssues:parentIssue];
		}
	} else {
		if(self.secondDataSource && [self.secondDataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
			[self.secondDataSource tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
		}
	}
}

@end
