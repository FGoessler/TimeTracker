//
//  TTExternalSystemLink+TTExtension.h
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTExternalSystemLink.h"

#define MOBJ_TTExternalSystemLink @"TTExternalSystemLink"

#define TT_SYS_TYPE_GITHUB @"GitHub"

@interface TTExternalSystemLink (TTExtension)
+(NSSet*)getAllSystemLinkTypes;
+(TTExternalSystemLink*)createNewExternalSystemLinkOfType:(NSString*)type;
@end
