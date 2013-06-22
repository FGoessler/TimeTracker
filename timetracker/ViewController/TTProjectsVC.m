//
//  TTProjectsVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTProjectsVC.h"
#import "TTProject+TTExtension.h"
#import "TTAppDelegate.h"
#import "TTProjectDataManager.h"


@interface TTProjectsVC () <UITableViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) TTProjectDataManager *projectManager;

@end

@implementation TTProjectsVC

- (IBAction)newProjectBtnClicked:(id)sender {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Project" message:@"Please enter a name for your awesome new project!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
	alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	[alertView show];

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	if(buttonIndex != 1) return;
	
	[self.projectManager createNewProjectWithName:[alertView textFieldAtIndex:0].text];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	
	self.tableView.delegate = self;
	self.projectManager = [[TTProjectDataManager alloc] initAsDataSourceOfTableView:self.tableView];
	
}


@end
