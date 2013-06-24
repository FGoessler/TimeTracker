//
//  TTProject+TTExtension.h
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTProject.h"

#define MOBJ_TTProject @"TTProject"

@interface TTProject (TTExtension)
@property (nonatomic, strong, readonly) TTIssue* currentIssue;
@end
