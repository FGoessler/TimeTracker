//
//  TTGitHubAPI.m
//  timetracker
//
//  Created by Florian Goessler on 27.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTGitHubAPI.h"
#import "TTAppDelegate.h"
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
		
		dispatch_async(dispatch_get_main_queue(), ^(){	//make sure to perform the callback on the main thread (otherwise no UI interaction!)
			if(self.delegate && [self.delegate respondsToSelector:@selector(loadProjectListFailed:)]) {
				[self.delegate loadProjectListFailed:systemLink];
			}
		});
	} completed:^(){
		dispatch_async(dispatch_get_main_queue(), ^(){	//make sure to perform the callback on the main thread (otherwise no UI interaction!)
			if(self.delegate && [self.delegate respondsToSelector:@selector(loadProjectListFailed:)]) {
				[self.delegate loadedProjectList:repositories forSystemLink:systemLink];
			}
		});
	}];
}

-(void)syncIssuesOfProject:(TTProject *)project {
	OCTUser* user = [OCTUser userWithLogin:project.parentSystemLink.username server:[OCTServer dotComServer]];
	OCTClient* client = [OCTClient authenticatedClientWithUser:user password:project.parentSystemLink.password];
		
	NSMutableArray *issues = [NSMutableArray array];
	
	RACSignal *issuesRequest = [client fetchIssuesForRepositoryWithName:project.externalSystemUID ofUser:project.parentSystemLink.username];
	[issuesRequest subscribeNext:^(OCTIssue *externalIssue) {
		NSLog(@"got issue: %@ - %@",externalIssue.title, externalIssue.text);
		
		[issues addObject:externalIssue];
	} error:^(NSError *err) {
		NSLog(@"%@", err);
		
		dispatch_async(dispatch_get_main_queue(), ^(){	//make sure to perform the callback on the main thread (otherwise no UI interaction!)
			if(self.delegate && [self.delegate respondsToSelector:@selector(loadProjectListFailed:)]) {
				[self.delegate syncingIssuesOfProjectFailed:project];
			}
		});
	} completed:^(){
		//check all issues
		for(OCTIssue *externalIssue in issues) {
			BOOL synced = false;
			//search for the local counterpart of the external issue
			for (TTIssue *localIssue in project.childIssues) {
				if([localIssue.externalSystemUID isEqualToString:externalIssue.objectID]) {
					localIssue.name = externalIssue.title;
					localIssue.shortText = externalIssue.text;
					synced = true;
					break;
				}
			}
			//no matching local issue found -> create one
			if(!synced) {
				[project addIssueWithName:externalIssue.title shortText:externalIssue.text externalUID:externalIssue.objectID andErrorIndicator:nil];
			}
		}
		
		[((TTAppDelegate*)[[UIApplication sharedApplication] delegate]) saveContext];	//TODO: error handling
		
		dispatch_async(dispatch_get_main_queue(), ^(){	//make sure to perform the callback on the main thread (otherwise no UI interaction!)
			if(self.delegate && [self.delegate respondsToSelector:@selector(loadProjectListFailed:)]) {
				[self.delegate syncedIssuesOfProject:project];
			}
		});
	}];
}

-(void)syncTimelogEntriesOfIssues:(TTIssue *)issue {
	
}

@end
