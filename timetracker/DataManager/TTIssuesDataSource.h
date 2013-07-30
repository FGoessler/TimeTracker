//
//  TTIssueDataManager.h
//  timetracker
//
//  Created by Rainforce Fifteen on 25/06/2013.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTIssuesDataSource : NSObject <UITableViewDataSource>

//Returns the issue, which is displayed at the given IndexPath.
- (TTIssue *)issueAtIndexPath:(NSIndexPath *)indexPath;

//Initializes this object as a DataSource for a TableView. The TableView will be updated when the data changes.
- (id)initWithProject:(TTProject *)project asDataSourceOfTableView:(UITableView *)tableView;

@end
