//
//  TTGitHubAPI.h
//  timetracker
//
//  Created by Florian Goessler on 27.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTExternalSystemInterface.h"

@interface TTGitHubAPI : NSObject <TTExternalSystemInterface>
@property(nonatomic, weak) id <TTexternalSystemInterfaceDelegate> delegate;
@end
