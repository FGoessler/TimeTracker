//
// Created by Florian Goessler on 26.07.13.
// Copyright (c) 2013 Florian Goessler. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface TTUIViewHelper : NSObject
+ (UIView *)searchInSubviewsOfView:(UIView *)view forUIViewClass:(Class)class;
@end