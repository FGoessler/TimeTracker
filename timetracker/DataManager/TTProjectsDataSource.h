//
//  TTProjectDataManager.h
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTProjectsDataSource : NSObject <UITableViewDataSource>

//Returns the project, which is displayed at the given IndexPath.
- (TTProject *)projectAtIndexPath:(NSIndexPath *)indexPath;


//Initializes this object as a DataSource for a TableView. The TableView will be updated when the data changes.
- (id)initAsDataSourceOfTableView:(UITableView *)tableView;

@end
