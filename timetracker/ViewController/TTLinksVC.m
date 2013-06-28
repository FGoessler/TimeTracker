//
//  TTLinksVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTLinksVC.h"
#import "TTExternalSystemLinksDataSource.h"
#import "TTExternalSystemLinkDetailsVC.h"
#import "TTExternalSystemProjectsListVC.h"

@interface TTLinksVC () <UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TTExternalSystemLinksDataSource *dataSource;
@property (strong, nonatomic) TTExternalSystemLink *selectedExternalSystemLink;
@end

@implementation TTLinksVC

- (IBAction)addLinkBtnClicked:(id)sender {
	[TTExternalSystemLink createNewExternalSystemLinkOfType:TT_SYS_TYPE_GITHUB];
}

-(void)cancelBtnClicked {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	self.selectedExternalSystemLink = [self.dataSource systemLinkAtIndexPath:indexPath];
	[self performSegueWithIdentifier:@"Show TTExternalSystemLinkDetailsVC" sender:self];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([self.dataSource systemLinkAtIndexPath:indexPath].username != nil) {
		[self performSegueWithIdentifier:@"Show TTExternalSystemProjectsListVC" sender:self];
	} else {
		[[[UIAlertView alloc] initWithTitle:@"No data!" message:@"You haven't specified a username for this system!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([segue.identifier isEqualToString:@"Show TTExternalSystemLinkDetailsVC"]) {
		TTExternalSystemLinkDetailsVC *destVC = (TTExternalSystemLinkDetailsVC*)[segue.destinationViewController topViewController];
		destVC.externalSystemLink = self.selectedExternalSystemLink;
	} else if([segue.identifier isEqualToString:@"Show TTExternalSystemProjectsListVC"]) {
		TTExternalSystemProjectsListVC *destVC = (TTExternalSystemProjectsListVC*)segue.destinationViewController;
		destVC.externalSystemLink = [self.dataSource systemLinkAtIndexPath:[self.tableView indexPathForSelectedRow]];
		
		//if this VC is presented to let the user pick a project to sync with, modify the ExternalSystemProjectsListVC and save selections 
		if(self.projectToSelectLinkFor != nil) {
			destVC.navigationItem.prompt = @"Select the project that should be synced with the app.";
			[destVC setHandlerForRowSelecting:^(UITableView *tableView, NSIndexPath *indexPath) {
				self.projectToSelectLinkFor.parentSystemLink = [self.dataSource systemLinkAtIndexPath:[self.tableView indexPathForSelectedRow]];
			}];
		}
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tableView.delegate = self;
	self.dataSource = [[TTExternalSystemLinksDataSource alloc] initAsDataSourceOfTableView:self.tableView];
	
	//if this VC is presented to let the user pick a project to sync with, modify this VC (add prompt and cancel button)
	if(self.projectToSelectLinkFor != nil) {
		self.navigationItem.prompt = @"Select a system you want to sync your project with.";
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnClicked)];
	}
}

@end
