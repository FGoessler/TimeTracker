//
//  TTExternalSystemLink.h
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TTProject;

@interface TTExternalSystemLink : NSManagedObject

@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *childProjects;
@end

@interface TTExternalSystemLink (CoreDataGeneratedAccessors)

- (void)addChildProjectsObject:(TTProject *)value;
- (void)removeChildProjectsObject:(TTProject *)value;
- (void)addChildProjects:(NSSet *)values;
- (void)removeChildProjects:(NSSet *)values;

@end
