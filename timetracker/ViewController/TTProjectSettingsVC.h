//
//  TTProjectSettingsVC.h
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTProject+TTExtension.h"

@interface TTProjectSettingsVC : UITableViewController
@property (nonatomic, strong) TTProject* project;
@end
