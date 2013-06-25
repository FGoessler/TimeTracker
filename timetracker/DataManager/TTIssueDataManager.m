//
//  TTIssueDataManager.m
//  timetracker
//
//  Created by Rainforce Fifteen on 25/06/2013.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTIssueDataManager.h"
#import "TTAppDelegate.h"

@interface TTIssueDataManager()  <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) UITableView* tableView;
@end

@implementation TTIssueDataManager

@end
