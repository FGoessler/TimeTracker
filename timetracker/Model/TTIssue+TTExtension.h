//
//  TTIssue+TTExtension.h
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTIssue.h"

#define MOBJ_TTIssue @"TTIssue"

#define TTLOG_ENTRY_STILL_ACTIVE 9001
#define TTLOG_ENTRY_NOT_ACTIVE 9002

@interface TTIssue (TTExtension)
@property (readonly, nonatomic, strong) TTLogEntry *latestLogEntry;

-(TTLogEntry*)createNewUnsavedLogEntry;

-(BOOL)startTracking:(NSError**)err;
-(BOOL)stopTracking:(NSError**)err;

@end
