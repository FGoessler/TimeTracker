//
//  TTExternalSystemProjectsListVC.h
//  timetracker
//
//  Created by Florian Goessler on 27.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TTRowSelectedHandler)(UITableView *tableView, NSIndexPath *selectedIndexPath, TTExternalProject *selectedProject);

@interface TTExternalSystemProjectsListVC : UIViewController
@property(nonatomic, strong) TTExternalSystemLink *externalSystemLink;

- (void)setHandlerForRowSelecting:(TTRowSelectedHandler)handler;
@end
