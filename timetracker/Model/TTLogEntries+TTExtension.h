//
//  TTLogEntries+TTExtension.h
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTLogEntry.h"

#define MOBJ_TTLogEntry @"TTLogEntry"

@interface TTLogEntry (TTExtension)
@property (readonly, nonatomic) NSTimeInterval timeInterval;
@end
