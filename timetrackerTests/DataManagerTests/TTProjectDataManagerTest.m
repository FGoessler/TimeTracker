//
//  TTProjectDataManagerTest.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTProjectDataManagerTest.h"
#import "TTProjectsDataSource.h"
#import "TTProject+TTExtension.h"

@implementation TTProjectDataManagerTest {
	TTProjectsDataSource *projectManager;
}

- (void)setUp
{
    [super setUp];
    
	projectManager = [[TTProjectsDataSource alloc] init];
}

- (void)tearDown
{
    projectManager = nil;
    
    [super tearDown];
}

- (void)testToCreateANewProject
{	
	[projectManager createNewProjectWithName:@"Testproject"];
	
	NSError *err;
	NSFetchRequest *projectsRequest = [[NSFetchRequest alloc] initWithEntityName:MOBJ_TTProject];
	NSArray *projects = [self.managedObjectContext executeFetchRequest:projectsRequest error:&err];
	
	STAssertNil(err, @"Error while perfoming a fetch request!");
	STAssertTrue(projects.count == 1, @"There should be exactly one project after creating one!");
	STAssertEqualObjects(((TTProject*)projects[0]).name, @"Testproject", @"Project should have the right name");
	STAssertNotNil(((TTProject*)projects[0]).defaultIssue, @"Project should have a default issue");
}


- (void)testThatItImplementsTheRightProtocols
{
    STAssertTrue([TTProjectsDataSource conformsToProtocol:@protocol(UITableViewDataSource)], @"Should conform to UITableViewDataSource protocol!");
	 STAssertTrue([TTProjectsDataSource conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)], @"Should conform to NSFetchedResultsControllerDelegate protocol!");
}

- (void)testToInitItWithATableView
{
	UITableView *tableView = [[UITableView alloc] init];
	
	projectManager = [[TTProjectsDataSource alloc] initAsDataSourceOfTableView:tableView];
	
	STAssertEqualObjects(tableView.dataSource, projectManager, @"Should have set the DataSource on the TableView");
}

- (void)testThatItProvidesRowsForTheContent
{
	//TODO STFail(@"unimplemented test!");
}

- (void)testThatItSupportsDeletingProjects
{
	//TODO STFail(@"unimplemented test!");
}

- (void)testToDeleteAProject
{
	//TODO STFail(@"unimplemented test!");
}


@end
