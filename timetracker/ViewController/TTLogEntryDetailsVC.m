//
//  TTLogEntryDetailsVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTLogEntryDetailsVC.h"

@interface TTLogEntryDetailsVC ()
@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;
@property (weak, nonatomic) IBOutlet UITextView *commentTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@end

@implementation TTLogEntryDetailsVC
- (IBAction)doneBtnClicked:(id)sender {
	//dismiss this ViewController
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelBtnClicked:(id)sender {
	//dismiss this ViewController
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
