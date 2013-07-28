//
//  TTCloudHelper.m
//  timetracker
//
//  Created by Florian Goessler on 23.07.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTCloudHelper.h"


@implementation TTCloudHelper

#pragma mark - Utility

+ (NSString *)documentState:(int)state {
	if (!state) return @"Document state is normal";

	NSMutableString *string = [NSMutableString string];
	if ((state & UIDocumentStateClosed) != 0)
		[string appendString:@"Document is closed\n"];
	if ((state & UIDocumentStateInConflict) != 0)
		[string appendString:@"Document is in conflict"];
	if ((state & UIDocumentStateSavingError) != 0)
		[string appendString:@"Document is experiencing saving error"];
	if ((state & UIDocumentStateEditingDisabled) != 0)
		[string appendString:@"Document editing is disbled"];

	return string;
}

+ (BOOL)isICloudWishedByUser {
	NSNumber *value = [[NSUserDefaults standardUserDefaults] valueForKey:@"TTUseICloudStatus"];
	if (value != nil && [value boolValue] == true) {
		return true;
	} else {
		return false;
	}
}

+ (BOOL)hasUserBeenAskedForICloudUsage {
	return [[NSUserDefaults standardUserDefaults] valueForKey:@"TTUseICloudStatus"] == nil ? false : true;
}

+ (void)setUsersStoredICloudChoice:(NSNumber *)useICloud {
	[[NSUserDefaults standardUserDefaults] setValue:useICloud forKey:@"TTUseICloudStatus"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Local Documents
+ (NSString *)localDocumentsPath {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSURL *)localDocumentsURL {
	return [NSURL fileURLWithPath:[self localDocumentsPath]];
}

#pragma mark Ubiquity Data
+ (NSURL *)ubiquityDataURLForContainer:(NSString *)container {
	return [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:container];
}

+ (NSURL *)ubiquityDataURL {
	return [self ubiquityDataURLForContainer:nil];
}

#pragma mark - File URLs
+ (NSURL *)localFileURL:(NSString *)filename {
	if (!filename) return nil;
	NSURL *fileURL = [[self localDocumentsURL] URLByAppendingPathComponent:filename];
	return fileURL;
}

+ (NSURL *)ubiquityDataFileURL:(NSString *)filename {
	if (!filename) return nil;
	NSURL *fileURL = [[self ubiquityDataURLForContainer:nil] URLByAppendingPathComponent:filename];
	return fileURL;
}

#pragma mark - Testing Files
+ (BOOL)isLocal:(NSString *)filename {
	if (!filename) return NO;
	NSURL *targetURL = [self localFileURL:filename];
	if (!targetURL) return NO;
	return [[NSFileManager defaultManager] fileExistsAtPath:targetURL.path];
}


@end
