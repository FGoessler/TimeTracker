//
//  TTLogEntryDataManager.m
//  timetracker
//
//  Created by Florian Goessler on 24.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTLogEntryDataManager.h"
#import "TTLogEntries+TTExtension.h"
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

-(TTLogEntries*)logEntryAtIndexPath:(NSIndexPath*)indexPath {
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
	self.sortedChildLogEntries = [[self.issue.childLogEntries allObjects] sortedArrayUsingComparator:^NSComparisonResult(TTLogEntries *obj1, TTLogEntries *obj2){
		return [obj2.startDate compare:obj1.startDate];
	}];
}

#pragma mark - TableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.issue.childLogEntries.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackingCell"];
	
	//configure cell
	TTLogEntries *logEntry = [self logEntryAtIndexPath:indexPath];
	cell.textLabel.text = [NSString stringWithNSTimeInterval:logEntry.timeInterval];
	if(logEntry.endDate == nil) {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - now",logEntry.startDate];
	} else {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",logEntry.startDate, logEntry.endDate];
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
		TTLogEntries *logEntry = [self logEntryAtIndexPath:indexPath];
		[[self appDelegate].managedObjectContext deleteObject:logEntry];
		[[self appDelegate] saveContext];
    }
}

@end
