//
//  NSString+TTExtensions.h
//  timetracker
//
//  Created by Florian Goessler on 24.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TTExtensions)
+ (NSString *)stringWithNSTimeInterval:(NSTimeInterval)timeInterval;

+ (NSString *)stringWithNSDate:(NSDate *)date;
@end
