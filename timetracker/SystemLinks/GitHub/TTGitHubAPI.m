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
	
	NSMutableArray *repositories = [NSMutableArray array];
	
	RACSignal *repositoriesRequest = [client fetchUserRepositories];
	[repositoriesRequest subscribeNext:^(OCTRepository *repository) {
		TTExternalProject *project = [[TTExternalProject alloc] init];
		project.name = repository.name;
		project.externalSystemProjectId = repository.name;
		
		[repositories addObject:project];
	} error:^(NSError *err) {
		NSLog(@"%@", err);
		
		dispatch_async(dispatch_get_main_queue(), ^(){
			[self.delegate loadProjectListFailed:systemLink];
		});
	} completed:^(){
		dispatch_async(dispatch_get_main_queue(), ^(){
			[self.delegate loadedProjectList:repositories forSystemLink:systemLink];
		});
	}];
}

-(void)syncIssuesOfProject:(TTProject *)project {
	//load all issues from the server and compare them with the issues known to the app (use the externalSystemIdentifier to identify issues)
}

-(void)syncTimelogEntriesOfIssues:(TTIssue *)issue {
	
}

@end
