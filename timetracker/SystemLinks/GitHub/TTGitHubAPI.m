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

- (id <TTexternalSystemInterfaceDelegate>)getDelegate {
	return _delegate;
}

- (void)validateLoginForSystemLink:(TTExternalSystemLink *)systemLink {
	OCTUser *user = [OCTUser userWithLogin:systemLink.username server:[OCTServer dotComServer]];
	OCTClient *client = [OCTClient authenticatedClientWithUser:user password:systemLink.password];

	RACSignal *userInfo = [client fetchUserInfo];
	[userInfo subscribeNext:^(OCTUser *user) {
		NSLog(@"%@", user.name);
	}                 error:^(NSError *err) {
		NSLog(@"%@", err);
	}];
}

- (void)loadProjectListForSystemLink:(TTExternalSystemLink *)systemLink {
	OCTUser *user = [OCTUser userWithLogin:systemLink.username server:[OCTServer dotComServer]];
	OCTClient *client = [OCTClient authenticatedClientWithUser:user password:systemLink.password];

	NSMutableArray *repositories = [NSMutableArray array];

	RACSignal *repositoriesRequest = [client fetchUserRepositories];
	[repositoriesRequest subscribeNext:^(OCTRepository *repository) {
		TTExternalProject *project = [[TTExternalProject alloc] init];
		project.name = repository.name;
		project.externalSystemProjectId = [NSString stringWithFormat:@"%@/%@", repository.ownerLogin, repository.name];

		[repositories addObject:project];
	}                            error:^(NSError *err) {
		NSLog(@"%@", err);

		dispatch_async(dispatch_get_main_queue(), ^() {    //make sure to perform the callback on the main thread (otherwise no UI interaction!)
			if (self.delegate && [self.delegate respondsToSelector:@selector(loadProjectListFailed:)]) {
				[self.delegate loadProjectListFailed:systemLink];
			}
		});
	}                        completed:^() {
		dispatch_async(dispatch_get_main_queue(), ^() {    //make sure to perform the callback on the main thread (otherwise no UI interaction!)
			if (self.delegate && [self.delegate respondsToSelector:@selector(loadProjectListFailed:)]) {
				[self.delegate loadedProjectList:repositories forSystemLink:systemLink];
			}
		});
	}];
}

- (void)syncIssuesOfProject:(TTProject *)project {
	OCTUser *user = [OCTUser userWithLogin:project.parentSystemLink.username server:[OCTServer dotComServer]];
	OCTClient *client = [OCTClient authenticatedClientWithUser:user password:project.parentSystemLink.password];

	NSMutableArray *issues = [NSMutableArray array];

	//load all open issues from github
	RACSignal *issuesRequest = [client fetchIssuesForRepositoryWithIdString:project.externalSystemUID withOptions:@{@"state" : @"open"}];
	[issuesRequest subscribeNext:^(OCTIssue *externalIssue) {
		[issues addObject:externalIssue];
	}                      error:^(NSError *err) {
		NSLog(@"%@", err);

		dispatch_async(dispatch_get_main_queue(), ^() {    //make sure to perform the callback on the main thread (otherwise no UI interaction!)
			if (self.delegate && [self.delegate respondsToSelector:@selector(syncingIssuesOfProjectFailed:)]) {
				[self.delegate syncingIssuesOfProjectFailed:project];
			}
		});
	}                  completed:^() {
		//load all closed issues from github
		RACSignal *issuesRequest = [client fetchIssuesForRepositoryWithIdString:project.externalSystemUID withOptions:@{@"state" : @"closed"}];
		[issuesRequest subscribeNext:^(OCTIssue *externalIssue) {
			[externalIssue setValue:[NSString stringWithFormat:@"CLOSED - %@", externalIssue.title] forKey:@"title"];
			[issues addObject:externalIssue];
		}                      error:^(NSError *err) {
			NSLog(@"%@", err);

			dispatch_async(dispatch_get_main_queue(), ^() {    //make sure to perform the callback on the main thread (otherwise no UI interaction!)
				if (self.delegate && [self.delegate respondsToSelector:@selector(syncingIssuesOfProjectFailed:)]) {
					[self.delegate syncingIssuesOfProjectFailed:project];
				}
			});
		}                  completed:^() {
			//check all issues
			NSMutableArray *unupdatedIssues = [project.childIssues mutableCopy];
			for (OCTIssue *externalIssue in issues) {
				BOOL synced = false;
				//search for the local counterpart of the external issue
				for (TTIssue *localIssue in project.childIssues) {
					if ([localIssue.externalSystemUID isEqualToString:externalIssue.objectID]) {
						localIssue.name = externalIssue.title;
						localIssue.shortText = externalIssue.text;
						[unupdatedIssues removeObject:localIssue];    //issue is synced -> remove from list of unsynced issues
						synced = true;
						break;
					}
				}
				//no matching local issue found -> create one
				if (!synced) {
					[project addIssueWithName:externalIssue.title shortText:externalIssue.text externalUID:externalIssue.objectID andErrorIndicator:nil];
				}
			}

			//iterate over all local issues which do not have an counterpart in the external system and set their externalSystemUID to nil
			for (TTIssue *issueWithoutExternalCounterpart in unupdatedIssues) {
				issueWithoutExternalCounterpart.externalSystemUID = nil;
			}

			[[TTCoreDataManager defaultManager] saveContext];

			dispatch_async(dispatch_get_main_queue(), ^() {    //make sure to perform the callback on the main thread (otherwise no UI interaction!)
				if (self.delegate && [self.delegate respondsToSelector:@selector(syncedIssuesOfProject:)]) {
					[self.delegate syncedIssuesOfProject:project];
				}
			});
		}];
	}];
}

- (void)syncTimelogEntriesOfIssues:(TTIssue *)issue {
	if (issue.externalSystemUID == nil) {
		return;
	}

	OCTUser *user = [OCTUser userWithLogin:issue.parentProject.parentSystemLink.username server:[OCTServer dotComServer]];
	OCTClient *client = [OCTClient authenticatedClientWithUser:user password:issue.parentProject.parentSystemLink.password];

	__block BOOL updated = false;

	OCTIssue *gitHubIssue = [[OCTIssue alloc] initWithDictionary:@{@"objectID" : issue.externalSystemUID} error:nil];
	NSRange dividerPosition = [issue.parentProject.externalSystemUID rangeOfString:@"/"];;
	NSString *ownerName = [issue.parentProject.externalSystemUID substringToIndex:dividerPosition.location];
	NSString *repositoryName = [issue.parentProject.externalSystemUID substringFromIndex:dividerPosition.location + 1];
	OCTRepository *gitHubRepro = [[OCTRepository alloc] initWithDictionary:@{@"ownerLogin" : ownerName, @"name" : repositoryName} error:nil];

	RACSignal *commentsReuqest = [client fetchCommentsForIssue:gitHubIssue inRepository:gitHubRepro];
	[commentsReuqest subscribeNext:^(OCTIssueComment *comment) {
		//check each comment if it contains TimeTracker information and update those information if its invalid		
		if ([comment.text rangeOfString:[NSString stringWithFormat:@"[# TimeTracker : %@ #]", issue.parentProject.parentSystemLink.username]].location != NSNotFound) {
			NSString *newCommentText = [self createTimelogCommentForIssue:issue];

			if (newCommentText != nil) {        //only add a comment when some time tracking information exist!
				NSMutableDictionary *newData = [[comment dictionaryValue] mutableCopy];
				[newData setValue:newCommentText forKey:@"text"];
				OCTIssueComment *newComment = [[OCTIssueComment alloc] initWithDictionary:newData error:nil];

				RACSignal *createCommentRequest = [client updateComment:newComment inRepository:gitHubRepro];
				[createCommentRequest subscribeError:^(NSError *err) {
					NSLog(@"%@", err);

					dispatch_async(dispatch_get_main_queue(), ^() {    //make sure to perform the callback on the main thread (otherwise no UI interaction!)
						if (self.delegate && [self.delegate respondsToSelector:@selector(syncingTimelogEntriesOfIssueFailed:)]) {
							[self.delegate syncingTimelogEntriesOfIssueFailed:issue];
						}
					});
				}                          completed:^() {
					dispatch_async(dispatch_get_main_queue(), ^() {    //make sure to perform the callback on the main thread (otherwise no UI interaction!)
						if (self.delegate && [self.delegate respondsToSelector:@selector(syncedTimelogEntriesOfIssue:)]) {
							[self.delegate syncedTimelogEntriesOfIssue:issue];
						}
					});
				}];
			} else {    //since there's no tracking information delete this outdated comment
				RACSignal *deleteCommentRequest = [client deleteComment:comment inRepository:gitHubRepro];
				[deleteCommentRequest subscribeError:^(NSError *err) {
					NSLog(@"%@", err);

					dispatch_async(dispatch_get_main_queue(), ^() {    //make sure to perform the callback on the main thread (otherwise no UI interaction!)
						if (self.delegate && [self.delegate respondsToSelector:@selector(syncingTimelogEntriesOfIssueFailed:)]) {
							[self.delegate syncingTimelogEntriesOfIssueFailed:issue];
						}
					});
				}                          completed:^() {
					dispatch_async(dispatch_get_main_queue(), ^() {    //make sure to perform the callback on the main thread (otherwise no UI interaction!)
						if (self.delegate && [self.delegate respondsToSelector:@selector(syncedTimelogEntriesOfIssue:)]) {
							[self.delegate syncedTimelogEntriesOfIssue:issue];
						}
					});
				}];
			}

			updated = true;
		}

	}                        error:^(NSError *err) {
		NSLog(@"%@", err);

		dispatch_async(dispatch_get_main_queue(), ^() {    //make sure to perform the callback on the main thread (otherwise no UI interaction!)
			if (self.delegate && [self.delegate respondsToSelector:@selector(loadProjectListFailed:)]) {
				[self.delegate syncingTimelogEntriesOfIssueFailed:issue];
			}
		});
	}                    completed:^() {
		//if no comment exists -> create one 
		if (!updated) {
			NSString *newCommentText = [self createTimelogCommentForIssue:issue];

			if (newCommentText != nil) {        //only add a comment when some time tracking information exist!
				OCTIssueComment *newComment = [[OCTIssueComment alloc] initWithDictionary:@{@"text" : newCommentText} error:nil];

				RACSignal *createCommentRequest = [client createComment:newComment forIssue:gitHubIssue inRepository:gitHubRepro];
				[createCommentRequest subscribeError:^(NSError *err) {
					NSLog(@"%@", err);

					dispatch_async(dispatch_get_main_queue(), ^() {    //make sure to perform the callback on the main thread (otherwise no UI interaction!)
						if (self.delegate && [self.delegate respondsToSelector:@selector(syncingTimelogEntriesOfIssueFailed:)]) {
							[self.delegate syncingTimelogEntriesOfIssueFailed:issue];
						}
					});
				}                          completed:^() {
					dispatch_async(dispatch_get_main_queue(), ^() {    //make sure to perform the callback on the main thread (otherwise no UI interaction!)
						if (self.delegate && [self.delegate respondsToSelector:@selector(syncedTimelogEntriesOfIssue:)]) {
							[self.delegate syncedTimelogEntriesOfIssue:issue];
						}
					});
				}];
			}
		}
	}];
}

- (NSString *)createTimelogCommentForIssue:(TTIssue *)issue {
	if ([issue.childLogEntries count] == 0) {
		return nil;
	}

	NSMutableString *comment = [@"" mutableCopy];

	[comment appendFormat:@"[# TimeTracker : %@ #]\n", issue.parentProject.parentSystemLink.username];

	for (TTLogEntry *logEntry in issue.childLogEntries) {
		if (logEntry.endDate == nil) {
			[comment appendFormat:@"[# in progress since: %@ #]\n", [NSString stringWithNSDate:logEntry.startDate]];
		} else if (logEntry.comment != nil && ![logEntry.comment isEqualToString:@""]) {
			[comment appendFormat:@"[# from: %@ until: %@ = %@ : %@ #]\n", [NSString stringWithNSDate:logEntry.startDate], [NSString stringWithNSDate:logEntry.endDate], [NSString stringWithNSTimeInterval:logEntry.timeInterval], logEntry.comment];
		} else {
			[comment appendFormat:@"[# from: %@ until: %@ = %@ #]\n", [NSString stringWithNSDate:logEntry.startDate], [NSString stringWithNSDate:logEntry.endDate], [NSString stringWithNSTimeInterval:logEntry.timeInterval]];
		}
	}

	[comment appendString:@"[# TimeTracker #]"];

	return comment;
}

@end
