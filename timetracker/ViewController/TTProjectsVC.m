//
//  TTProjectsVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTProjectsVC.h"
#import "TTProjectsDataSource.h"
#import "TTTrackingVC.h"
#import "TTMessageOverlay.h"
#import "TTProjectSettingsVC.h"


@interface TTProjectsVC () <UITableViewDelegate, UIAlertViewDelegate>
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *addBtn;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *externalLinksBtn;

@property(strong, nonatomic) TTProjectsDataSource *dataSource;
@property(nonatomic, strong) TTProject *selectedProject;

@property(nonatomic, strong) TTMessageOverlay *messageOverlay;
@end

@implementation TTProjectsVC

- (IBAction)newProjectBtnClicked:(id)sender {
	//show an AlertView to let the user enter a name for the project.
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Project" message:@"Please enter a name for your awesome new project!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
	alertView.alertViewStyle = UIAlertViewStylePlainTextInput;

	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex != 1) return;    //do nothing if cancel button clicked

	[TTProject createNewProjectWithName:[alertView textFieldAtIndex:0].text];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self performSegueWithIdentifier:@"Show TTTrackingVC" sender:self];        //show TrackingVC
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	self.selectedProject = [self.dataSource projectAtIndexPath:indexPath];
	[self performSegueWithIdentifier:@"Show TTProjectSettingsVC" sender:self];        //show ProjectSettingsVC
}

- (void)showICloudMessage {
	self.messageOverlay = [TTMessageOverlay showLoadingOverlayInViewController:self withMessage:@"Initiating Data Store."];
	[self.addBtn setEnabled:NO];
	[self.externalLinksBtn setEnabled:NO];

	[self.tableView reloadData];
}

- (void)hideICloudMessage:(NSNotification *)notification {
	if (self.messageOverlay) {
		[self.messageOverlay hide];
	}
	[self.addBtn setEnabled:YES];
	[self.externalLinksBtn setEnabled:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Show TTTrackingVC"]) {
		TTTrackingVC *destVC = segue.destinationViewController;
		//pass the selected project to the TrackingVC
		destVC.project = [self.dataSource projectAtIndexPath:[self.tableView indexPathForSelectedRow]];
	} else if ([segue.identifier isEqualToString:@"Show TTProjectSettingsVC"]) {
		TTProjectSettingsVC *destVC = (TTProjectSettingsVC *) [segue.destinationViewController topViewController];
		//pass the selected project to the ProjectSettingsVC
		destVC.project = self.selectedProject;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	//configure TableView
	self.tableView.delegate = self;
	self.dataSource = [[TTProjectsDataSource alloc] initAsDataSourceOfTableView:self.tableView];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideICloudMessage:) name:TT_MODEL_CHANGED_NOTIFICATION object:nil];

	[self showICloudMessage];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
