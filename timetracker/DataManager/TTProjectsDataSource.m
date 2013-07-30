//
//  TTProjectDataManager.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTProjectsDataSource.h"


@interface TTProjectsDataSource () <NSFetchedResultsControllerDelegate>
@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, strong) NSTimer *pollingTimer;
@end

@implementation TTProjectsDataSource

- (id)initAsDataSourceOfTableView:(UITableView *)tableView {
	self = [super init];

	if (self) {
		tableView.DataSource = self;
		_tableView = tableView;

		self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRows) userInfo:nil repeats:YES];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOnICloudChange:) name:TT_MODEL_CHANGED_NOTIFICATION object:nil];
	}

	return self;
}

- (void)dealloc {
	[self.pollingTimer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (TTProject *)projectAtIndexPath:(NSIndexPath *)indexPath {
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)updateOnICloudChange:(NSNotification *)notification {
	NSLog(@"updating project list...");

	self.fetchedResultsController = nil;
	[self.tableView reloadData];
}

- (void)updateRows {
	int numberOfRows = [self tableView:self.tableView numberOfRowsInSection:0];
	for (int i = 0; i < numberOfRows; i++) {
		[self configureCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
	}
}

#pragma mark - FetchedResultsController


- (NSFetchedResultsController *)fetchedResultsController {
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}

	//init the request with an entity (TTProject)
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:MOBJ_TTProject inManagedObjectContext:[TTCoreDataManager defaultManager].managedObjectContext];
	[fetchRequest setEntity:entity];

	//set sort descriptor
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];

	[fetchRequest setSortDescriptors:@[sortDescriptor]];

	//init the FetchedResultsController with no sections and a cache
	_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[TTCoreDataManager defaultManager].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	_fetchedResultsController.delegate = self;

	//perform fetch
	NSError *error;
	[_fetchedResultsController performFetch:&error];

	if (error) {
		NSLog(@"error while performing fetch:%@", error);
	}

	return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}

//Handle changes of the data to update the UI.
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *tableView = self.tableView;

	switch (type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;

		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;

		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView endUpdates];
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([[TTCoreDataManager defaultManager] isReady]) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
		return [sectionInfo numberOfObjects];
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectCell"];

	cell = [self configureCell:cell atIndexPath:indexPath];

	return cell;
}

//Allow swipe to delete for all rows.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

//Handle deletions.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[[TTCoreDataManager defaultManager].managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		[[TTCoreDataManager defaultManager] saveContext];
	}
}


//This method configures a cell based on the data delivered by the FetchedResultsController.
- (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	TTProject *project = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = project.name;
	cell.detailTextLabel.text = [NSString stringWithNSTimeInterval:[((NSNumber *) [project valueForKeyPath:@"childIssues.@sum.childLogEntries.@sum.timeInterval"]) doubleValue]];
	[cell setNeedsLayout];

	return cell;
}

@end
