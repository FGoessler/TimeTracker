//
//  TTExternalProject.h
//  timetracker
//
//  Created by Florian Goessler on 28.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTExternalProject : NSObject
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *externalSystemProjectId;
@end
