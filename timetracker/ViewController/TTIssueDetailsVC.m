//
//  TTIssueDetailsVC.m
//  timetracker
//
//  Created by Florian Goessler on 24.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTIssueDetailsVC.h"
#import "TTAppDelegate.h"

@interface TTIssueDetailsVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;

@end

@implementation TTIssueDetailsVC
- (IBAction)doneBtnClicked:(id)sender {
	self.issue.name = self.nameTextField.text;
	
	BOOL saved = [((TTAppDelegate*)[[UIApplication sharedApplication] delegate]) saveContextWithErrorHandler:^BOOL(NSError *err) {
		NSDictionary *errInfo = [err userInfo];
		if(errInfo[@"NSDetailedErrors"] != nil) {
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
			return false;	//another error occured - let the default routine handle this (most likly it crashes the app)
		}
	}];
	
	//dismiss this ViewController if data was saved
	if(saved) {
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}
- (IBAction)cancelBtnClicked:(id)sender {
	//reset all changes
	[((TTAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext rollback];
	
	//dismiss this ViewController
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated {
	self.nameTextField.text = self.issue.name;
	self.descriptionTextField.text = self.issue.shortText;
}

@end
