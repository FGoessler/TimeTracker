//
//  TTTrackingVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTTrackingVC.h"
#import "TTChangeIssueVC.h"
#import "TTLogEntriesDataSource.h"
#import "TTLogEntryDetailsVC.h"
#import "TTIssueDetailsVC.h"

@interface TTTrackingVC ()
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *currentIssueLbl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *trackingBtn;
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (strong, nonatomic) NSTimer *pollingTimer;

@property (strong, nonatomic) TTLogEntriesDataSource *dataSource;
@end

@implementation TTTrackingVC
@synthesize currentIssue = _currentIssue;

-(void)setProject:(TTProject *)project {
	_project = project;
	self.currentIssue = self.project.currentIssue;
}

-(TTIssue*)currentIssue {
	if(_currentIssue == nil || _currentIssue.name == nil) {
		_currentIssue = self.project.currentIssue;
	}
	return _currentIssue;
}
-(void)setCurrentIssue:(TTIssue *)currentIssue {
	_currentIssue = currentIssue;
	self.dataSource = [[TTLogEntriesDataSource alloc] initWithIssue:_currentIssue asDataSourceOfTableView:self.tableView];
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
	
	
	[[TTExternalSystemLink externalSystemInterfaceForType:self.project.parentSystemLink.type] syncTimelogEntriesOfIssues:self.currentIssue];
	
	[self updateViews];
}

-(void)newTimelogEntryBtnClicked {
	[self performSegueWithIdentifier:@"Show TTLogEntryDetailsVC for new TTLogEntry" sender:self];
}

//This method updates all views.
-(void)updateViews {	
	self.currentIssueLbl.text = [NSString stringWithFormat:@"Current Issue: %@", self.currentIssue.name];	//Show the name of the current issue
		
	self.timeLbl.text = [NSString stringWithNSTimeInterval:self.currentIssue.latestLogEntry.timeInterval];	//Show the elapsed time
		
	//configure the trackingBtn and start/stop view update timer
	if(self.currentIssue.latestLogEntry != nil && self.currentIssue.latestLogEntry.endDate == nil) {
		[self.trackingBtn setTitle:@"Stop Tracking" forState:UIControlStateNormal];
	} else {
		[self.trackingBtn setTitle:@"Start Tracking" forState:UIControlStateNormal];
		self.timeLbl.text = @"00:00:00";
	}
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self performSegueWithIdentifier:@"Show TTLogEntryDetailsVC" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([segue.identifier isEqualToString:@"Show TTLogEntryDetailsVC"]) {
		TTLogEntryDetailsVC *destVC = (TTLogEntryDetailsVC*)[segue.destinationViewController topViewController];
		destVC.logEntry = [self.dataSource logEntryAtIndexPath:[self.tableView indexPathForSelectedRow]];
	} else if([segue.identifier isEqualToString:@"Show TTLogEntryDetailsVC for new TTLogEntry"]) {
		TTLogEntryDetailsVC *destVC = (TTLogEntryDetailsVC*)[segue.destinationViewController topViewController];
		destVC.logEntry = [self.currentIssue createNewUnsavedLogEntry];
		destVC.logEntry.startDate = [NSDate date];
		destVC.logEntry.endDate = [NSDate date];
	} else if([segue.identifier isEqualToString:@"Show TTIssueDetailsVC"]) {
		TTIssueDetailsVC *destVC = (TTIssueDetailsVC*)[segue.destinationViewController topViewController];
		destVC.issue = self.currentIssue;
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
	self.dataSource = [[TTLogEntriesDataSource alloc] initWithIssue:self.currentIssue asDataSourceOfTableView:self.tableView];
	
	self.tableView.tableHeaderView = [[UILabel alloc] init];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[self configureTableHeaderView];
	
	[self updateViews];
	
	self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateViews) userInfo:nil repeats:YES];
	
	self.topView.layer.shadowOffset = CGSizeMake(0, 5);
	self.topView.layer.shadowRadius = 5;
	self.topView.layer.shadowOpacity = 0.5;
}

-(void)viewWillDisappear:(BOOL)animated {
	[self.pollingTimer invalidate];		//stop the timer when view disappears - don't waste computation time! 
}


-(void)configureTableHeaderView {
	UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	container.layer.borderWidth = 1.0;
	container.layer.borderColor = [[UIColor lightGrayColor] CGColor];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
	label.text = @"Create a new Log Entry...";
	label.translatesAutoresizingMaskIntoConstraints = NO;
	UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
	button.translatesAutoresizingMaskIntoConstraints = NO;
	
	[container addSubview:label];
	[container addSubview:button];
	
	self.tableView.tableHeaderView = container;
	
	[container addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
	[container addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

	
	[container addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0]];
	[container addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:10.0]];
	
	[button addTarget:self action:@selector(newTimelogEntryBtnClicked) forControlEvents:UIControlEventTouchUpInside];
}

@end
