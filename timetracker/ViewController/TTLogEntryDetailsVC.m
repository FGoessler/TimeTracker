//
//  TTLogEntryDetailsVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTLogEntryDetailsVC.h"

@interface TTLogEntryDetailsVC () <UITextViewDelegate>
@property(weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property(weak, nonatomic) IBOutlet UITextField *endTimeTextField;
@property(weak, nonatomic) IBOutlet UITextView *commentTextField;
@property(weak, nonatomic) IBOutlet UIDatePicker *startPicker;
@property(weak, nonatomic) IBOutlet UIDatePicker *endPicker;

@property(weak, nonatomic) UITextField *currentTxtField;
@end

#pragma mark Navigation Bar Buttons

@implementation TTLogEntryDetailsVC
- (IBAction)doneBtnClicked:(id)sender {
	self.logEntry.comment = self.commentTextField.text;

	BOOL saved = [[TTCoreDataManager defaultManager] saveContextWithErrorHandler:^BOOL(NSError *err) {
		NSDictionary *errInfo = [err userInfo];
		if (errInfo[@"NSDetailedErrors"] != nil) {    //if multiple errors occurred only report the first one
			errInfo = [errInfo[@"NSDetailedErrors"][0] userInfo];
		}

		NSString *msg = nil;
		if ([errInfo[@"NSValidationErrorKey"] isEqualToString:@"startDate"]) {
			msg = @"The start date you entered is invalid!";
		} else if ([errInfo[@"NSValidationErrorKey"] isEqualToString:@"endDate"]) {
			msg = @"The end date you entered is invalid!";
		} else if ([errInfo[@"NSValidationErrorKey"] isEqualToString:@"comment"]) {
			msg = @"The comment you entered is invalid!";
		}

		if (msg != nil) {
			//show a message to inform the user about the invalid data
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid data" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];

			return true;    //the error could be handled - do not crash the app!
		} else {
			return false;    //another error occurred - let the default routine handle this (most likely it crashes the app)
		}
	}];

	//dismiss this ViewController if data was saved
	if (saved) {
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

- (IBAction)cancelBtnClicked:(id)sender {
	//reset all changes
	[[TTCoreDataManager defaultManager].managedObjectContext rollback];

	//dismiss this ViewController
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Time Text Fields

- (IBAction)timeTxtFieldTapped:(id)sender {
	self.currentTxtField = sender;
	[self.currentTxtField resignFirstResponder];


	//self.timePicker.hidden = NO;

	UIDatePicker *picker;
	if (self.currentTxtField == self.startTimeTextField && self.logEntry.startDate != nil) {
		picker = self.startPicker;
		picker.date = self.logEntry.startDate;
	} else if (self.currentTxtField == self.endTimeTextField && self.logEntry.endDate != nil) {
		picker = self.startPicker;
		picker.date = self.logEntry.endDate;
	}
}

- (IBAction)startPickerChanged:(id)sender {
	self.logEntry.startDate = self.startPicker.date;
}

- (IBAction)endPickerChanged:(id)sender {
	self.logEntry.endDate = self.endPicker.date;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self.startTimeTextField resignFirstResponder];
	[self.endTimeTextField resignFirstResponder];
	[self.commentTextField resignFirstResponder];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"startDate"] && object == self.logEntry) {
		self.startTimeTextField.text = [NSString stringWithNSDate:self.logEntry.startDate];
	} else if ([keyPath isEqualToString:@"endDate"] && object == self.logEntry) {
		if (self.logEntry.endDate) {
			self.endTimeTextField.text = [NSString stringWithNSDate:self.logEntry.endDate];
		} else {
			self.endTimeTextField.text = @"now";
		}
	}
}

#pragma mark ViewController Lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];


	self.startTimeTextField.text = [NSString stringWithNSDate:self.logEntry.startDate];
	if (self.logEntry.endDate) {
		self.endTimeTextField.text = [NSString stringWithNSDate:self.logEntry.endDate];
	} else {
		self.endTimeTextField.text = @"now";
	}

	[self.logEntry addObserver:self forKeyPath:@"startDate" options:0 context:nil];
	[self.logEntry addObserver:self forKeyPath:@"endDate" options:0 context:nil];

	self.commentTextField.text = self.logEntry.comment;
	self.commentTextField.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.logEntry removeObserver:self forKeyPath:@"startDate"];
	[self.logEntry removeObserver:self forKeyPath:@"endDate"];
}

@end
