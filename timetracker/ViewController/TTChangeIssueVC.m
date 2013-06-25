//
//  TTChangeIssueVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTChangeIssueVC.h"
#import "TTProjectsVC.h"
#import "TTProject+TTExtension.h"
#import "TTAppDelegate.h"
#import "TTProjectDataManager.h"
#import "TTTrackingVC.h"
#import "TTProjectSettingsVC.h"

@interface TTChangeIssueVC () <UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;


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

/*- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex != 1) return;	//do nothing if cancel button clicked
	[self.project createNewProjectWithName:[alertView textFieldAtIndex:0].text];
}*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(TTIssue*)IssueAtIndexPath:(NSIndexPath*)indexPath {
	return self.project.childIssues.allObjects[indexPath.row];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.project.childIssues.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackingCell"];
	
	//configure cell
	TTIssue *currentIssue = [self IssueAtIndexPath:indexPath];
	cell.textLabel.text = currentIssue.name;
	return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.tableView.delegate = self;
	if (self.project.childIssues.count == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ZERO." message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
		alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
		[alertView show];
	}
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
