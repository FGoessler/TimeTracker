//
//  TTIssueListVC.m
//  timetracker
//
//  Created by Florian Goessler on 29.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTIssueListVC.h"
#import "TTIssuesDataSource.h"
#import "TTIssueDetailsVC.h"

@interface TTIssueListVC () <UITableViewDelegate>
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) TTIssuesDataSource *dataSource;
@end

@implementation TTIssueListVC

- (IBAction)addBtnClicked:(id)sender {
	//show an AlertView to let the user enter a name for the Issue.
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Issue" message:@"Please enter a name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
	alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex != 1) return;    //do nothing if cancel button clicked

	[self.project addIssueWithName:[alertView textFieldAtIndex:0].text andError:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Show TTIssueDetailsVC3"]) {
		TTIssueDetailsVC *destVC = (TTIssueDetailsVC *) [segue.destinationViewController topViewController];
		//pass the selected issue to the TTIssueDetailsVC
		destVC.issue = [self.dataSource issueAtIndexPath:[self.tableView indexPathForSelectedRow]];
	}
}

#pragma mark View Controller lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

	//setup tableView
	self.tableView.delegate = self;
	self.dataSource = [[TTIssuesDataSource alloc] initWithProject:self.project asDataSourceOfTableView:self.tableView];

}

@end
