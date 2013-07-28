//
//  TTTrackingVC.h
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTTrackingVC : UIViewController <UITableViewDelegate>
@property(nonatomic, strong) TTProject *project;
@property(nonatomic, strong) TTIssue *currentIssue;

@end
