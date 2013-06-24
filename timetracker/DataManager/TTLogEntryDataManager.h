//
//  TTLogEntryDataManager.h
//  timetracker
//
//  Created by Florian Goessler on 24.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTIssue+TTExtension.h"

@interface TTLogEntryDataManager : NSObject <UITableViewDataSource>
@property (nonatomic, strong) TTIssue *issue;

//Initialzes this DataManger as a DataSource for a TableView. The TableView will be updated when the data changes.
-(id)initWithIssue:(TTIssue*)issue asDataSourceOfTableView:(UITableView*)tableView;
@end
