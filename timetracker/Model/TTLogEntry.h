//
//  TTLogEntries.h
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TTIssue;

@interface TTLogEntry : NSManagedObject

@property(nonatomic, retain) NSString *comment;
@property(nonatomic, retain) NSDate *endDate;
@property(nonatomic, retain) NSDate *startDate;
@property(nonatomic, retain) NSNumber *synced;
@property(nonatomic, retain) TTIssue *parentIssue;

@end
