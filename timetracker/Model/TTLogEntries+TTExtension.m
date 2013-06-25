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

-(BOOL)validateStartDate:(NSDate **)ioValue error:(NSError **)outError {
	if(*ioValue == nil) {
		if (outError != NULL) {
            NSDictionary *userInfoDict = @{ NSLocalizedDescriptionKey : @"Start date must not be nil!",
											@"NSValidationErrorKey" : @"startDate"};
            NSError *error = [[NSError alloc] initWithDomain:@"TTModelError"
														code:TTLOG_ENTRY_INVALID_START_DATE
													userInfo:userInfoDict];
            *outError = error;
        }
		return NO;
	}
	if(self.endDate != nil && [*ioValue compare:self.endDate] != NSOrderedAscending) {
		if (outError != NULL) {
            NSDictionary *userInfoDict = @{ NSLocalizedDescriptionKey : @"Start date must be before end date!",
											@"NSValidationErrorKey" : @"startDate"};
            NSError *error = [[NSError alloc] initWithDomain:@"TTModelError"
														code:TTLOG_ENTRY_INVALID_START_DATE
													userInfo:userInfoDict];
            *outError = error;
        }
		return NO;
	}
	return YES;
}

-(BOOL)validateEndDate:(NSDate **)ioValue error:(NSError **)outError {
	if(*ioValue == nil) {
		return YES;	//allow nil values
	}
	if([*ioValue compare:self.startDate] != NSOrderedDescending) {
		if (outError != NULL) {
            NSDictionary *userInfoDict = @{ NSLocalizedDescriptionKey : @"End date must be after start date!",
											@"NSValidationErrorKey" : @"endDate"};
            NSError *error = [[NSError alloc] initWithDomain:@"TTModelError"
														code:TTLOG_ENTRY_INVALID_END_DATE
													userInfo:userInfoDict];
            *outError = error;
        }
		return NO;
	}
	return YES;
}

@end
