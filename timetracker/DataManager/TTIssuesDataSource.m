//
//  TTIssueDataManager.m
//  timetracker
//
//  Created by Rainforce Fifteen on 25/06/2013.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTIssuesDataSource.h"
#import "TTAppDelegate.h"

@interface TTIssuesDataSource() 
@property (nonatomic, weak) UITableView* tableView;
@property (readonly, nonatomic, strong) TTProject* project;
@property (nonatomic, strong) NSArray* sortedIssues;
@end

@implementation TTIssuesDataSource

- (TTAppDelegate*)appDelegate {
	return [[UIApplication sharedApplication] delegate];
}

-(id)initWithProject:(TTProject*)project asDataSourceOfTableView:(UITableView*)tableView; {
	self = [super init];
	
	if(self) {
		_project = project;
		[_project addObserver:self forKeyPath:@"childIssues" options:0 context:nil];
		
		[self createSortedIssuesArray];
		
		_tableView = tableView;
		_tableView.DataSource = self;
	}
	
	return self;
}

-(void)dealloc {
	[self.project removeObserver:self forKeyPath:@"childIssues"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([keyPath isEqualToString:@"childIssues"] && object == self.project) {
		[self createSortedIssuesArray];
		[self.tableView reloadData];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

-(TTIssue*)issueAtIndexPath:(NSIndexPath*)indexPath {
	return self.sortedIssues[indexPath.row];
}

//creates a sorted list of the issues
- (void)createSortedIssuesArray {
	self.sortedIssues = [[self.project.childIssues allObjects] sortedArrayUsingComparator:^NSComparisonResult(TTIssue *obj1, TTIssue *obj2){
		return [obj2.latestLogEntry.startDate compare:obj1.latestLogEntry.startDate];
	}];
}

#pragma mark TableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.sortedIssues.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IssueCell"];
	
	//configure cell
	TTIssue *currentIssue = [self issueAtIndexPath:indexPath];
	cell.textLabel.text = currentIssue.name;
	cell.detailTextLabel.text = @"";
	
	return cell;
}

//Allow swipe to delte for all rows.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
//Handle deletions.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		TTIssue *issue = [self issueAtIndexPath:indexPath];
		[self.project removeChildIssuesObject:issue];
		
		if(issue == self.project.defaultIssue) {	//if the user deletes the DefaultIssue try to set a new DefaultIssue and display a error message when this cannot be done.
			if(self.project.childIssues.count > 0) {
				self.project.defaultIssue = [self.project.childIssues allObjects][0];
			} else {
				[[[UIAlertView alloc] initWithTitle:@"Action not allowed!" message:@"You cannot delete all issues!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
				[[self appDelegate].managedObjectContext rollback];
				return;
			}
		}
		
		[[self appDelegate].managedObjectContext deleteObject:issue];		
		[[self appDelegate] saveContextWithErrorHandler:^BOOL(NSError *err) {
			//show a message to inform the user about a generic error
			[[[UIAlertView alloc] initWithTitle:@"Action not allowed!" message:@"You are not allowed to delete this issue!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
			[[self appDelegate].managedObjectContext rollback];
			return YES;
		}];
    }
}

@end
