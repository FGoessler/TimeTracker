//
//  TTIssueDetailsVC.m
//  timetracker
//
//  Created by Florian Goessler on 24.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTIssueDetailsVC.h"
#import "TTLogEntriesDataSource.h"

@interface TTIssueDetailsVC ()
@property (weak, nonatomic) UITextField *nameTextField;
@property (weak, nonatomic) UITextView *descriptionTextField;
@property (weak, nonatomic) UILabel *syncStatusLbl;
@property (weak, nonatomic) UILabel *timeSpentLbl;

@property(nonatomic, strong) TTLogEntriesDataSource *logEntriesDataSource;
@end

@implementation TTIssueDetailsVC
- (IBAction)doneBtnClicked:(id)sender {
	//do not allow editing when the issue is loaded from remote system - upload not yet implemented!
	if(self.issue.externalSystemUID) {
		[[[UIAlertView alloc] initWithTitle:@"Action not allowed!" message:@"You cannot change issues that are synced with an external system! Please wait for a later version of the app which might support this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
		return;
	}	
	
	self.issue.name = self.nameTextField.text;
	self.issue.shortText = self.descriptionTextField.text;
	
	BOOL saved = [[TTCoreDataManager defaultManager] saveContextWithErrorHandler:^BOOL(NSError *err) {
		NSDictionary *errInfo = [err userInfo];
		if(errInfo[@"NSDetailedErrors"] != nil) {	//if multiple errors occurred only report the first one
			errInfo = [errInfo[@"NSDetailedErrors"][0] userInfo];
		}
		
		NSString *msg = nil;
		if([errInfo[@"NSValidationErrorKey"] isEqualToString:@"name"]) {
			msg = @"The name you entered for the issue is invalid!";
		} else if([errInfo[@"NSValidationErrorKey"] isEqualToString:@"shortText"]) {
			msg = @"The description you entered for the issue invalid!";
		}
		
		if(msg != nil) {
			//show a message to inform the user about the invalid data
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid data" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alertView show];
			
			return true;	//the error could be handled - do not crash the app!
		} else {
			return false;	//another error occurred - let the default routine handle this (most likely it crashes the app)
		}
	}];
	
	//dismiss this ViewController if data was saved
	if(saved) {
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}
- (IBAction)cancelBtnClicked:(id)sender {
	//reset all changes
	[[TTCoreDataManager defaultManager].managedObjectContext rollback];
	
	//dismiss this ViewController
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.logEntriesDataSource = [[TTLogEntriesDataSource alloc] initWithIssue:self.issue asDataSourceOfTableView:self.tableView];
	[self.logEntriesDataSource restrictToSection:2 andSetSecondHandDataSource:self];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section){
		case 0:
			return 3;
		case 1:
			return 1;
		default:
			return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1 && indexPath.row == 0) {
		return 122.0;
	} else {
		return [super tableView:tableView heightForRowAtIndexPath:indexPath];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section) {
		case 1:
			return @"Description";
		case 2:
			return @"Time Logged";
		default:
			return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;

	if(indexPath.row == 0 && indexPath.section == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"IssueNameCell"];
		self.nameTextField = [[[cell.subviews objectAtIndex:0] subviews] objectAtIndex:0];
		self.nameTextField.text = self.issue.name;
	} else if(indexPath.row == 1 && indexPath.section == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"CenteredTextCell"];
		self.timeSpentLbl = [[[cell.subviews objectAtIndex:0] subviews] objectAtIndex:0];
		self.timeSpentLbl.text = [NSString stringWithNSTimeInterval:[((NSNumber*)[self.issue valueForKeyPath:@"childLogEntries.@sum.timeInterval"]) doubleValue]];
	} else if(indexPath.row == 2 && indexPath.section == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"CenteredTextCell"];
		self.syncStatusLbl = [[[cell.subviews objectAtIndex:0] subviews] objectAtIndex:0];
		if(self.issue.externalSystemUID != nil) {
			self.syncStatusLbl.text = @"synced with external system";
		} else {
			self.syncStatusLbl.text = @"not synced";
		}
	} else if(indexPath.row == 0 && indexPath.section == 1) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"LargeTextCell"];
		self.descriptionTextField = [[[cell.subviews objectAtIndex:0] subviews] objectAtIndex:0];
		self.descriptionTextField.text = self.issue.shortText;
	}

	return cell;
}

@end
