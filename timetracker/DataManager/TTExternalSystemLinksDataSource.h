//
//  TTExternalSystemLinksDataSource.h
//  timetracker
//
//  Created by Florian Goessler on 27.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTExternalSystemLinksDataSource : NSObject <UITableViewDataSource>

//Returns the system link, which is displayed at the given IndexPath.
-(TTExternalSystemLink*)systemLinkAtIndexPath:(NSIndexPath*)indexPath;


//Initializes this object as a DataSource for a TableView. The TableView will be updated when the data changes.
-(id)initAsDataSourceOfTableView:(UITableView*)tableView;

@end
