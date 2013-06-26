//
//  NSString+TTExtensions.m
//  timetracker
//
//  Created by Florian Goessler on 24.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "NSString+TTExtensions.h"

@implementation NSString (TTExtensions)

+ (NSString *)stringWithNSTimeInterval:(NSTimeInterval)timeInterval {
	int days = (int) floor(timeInterval / 60.0 / 60.0 / 24.0);
	int hours = (int) floor(timeInterval / 60.0 / 60.0 - days * 24.0);
	int minutes = (int) floor(timeInterval / 60.0 - hours * 60.0 - days * 60.0 * 24.0);
	int seconds = (int) floor(timeInterval - minutes * 60.0 - hours * 60.0 * 60.0 - days * 60.0 * 60.0 * 24.0);
	
	if(days > 0) {
		return [NSString stringWithFormat:@"%d %@ %02d:%02d:%02d", days, @"Day(s)", hours, minutes, seconds];
	} else {
		return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
	}
}

+ (NSString*)stringWithNSDate:(NSDate*)date {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	
	return [dateFormatter stringFromDate:date];
}

@end
