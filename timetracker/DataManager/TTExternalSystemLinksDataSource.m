//
//  TTExternalSystemLinksDataSource.m
//  timetracker
//
//  Created by Florian Goessler on 27.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTExternalSystemLinksDataSource.h"

@interface TTExternalSystemLinksDataSource () <NSFetchedResultsControllerDelegate>
@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, weak) UITableView *tableView;
@end

@implementation TTExternalSystemLinksDataSource

- (id)initAsDataSourceOfTableView:(UITableView *)tableView {
	self = [super init];

	if (self) {
		tableView.DataSource = self;
		_tableView = tableView;
	}

	return self;
}

- (TTExternalSystemLink *)systemLinkAtIndexPath:(NSIndexPath *)indexPath {
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - FetchedResultsController


- (NSFetchedResultsController *)fetchedResultsController {
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}

	//init the request with an entity (TTProject)
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:MOBJ_TTExternalSystemLink inManagedObjectContext:[TTCoreDataManager defaultManager].managedObjectContext];
	[fetchRequest setEntity:entity];

	//set batch size
	[fetchRequest setFetchBatchSize:20];

	//set sort descriptor
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES];

	[fetchRequest setSortDescriptors:@[sortDescriptor]];

	//init the FetchedResultsController with no sections and a cache
	_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[TTCoreDataManager defaultManager].managedObjectContext sectionNameKeyPath:nil cacheName:@"SystemLinks"];
	_fetchedResultsController.delegate = self;

	//perform fetch
	[_fetchedResultsController performFetch:nil];

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
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LinksCell"];

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
	TTExternalSystemLink *systemLink = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = [NSString stringWithFormat:@"%@", systemLink.type];
	if (systemLink.username != nil) {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"user: %@", systemLink.username];
	} else {
		cell.detailTextLabel.text = @"no user data";
	}
	[cell setNeedsLayout];

	return cell;
}

@end
