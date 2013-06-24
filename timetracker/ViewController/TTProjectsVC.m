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
#import "TTTrackingVC.h"
#import "TTProjectSettingsVC.h"


@interface TTProjectsVC () <UITableViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) TTProjectDataManager *projectManager;

@property (nonatomic, strong) TTProject* selectedProject;
@end

@implementation TTProjectsVC

- (IBAction)newProjectBtnClicked:(id)sender {
	//show an AlertView to let the user enter a name for the project.
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Project" message:@"Please enter a name for your awesome new project!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
	alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	[alertView show];

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex != 1) return;	//do nothing if cancel button clicked
	
	[self.projectManager createNewProjectWithName:[alertView textFieldAtIndex:0].text];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self performSegueWithIdentifier:@"Show TTTrackingVC" sender:self];		//show TrackingVC
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	self.selectedProject = [self.projectManager projectAtIndexPath:indexPath];
	[self performSegueWithIdentifier:@"Show TTProjectSettingsVC" sender:self];		//show ProjectSettingsVC
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([segue.identifier isEqualToString:@"Show TTTrackingVC"]) {
		TTTrackingVC *destVC = segue.destinationViewController;
		//pass the selected project to the TrackingVC
		destVC.project = [self.projectManager projectAtIndexPath:[self.tableView indexPathForSelectedRow]];
	} else if([segue.identifier isEqualToString:@"Show TTProjectSettingsVC"]) {
		TTProjectSettingsVC *destVC = (TTProjectSettingsVC*)[segue.destinationViewController topViewController];
		//pass the selected project to the ProjectSettingsVC
		destVC.project = self.selectedProject;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//configure TableView
	self.tableView.delegate = self;
	self.projectManager = [[TTProjectDataManager alloc] initAsDataSourceOfTableView:self.tableView];
}


@end
