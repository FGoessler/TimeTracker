//
//  TTGitHubAPI.m
//  timetracker
//
//  Created by Florian Goessler on 27.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTGitHubAPI.h"
#import <OctoKit/OctoKit.h>

@implementation TTGitHubAPI

-(id<TTexternalSystemInterfaceDelegate>)getDelegate {
	return _delegate;
}

-(void)validateLoginForSystemLink:(TTExternalSystemLink *)systemLink {
	OCTUser* user = [OCTUser userWithLogin:systemLink.username server:[OCTServer dotComServer]];
	OCTClient* client = [OCTClient authenticatedClientWithUser:user password:systemLink.password];
	
	RACSignal *userInfo = [client fetchUserInfo];
	[userInfo subscribeNext:^(OCTUser *user) {
		NSLog(@"%@", user.name);
	} error:^(NSError *err) {
		NSLog(@"%@", err);
	}];
}

-(void)loadProjectListForSystemLink:(TTExternalSystemLink *)systemLink {
	OCTUser* user = [OCTUser userWithLogin:systemLink.username server:[OCTServer dotComServer]];
	OCTClient* client = [OCTClient authenticatedClientWithUser:user password:systemLink.password];
	
	RACSignal *repositories = [client fetchUserRepositories];
	[repositories subscribeNext:^(OCTRepository *repository) {
		NSLog(@"%@", repository.name);
		
		[self.delegate loadedProjectList:@[repository.name] forStytemLink:systemLink];
	} error:^(NSError *err) {
		NSLog(@"%@", err);
		
		[self.delegate loadProjectListFailed:systemLink];
	}];
}

-(void)syncIssuesOfProject:(TTProject *)project {
	
}

-(void)syncTimelogEntriesOfIssues:(TTIssue *)issue {
	
}

@end
