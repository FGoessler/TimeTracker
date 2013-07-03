//
//  TTExternalSystemProjectsListVC.m
//  timetracker
//
//  Created by Florian Goessler on 27.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTExternalSystemProjectsListVC.h"
#import "TTExternalSystemInterface.h"
#import "TTMessageOverlay.h"

@interface TTExternalSystemProjectsListVC () <TTexternalSystemInterfaceDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TTMessageOverlay *messageOverlay;
@property (strong, nonatomic) id<TTExternalSystemInterface> systemInterface;
@property (strong, nonatomic) NSArray *projects;
@end

@implementation TTExternalSystemProjectsListVC {
	TTRowSelectedHandler _handlerForRowSelection;
}

-(void)setHandlerForRowSelecting:(TTRowSelectedHandler)handler {
	_handlerForRowSelection = handler;
}

-(void)loadProjectListFailed:(TTExternalSystemLink *)systemLink {
	[self.messageOverlay hide];
	self.messageOverlay = [TTMessageOverlay showMessageOverlayInViewController:self withMessage:@"Error while loading data!" forTime:5];
}

-(void)loadedProjectList:(NSArray *)projectList forSystemLink:(TTExternalSystemLink *)systemLink {
	NSLog(@"Loaded project list...");
	
	self.projects = projectList;
	
	[self.tableView reloadData];
	[self.messageOverlay hide];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.projects = @[];
	
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
	self.messageOverlay = [TTMessageOverlay showLoadingOverlayInViewController:self];
	
	self.systemInterface = [TTExternalSystemLink externalSystemInterfaceForType:self.externalSystemLink.type];
	[self.systemInterface setDelegate:self];
	[self.systemInterface loadProjectListForSystemLink:self.externalSystemLink];

}

#pragma mark Table View DataSource/Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.projects count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemoteProjectCell"];
	
	cell.textLabel.text = ((TTExternalProject*)self.projects[indexPath.row]).name;
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	_handlerForRowSelection(tableView, indexPath, self.projects[indexPath.row]);
}


@end
