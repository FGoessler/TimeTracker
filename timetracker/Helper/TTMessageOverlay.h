//
//  TTMessageOverlay.h
//  timetracker
//
//  Created by Florian Goessler on 28.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTMessageOverlay : NSObject

+(TTMessageOverlay*)showLoadingOverlayInViewController:(UIViewController*)viewController;

+(TTMessageOverlay*)showMessageOverlayInViewController:(UIViewController*)viewController withMessage:(NSString*)message forTime:(NSTimeInterval)timeInterval;

@property (nonatomic, strong) NSString *message;

-(void)hide;

@end
