//
//  TTExternalSystemLinkDeatilsVCViewController.m
//  timetracker
//
//  Created by Florian Goessler on 27.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTExternalSystemLinkDeatilsVC.h"

@interface TTExternalSystemLinkDeatilsVC ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTxtField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxtField;
@property (weak, nonatomic) IBOutlet UIPickerView *typeSpinner;

@end

@implementation TTExternalSystemLinkDeatilsVC

- (IBAction)cancelBtnClicked:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)doneBtnClicked:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
