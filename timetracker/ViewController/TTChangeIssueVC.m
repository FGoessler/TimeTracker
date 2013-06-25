//
//  TTChangeIssueVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTChangeIssueVC.h"
#import "TTIssueDataManager.h"

@interface TTChangeIssueVC () <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TTIssueDataManager *dataManager;
@end

@implementation TTChangeIssueVC

- (IBAction)addBtnClicked:(id)sender {
	//show an AlertView to let the user enter a name for the Issue.
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Issue" message:@"Please enter a name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
	alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alertView show];
}
- (IBAction)cancelBtnClicked:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex != 1) return;	//do nothing if cancel button clicked
	
	[self.project addIssueWithName:[alertView textFieldAtIndex:0].text andError:nil];
}

#pragma mark View Controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	//setup tableView
	self.tableView.dataSource = self;
	self.dataManager = [[TTIssueDataManager alloc] initWithProject:self.project AsDataSourceOfTableView:self.tableView];
}

@end
