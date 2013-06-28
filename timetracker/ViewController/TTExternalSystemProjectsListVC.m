//
//  TTExternalSystemProjectsListVC.m
//  timetracker
//
//  Created by Florian Goessler on 27.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTExternalSystemProjectsListVC.h"
#import "TTExternalSystemInterface.h"

@interface TTExternalSystemProjectsListVC () <TTexternalSystemInterfaceDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) id<TTExternalSystemInterface> systemInterface;
@property (strong, nonatomic) NSArray *projects;
@end

@implementation TTExternalSystemProjectsListVC

-(void)loadProjectListFailed:(TTExternalSystemLink *)systemLink {
	NSLog(@"Failed loading project list...");
}

-(void)loadedProjectList:(NSArray *)projectList forStytemLink:(TTExternalSystemLink *)systemLink {
	NSLog(@"Loaded project list...");
	
	self.projects = projectList;
	
	[self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.projects = @[];
	
	self.systemInterface = [TTExternalSystemLink externalSystemInterfaceForType:self.externalSystemLink.type];
	[self.systemInterface setDelegate:self];
	[self.systemInterface loadProjectListForSystemLink:self.externalSystemLink];
}

#pragma mark Table View DataSource/Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.projects count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectsCell"];
	
	cell.textLabel.text = ((TTExternalProject*)self.projects[indexPath.row]).name;
	
	return cell;
}


@end
