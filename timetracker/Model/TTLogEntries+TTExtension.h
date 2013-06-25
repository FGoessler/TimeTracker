//
//  TTLogEntries+TTExtension.h
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTLogEntries.h"

#define MOBJ_TTLogEntry @"TTLogEntries"

@interface TTLogEntries (TTExtension)
@property (readonly, nonatomic) NSTimeInterval timeInterval;
@end
