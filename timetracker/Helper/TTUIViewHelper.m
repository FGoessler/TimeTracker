//
// Created by Florian Goessler on 26.07.13.
// Copyright (c) 2013 Florian Goessler. All rights reserved.
//


#import "TTUIViewHelper.h"


@implementation TTUIViewHelper {

}
+ (UIView *)searchInSubviewsOfView:(UIView *)view forUIViewClass:(Class)class {
	NSMutableArray *subviews = view.subviews.mutableCopy;
	while (subviews.count > 0) {
		UIView *currentView = subviews.lastObject;
		if ([currentView isKindOfClass:class]) {
			return currentView;
		} else {
			[subviews addObjectsFromArray:currentView.subviews];
		}
		[subviews removeObject:currentView];
	}
	return nil;
}
@end