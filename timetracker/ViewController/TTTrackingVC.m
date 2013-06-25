//
//  TTTrackingVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTTrackingVC.h"
#import "TTProject+TTExtension.h"
#import "TTAppDelegate.h"
#import "TTProjectDataManager.h"
#import "TTTrackingVC.h"
#import "TTProjectSettingsVC.h"
#import "TTChangeIssueVC.h"
#import "TTLogEntryDataManager.h"
#import "TTLogEntryDetailsVC.h"
#import "TTIssueDetailsVC.h"




@interface TTTrackingVC ()
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *currentIssueLbl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *trackingBtn;

@property (strong, nonatomic) NSTimer *pollingTimer;

@property (strong, nonatomic) TTLogEntryDataManager *dataManager;
@end

@implementation TTTrackingVC

-(void)setProject:(TTProject *)project {
	_project = project;
	self.currentIssue = self.project.currentIssue;
}
-(void)setCurrentIssue:(TTIssue *)currentIssue {
	_currentIssue = currentIssue;
	self.dataManager = [[TTLogEntryDataManager alloc] initWithIssue:_currentIssue asDataSourceOfTableView:self.tableView];
}

- (IBAction)trackingBtnClicked:(id)sender {
	NSError *err = nil;
	if(self.currentIssue.latestLogEntry != nil && self.currentIssue.latestLogEntry.endDate == nil) {
		//stop tracking if still running
		[self.currentIssue stopTracking:&err];
	} else {
		//start new tracking otherwise
		[self.currentIssue startTracking:&err];
	}

	if(err != nil) {
		NSLog(@"FEHLER! %@", err);	//TODO!
	}
	
	[self updateViews];
}

//This method updates all views.
-(void)updateViews {	
	self.currentIssueLbl.text = [NSString stringWithFormat:@"Current Issue: %@", self.currentIssue.name];	//Show the name of the current issue
		
	self.timeLbl.text = [NSString stringWithNSTimeInterval:self.currentIssue.latestLogEntry.timeInterval];	//Show the elapsed time
		
	//configure the trackingBtn and start/stop view update timer
	if(self.currentIssue.latestLogEntry != nil && self.currentIssue.latestLogEntry.endDate == nil) {
		[self.trackingBtn setTitle:@"Stop Tracking" forState:UIControlStateNormal];
		self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateViews) userInfo:nil repeats:YES];
	} else {
		[self.pollingTimer invalidate];
		[self.trackingBtn setTitle:@"Start Tracking" forState:UIControlStateNormal];
		self.timeLbl.text = @"00:00:00";
	}
	
	[self.tableView reloadData];	//update the tableView
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self performSegueWithIdentifier:@"Show TTLogEntryDetailsVC" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([segue.identifier isEqualToString:@"Show TTLogEntryDetailsVC"]) {
		TTLogEntryDetailsVC *destVC = (TTLogEntryDetailsVC*)[segue.destinationViewController topViewController];
		destVC.logEntry = [self.dataManager logEntryAtIndexPath:[self.tableView indexPathForSelectedRow]];
	} else if([segue.identifier isEqualToString:@"Show TTIssueDetailsVC"]) {
		TTIssueDetailsVC *destVC = (TTIssueDetailsVC*)[segue.destinationViewController topViewController];
		destVC.issue = self.currentIssue;
	} else if([segue.identifier isEqualToString:@"Show TTChangeIssueVC"]) {
		TTChangeIssueVC *destVC = (TTChangeIssueVC*)[segue.destinationViewController topViewController];
		//pass the selected project to the ChangeIssueVC
		destVC.parentVC = self;
	}
}

-(void)viewDidLoad {
	[super viewDidLoad];
	
	//configure the tableView
	self.tableView.delegate = self;
	self.dataManager = [[TTLogEntryDataManager alloc] initWithIssue:self.currentIssue asDataSourceOfTableView:self.tableView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[self updateViews];
}

-(void)viewWillDisappear:(BOOL)animated {
	[self.pollingTimer invalidate];		//stop the timer when view disappears - don't waste computation time! 
}

@end
