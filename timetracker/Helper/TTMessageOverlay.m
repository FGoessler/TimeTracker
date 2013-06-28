//
//  TTMessageOverlay.m
//  timetracker
//
//  Created by Florian Goessler on 28.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTMessageOverlay.h"

@interface TTMessageOverlay ()
@property (nonatomic, strong) UILabel *messageLabel;
@end
@implementation TTMessageOverlay

+(UILabel*)createMessageLabelInVC:(UIViewController*)viewController {
	UILabel *label = [UILabel new];
	[label setTextAlignment:NSTextAlignmentCenter];
	[label setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.2]];
	label.translatesAutoresizingMaskIntoConstraints = NO;
	
	[viewController.view addSubview:label];
	
	[viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX
																	relatedBy:NSLayoutRelationEqual
																	   toItem:viewController.view attribute:NSLayoutAttributeCenterX
																   multiplier:1.0 constant:0.0]];
	[viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY
																	relatedBy:NSLayoutRelationEqual
																	   toItem:viewController.view attribute:NSLayoutAttributeCenterY
																   multiplier:1.0 constant:0.0]];
	[viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight
																	relatedBy:NSLayoutRelationGreaterThanOrEqual
																	   toItem:nil attribute:NSLayoutAttributeNotAnAttribute
																   multiplier:1.0 constant:50.0]];
	[viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth
																	relatedBy:NSLayoutRelationGreaterThanOrEqual
																	   toItem:nil attribute:NSLayoutAttributeNotAnAttribute
																   multiplier:1.0 constant:280.0]];
	
	return label;
}

+(TTMessageOverlay*)showLoadingOverlayInViewController:(UIViewController*)viewController {
	TTMessageOverlay *newOverlay = [[TTMessageOverlay alloc] init];
	
	newOverlay.messageLabel = [TTMessageOverlay createMessageLabelInVC:viewController];
	newOverlay.messageLabel.text = @"Loading data...";
	
	return newOverlay;
}

+(TTMessageOverlay*)showMessageOverlayInViewController:(UIViewController*)viewController withMessage:(NSString*)message forTime:(NSTimeInterval)timeInterval {
	TTMessageOverlay *newOverlay = [[TTMessageOverlay alloc] init];
	
	newOverlay.messageLabel = [TTMessageOverlay createMessageLabelInVC:viewController];
	newOverlay.messageLabel.text = message;

	[NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(hide) userInfo:nil repeats:NO];
	
	return newOverlay;
}

-(void)hide {
	[self.messageLabel removeFromSuperview];
}

@end
