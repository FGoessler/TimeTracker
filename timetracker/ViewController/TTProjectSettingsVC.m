//
//  TTProjectSettingsVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTProjectSettingsVC.h"
#import "TTAppDelegate.h"

@interface TTProjectSettingsVC ()
@property (weak, nonatomic) IBOutlet UITextField *projectNameTextField;

@end

@implementation TTProjectSettingsVC

- (IBAction)doneBtnClicked:(id)sender {	
	//change data and save it
	self.project.name = self.projectNameTextField.text;
	
	BOOL saved = [((TTAppDelegate*)[[UIApplication sharedApplication] delegate]) saveContextWithErrorHandler:^BOOL(NSError *err) {
		if([[err userInfo][@"NSValidationErrorKey"] isEqualToString:@"name"]) {
			//show a message to inform the user about the invalid name
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid data" message:@"The name you entered for the project is invalid!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alertView show];
			
			return true;	//the error could be handled - do not crash the app!
		}
		return false;	//another error occurred - let the default routine handle this (most likely it crashes the app)
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	self.projectNameTextField.text = self.project.name;
}

@end
