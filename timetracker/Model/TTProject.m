//
//  TTProject.m
//  timetracker
//
//  Created by Florian Goessler on 28.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTProject.h"
#import "TTExternalSystemLink.h"
#import "TTIssue.h"


@implementation TTProject

@dynamic name;
@dynamic externalSystemUID;
@dynamic childIssues;
@dynamic defaultIssue;
@dynamic parentSystemLink;

@end
