//
//  TTChangeIssueVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTChangeIssueVC.h"
#import "TTProjectsVC.h"
#import "TTProject+TTExtension.h"
#import "TTAppDelegate.h"
#import "TTProjectDataManager.h"
#import "TTTrackingVC.h"
#import "TTProjectSettingsVC.h"

@interface TTChangeIssueVC () <UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation TTChangeIssueVC
- (IBAction)addBtnClicked:(id)sender {
}
- (IBAction)cancelBtnClicked:(id)sender {
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
	
	self.tableView.delegate = self;
	//self.tableView.dataSource = self.project.childIssues;
	
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
