//
//  TTTrackingVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTTrackingVC.h"
#import "TTIssue+TTExtension.h"
#import "TTLogEntries+TTExtension.h"


@interface TTTrackingVC ()
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *currentIssueLbl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *trackingBtn;

@property (strong, nonatomic) NSTimer *pollingTimer;
@end

@implementation TTTrackingVC

- (IBAction)changeIssueBtnClicked:(id)sender {
}

- (IBAction)trackingBtnClicked:(id)sender {
	NSError *err = nil;
	if(self.project.currentIssue.latestLogEntry != nil && self.project.currentIssue.latestLogEntry.endDate == nil) {
		//stop tracking if still running
		[self.project.currentIssue stopTracking:&err];
	} else {
		//start new tracking otherwise
		[self.project.currentIssue startTracking:&err];
	}

	if(err != nil) {
		NSLog(@"FEHLER! %@", err);
	}
	
	[self updateViews];
}

- (IBAction)moreInfoBtnClicked:(id)sender {
}

-(void)updateViews {
	TTIssue *currentIssue = self.project.currentIssue;
	
	self.currentIssueLbl.text = [NSString stringWithFormat:@"Current Issue: %@", currentIssue.name];
		
	self.timeLbl.text = [NSString stringWithNSTimeInterval:currentIssue.latestLogEntry.timeInterval];
		
	if(currentIssue.latestLogEntry != nil && currentIssue.latestLogEntry.endDate == nil) {
		[self.trackingBtn setTitle:@"Stop Tracking" forState:UIControlStateNormal];
		self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateViews) userInfo:nil repeats:YES];
	} else {
		[self.pollingTimer invalidate];
		[self.trackingBtn setTitle:@"Start Tracking" forState:UIControlStateNormal];
		self.timeLbl.text = @"00:00:00";
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[self updateViews];
}

-(void)viewWillDisappear:(BOOL)animated {
	[self.pollingTimer invalidate];
}

@end
