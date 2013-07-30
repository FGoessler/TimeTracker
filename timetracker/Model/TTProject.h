//
//  TTProject.h
//  timetracker
//
//  Created by Florian Goessler on 28.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TTExternalSystemLink, TTIssue;

@interface TTProject : NSManagedObject

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *externalSystemUID;
@property(nonatomic, retain) NSSet *childIssues;
@property(nonatomic, retain) TTIssue *defaultIssue;
@property(nonatomic, retain) TTExternalSystemLink *parentSystemLink;
@end

@interface TTProject (CoreDataGeneratedAccessors)

- (void)addChildIssuesObject:(TTIssue *)value;

- (void)removeChildIssuesObject:(TTIssue *)value;

- (void)addChildIssues:(NSSet *)values;

- (void)removeChildIssues:(NSSet *)values;

@end
