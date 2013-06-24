//
//  TTProjectDataManager.h
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTProject+TTExtension.h"

@interface TTProjectDataManager : NSObject
//Creates a new TTProject object with the given name and saves with the default ManagedObjectContext.
-(void)createNewProjectWithName:(NSString*)name;

@end

@interface TTProjectDataManager (DataSource) <UITableViewDataSource>

//Returns the project, which is displayed at the given IndexPath.
-(TTProject*)projectAtIndexPath:(NSIndexPath*)indexPath;
//Deletes the project, which is displayed at the given IndexPath.
-(void)deleteProjectAtIndexPath:(NSIndexPath*)indexPath;


//Initializes this DataManger as a DataSource for a TableView. The TableView will be updated when the data changes.
-(id)initAsDataSourceOfTableView:(UITableView*)tableView;

@end
