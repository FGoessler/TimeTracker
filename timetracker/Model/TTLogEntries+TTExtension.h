//
//  TTLogEntries+TTExtension.h
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTLogEntry.h"

#define MOBJ_TTLogEntry @"TTLogEntry"

#define TTLOG_ENTRY_INVALID_START_DATE 9011
#define TTLOG_ENTRY_INVALID_END_DATE 9012

@interface TTLogEntry (TTExtension)
@property (readonly, nonatomic) NSTimeInterval timeInterval;
@end
