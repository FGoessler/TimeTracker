//
//  TTExternalSystemInterface.h
//  timetracker
//
//  Created by Florian Goessler on 27.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTExternalSystemLink+TTExtension.h"
#import "TTProject+TTExtension.h"
#import "TTIssue+TTExtension.h"
#import "TTExternalProject.h"


@protocol TTexternalSystemInterfaceDelegate;

@protocol TTExternalSystemInterface <NSObject>

-(void)validateLoginForSystemLink:(TTExternalSystemLink*)systemLink;
-(void)loadProjectListForSystemLink:(TTExternalSystemLink*)systemLink;
-(void)syncIssuesOfProject:(TTProject*)project;
-(void)syncTimelogEntriesOfIssues:(TTIssue*)issue;

-(void)setDelegate:(id<TTexternalSystemInterfaceDelegate>)delegate;
-(id<TTexternalSystemInterfaceDelegate>)getDelegate;

@end

@protocol TTexternalSystemInterfaceDelegate <NSObject>

@optional

-(void)loginFailed;
-(void)loginValid;

-(void)loadedProjectList:(NSArray*)projectList forSystemLink:(TTExternalSystemLink*)systemLink;
-(void)loadProjectListFailed:(TTExternalSystemLink*)systemLink;

-(void)syncedIssuesOfProject:(TTProject*)project;
-(void)syncingIssuesOfProjectFailed:(TTProject*)project;

-(void)syncedTimelogEntriesOfIssue:(TTIssue*)issue;
-(void)syncingTimelogEntriesOfIssueFailed:(TTIssue*)issue;

@end