//
//  TTLogEntryDataManager.m
//  timetracker
//
//  Created by Florian Goessler on 24.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTLogEntryDataManager.h"
#import "TTAppDelegate.h"


@interface TTLogEntryDataManager()
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *sortedChildLogEntries;
@end
@implementation TTLogEntryDataManager

- (TTAppDelegate*)appDelegate {
	return [[UIApplication sharedApplication] delegate];
}

-(id)initWithIssue:(TTIssue*)issue asDataSourceOfTableView:(UITableView*)tableView {
	self = [super init];
	
	if(self != nil) {
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
	[self.issue removeObserver:self forKeyPath:@"childLogEntries"];
}

-(TTLogEntry*)logEntryAtIndexPath:(NSIndexPath*)indexPath {
	return self.sortedChildLogEntries[indexPath.row];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {	
	//handle changes of the childLogEntries property of the issue
	if([keyPath isEqualToString:@"childLogEntries"] && object == self.issue) {
		[self createSortedChildLogEntries];		//recreate the sorted list
		[self.tableView reloadData];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

//creates a sorted list of the log entries (sorted by startDate)
- (void)createSortedChildLogEntries {
	self.sortedChildLogEntries = [[self.issue.childLogEntries allObjects] sortedArrayUsingComparator:^NSComparisonResult(TTLogEntry *obj1, TTLogEntry *obj2){
		return [obj2.startDate compare:obj1.startDate];
	}];
}

#pragma mark - TableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.sortedChildLogEntries.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackingCell"];
	
	//configure cell
	TTLogEntry *logEntry = [self logEntryAtIndexPath:indexPath];
	cell.textLabel.text = [NSString stringWithNSTimeInterval:logEntry.timeInterval];
	if(logEntry.endDate == nil) {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - now",[NSString stringWithNSDate:logEntry.startDate]];
	} else {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",[NSString stringWithNSDate:logEntry.startDate], [NSString stringWithNSDate:logEntry.endDate]];
	}
	
	return cell;
}

//Allow swipe to delte for all rows.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
//Handle deletions.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		TTLogEntry *logEntry = [self logEntryAtIndexPath:indexPath];
		[[self appDelegate].managedObjectContext deleteObject:logEntry];
		[[self appDelegate] saveContext];
    }
}

@end
