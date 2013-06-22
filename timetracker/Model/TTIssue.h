//
//  TTIssue.h
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TTLogEntries, TTProject;

@interface TTIssue : NSManagedObject

@property (nonatomic, retain) NSString * externalSystemUID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * shortText;
@property (nonatomic, retain) NSSet *childLogEntries;
@property (nonatomic, retain) TTProject *parentProject;
@end

@interface TTIssue (CoreDataGeneratedAccessors)

- (void)addChildLogEntriesObject:(TTLogEntries *)value;
- (void)removeChildLogEntriesObject:(TTLogEntries *)value;
- (void)addChildLogEntries:(NSSet *)values;
- (void)removeChildLogEntries:(NSSet *)values;

@end
