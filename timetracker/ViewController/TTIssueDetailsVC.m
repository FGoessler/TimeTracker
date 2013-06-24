//
//  TTIssueDetailsVC.m
//  timetracker
//
//  Created by Florian Goessler on 24.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTIssueDetailsVC.h"

@interface TTIssueDetailsVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;

@end

@implementation TTIssueDetailsVC
- (IBAction)doneBtnClicked:(id)sender {
	//dismiss this ViewController
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelBtnClicked:(id)sender {
	//dismiss this ViewController
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated {
	self.nameTextField.text = self.issue.name;
}

@end
