//
//  TTExternalSystemLinkDetailsVC.m
//  timetracker
//
//  Created by Florian Goessler on 27.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTExternalSystemLinkDetailsVC.h"
#import "TTAppDelegate.h"

@interface TTExternalSystemLinkDetailsVC () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTxtField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxtField;
@property (weak, nonatomic) IBOutlet UIPickerView *typeSpinner;

@end

@implementation TTExternalSystemLinkDetailsVC

- (IBAction)cancelBtnClicked:(id)sender {
	//reset all changes
	[((TTAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext rollback];
	
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)doneBtnClicked:(id)sender {
	//change data and save it
	self.externalSystemLink.username = self.usernameTxtField.text;
	self.externalSystemLink.password = self.passwordTxtField.text;
	self.externalSystemLink.type = [[[TTExternalSystemLink getAllSystemLinkTypes] allObjects] objectAtIndex:[self.typeSpinner selectedRowInComponent:0]];
	
	BOOL saved = [((TTAppDelegate*)[[UIApplication sharedApplication] delegate]) saveContextWithErrorHandler:^BOOL(NSError *err) {
		if([[err userInfo][@"NSValidationErrorKey"] isEqualToString:@"type"]) {
			//show a message to inform the user about the invalid type
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid data" message:@"The type you entered is invalid!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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

- (void)viewWillAppear:(BOOL)animated {
	self.typeSpinner.delegate = self;
	self.typeSpinner.dataSource = self;
	
	self.usernameTxtField.text = self.externalSystemLink.username;
	self.passwordTxtField.text = self.externalSystemLink.password;
	
	[self selectRowWithSysType:self.externalSystemLink.type inPickerView:self.typeSpinner];
}

#pragma mark PickerView

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [[TTExternalSystemLink getAllSystemLinkTypes] count];
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [[[TTExternalSystemLink getAllSystemLinkTypes] allObjects] objectAtIndex:row];
}
-(void)selectRowWithSysType:(NSString*)sysType inPickerView:(UIPickerView*)pickerView {
	NSInteger i = 0;
	for(NSString *type in [[TTExternalSystemLink getAllSystemLinkTypes] allObjects]) {
		if([type isEqualToString:sysType]) {
			[pickerView selectRow:i inComponent:0 animated:NO];
			break;
		}
		i++;
	}
}

@end
