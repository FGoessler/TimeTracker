//
//  TTProjectDataManager.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTProjectsDataSource.h"
#import "TTAppDelegate.h"


@interface TTProjectsDataSource() <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, strong) NSTimer* pollingTimer;
@end

@implementation TTProjectsDataSource

- (TTAppDelegate*)appDelegate {
	return [[UIApplication sharedApplication] delegate];
}

-(id)initAsDataSourceOfTableView:(UITableView*)tableView {
	self = [super init];
	
	if(self) {
		tableView.DataSource = self;
		_tableView = tableView;
		
		self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRows) userInfo:nil repeats:YES];
	}
	
	return self;
}

-(void)dealloc {
	[self.pollingTimer invalidate];
}

-(TTProject*)projectAtIndexPath:(NSIndexPath*)indexPath {
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)updateRows {
	int numberOfRows = [self tableView:self.tableView numberOfRowsInSection:0];
	for (int i = 0; i < numberOfRows; i++) {
		[self configureCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0		]] atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
	}
}

#pragma mark - FetchedResultsController


- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
	//init the request with an entity (TTProject)
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:MOBJ_TTProject inManagedObjectContext:[self appDelegate].managedObjectContext];
    [fetchRequest setEntity:entity];
    
	//set batch size
    [fetchRequest setFetchBatchSize:20];
	
	//set sort descriptor
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
	//init the FetchedResultsController with no sections and a cache
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self appDelegate].managedObjectContext sectionNameKeyPath:nil cacheName:@"Projects"];
    _fetchedResultsController.delegate = self;
	
	//perform fetch
	[_fetchedResultsController performFetch:nil];
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

//Handle changes of the data to update the UI.
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - TableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
	return [sectionInfo numberOfObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
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
		[[self appDelegate].managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		[[self appDelegate] saveContext];
    }
}


//This method configures a cell based on the data delivered by the FetchedResultsController.
-(UITableViewCell*)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
	TTProject *project = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = project.name;
	cell.detailTextLabel.text = [NSString stringWithNSTimeInterval:[((NSNumber*)[project valueForKeyPath:@"childIssues.@sum.childLogEntries.@sum.timeInterval"]) doubleValue]];
	[cell setNeedsLayout];
	
	return cell;
}

@end
