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

//Creates a new TTProject object with the given name and saves with the default ManagedObjectContext.
+(TTProject*)createNewProjectWithName:(NSString*)name;

@property (nonatomic, strong, readonly) TTIssue* currentIssue;

-(BOOL)addIssueWithName:(NSString *)name andError:(NSError**)err;
-(BOOL)addIssueWithName:(NSString *)name shortText:(NSString *)text externalUID:(NSString *)uid andErrorIndicator:(NSError**)err;

@end
