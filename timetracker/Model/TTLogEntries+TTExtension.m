//
//  TTLogEntries+TTExtension.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTLogEntries+TTExtension.h"

@implementation TTLogEntry (TTExtension)

-(NSTimeInterval)timeInterval {
	if(self.endDate != nil)
		return [self.endDate timeIntervalSinceDate:self.startDate];
	else
		return [[NSDate date] timeIntervalSinceDate:self.startDate];
}

@end
