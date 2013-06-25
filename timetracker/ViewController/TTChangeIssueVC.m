//
//  TTChangeIssueVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTChangeIssueVC.h"
#import "TTIssuesDataSource.h"
#import "TTIssueDetailsVC.h"

@interface TTChangeIssueVC () <UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TTIssuesDataSource *dataSource;
@property (strong, nonatomic) TTIssue *selectedIssue;
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
	
	[self.parentVC.project addIssueWithName:[alertView textFieldAtIndex:0].text andError:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TTIssue *issue = [self.dataSource issueAtIndexPath:indexPath];
	self.parentVC.currentIssue = issue;
	
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	self.selectedIssue = [self.dataSource issueAtIndexPath:indexPath];
	[self performSegueWithIdentifier:@"Show TTIssueDetailsVC2" sender:self];		//show TTIssueDetailsVC
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([segue.identifier isEqualToString:@"Show TTIssueDetailsVC2"]) {
		TTIssueDetailsVC *destVC = (TTIssueDetailsVC*)[segue.destinationViewController topViewController];
		//pass the selected issue to the TTIssueDetailsVC
		destVC.issue = self.selectedIssue;
	}
}

#pragma mark View Controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	//setup tableView
	self.tableView.delegate = self;
	self.dataSource = [[TTIssuesDataSource alloc] initWithProject:self.parentVC.project asDataSourceOfTableView:self.tableView];
}

@end
