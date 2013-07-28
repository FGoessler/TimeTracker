//
//  TTMessageOverlay.m
//  timetracker
//
//  Created by Florian Goessler on 28.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTMessageOverlay.h"
#import "TTUIViewHelper.h"

@interface TTMessageOverlay ()
@property(nonatomic, strong) UIView *messageContainer;
@property(nonatomic, strong) UILabel *messageLabel;
@end

@implementation TTMessageOverlay

+ (UIView *)createMessageViewInVC:(UIViewController *)viewController withSpinner:(BOOL)spinner {
	UIView *baseView = [UIView new];
	[baseView.layer setCornerRadius:20.0];
	[baseView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
	baseView.translatesAutoresizingMaskIntoConstraints = NO;

	[viewController.view addSubview:baseView];

	[viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:baseView attribute:NSLayoutAttributeCenterX
																	relatedBy:NSLayoutRelationEqual
																	   toItem:viewController.view attribute:NSLayoutAttributeCenterX
																   multiplier:1.0 constant:0.0]];
	[viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:baseView attribute:NSLayoutAttributeCenterY
																	relatedBy:NSLayoutRelationEqual
																	   toItem:viewController.view attribute:NSLayoutAttributeCenterY
																   multiplier:1.0 constant:0.0]];
	[viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:baseView attribute:NSLayoutAttributeHeight
																	relatedBy:NSLayoutRelationGreaterThanOrEqual
																	   toItem:nil attribute:NSLayoutAttributeNotAnAttribute
																   multiplier:1.0 constant:50.0]];
	[viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:baseView attribute:NSLayoutAttributeWidth
																	relatedBy:NSLayoutRelationGreaterThanOrEqual
																	   toItem:nil attribute:NSLayoutAttributeNotAnAttribute
																   multiplier:1.0 constant:280.0]];

	//add label
	UILabel *label = [UILabel new];
	[label setTextAlignment:NSTextAlignmentCenter];
	[label setTextColor:[UIColor whiteColor]];
	[label setBackgroundColor:[UIColor clearColor]];
	label.translatesAutoresizingMaskIntoConstraints = NO;
	[baseView addSubview:label];

	[baseView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY
																	relatedBy:NSLayoutRelationEqual
																	   toItem:baseView attribute:NSLayoutAttributeCenterY
																   multiplier:1.0 constant:0.0]];
	[baseView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight
																	relatedBy:NSLayoutRelationGreaterThanOrEqual
																	   toItem:nil attribute:NSLayoutAttributeNotAnAttribute
																   multiplier:1.0 constant:50.0]];

	//add spinner
	if(spinner) {
		UIActivityIndicatorView *spinnerView = [UIActivityIndicatorView new];
		[baseView addSubview:spinnerView];
		spinnerView.translatesAutoresizingMaskIntoConstraints = NO;
		[spinnerView startAnimating];

		[baseView addConstraint:[NSLayoutConstraint constraintWithItem:spinnerView attribute:NSLayoutAttributeCenterY
															 relatedBy:NSLayoutRelationEqual
																toItem:baseView attribute:NSLayoutAttributeCenterY
															multiplier:1.0 constant:0.0]];
		[baseView addConstraint:[NSLayoutConstraint constraintWithItem:spinnerView attribute:NSLayoutAttributeLeading
															 relatedBy:NSLayoutRelationEqual
																toItem:baseView attribute:NSLayoutAttributeLeading
															multiplier:1.0 constant:10.0]];
		[baseView addConstraint:[NSLayoutConstraint constraintWithItem:spinnerView attribute:NSLayoutAttributeLeading
															 relatedBy:NSLayoutRelationEqual
																toItem:label attribute:NSLayoutAttributeLeading
															multiplier:1.0 constant:10.0]];
		[baseView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTrailing
															 relatedBy:NSLayoutRelationEqual
																toItem:baseView attribute:NSLayoutAttributeTrailing
															multiplier:1.0 constant:10.0]];
	} else {
		[baseView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX
															 relatedBy:NSLayoutRelationEqual
																toItem:baseView attribute:NSLayoutAttributeCenterX
															multiplier:1.0 constant:0.0]];

		[baseView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth
																		relatedBy:NSLayoutRelationGreaterThanOrEqual
																		   toItem:nil attribute:NSLayoutAttributeNotAnAttribute
																	   multiplier:1.0 constant:280.0]];
	}


	return baseView;
}

+ (TTMessageOverlay *)showLoadingOverlayInViewController:(UIViewController *)viewController {
	return [TTMessageOverlay showLoadingOverlayInViewController:viewController withMessage:@"Loading data..."];
}

+ (TTMessageOverlay *)showLoadingOverlayInViewController:(UIViewController *)viewController withMessage:(NSString *)message {
	TTMessageOverlay *newOverlay = [[TTMessageOverlay alloc] init];

	newOverlay.messageContainer = [TTMessageOverlay createMessageViewInVC:viewController withSpinner:YES ];
	newOverlay.messageLabel = (UILabel *) [TTUIViewHelper searchInSubviewsOfView:newOverlay.messageContainer forUIViewClass:[UILabel class]];
	newOverlay.messageLabel.text = message;

	return newOverlay;
}

+ (TTMessageOverlay *)showMessageOverlayInViewController:(UIViewController *)viewController withMessage:(NSString *)message forTime:(NSTimeInterval)timeInterval {
	TTMessageOverlay *newOverlay = [[TTMessageOverlay alloc] init];

	newOverlay.messageContainer = [TTMessageOverlay createMessageViewInVC:viewController withSpinner:NO ];
	newOverlay.messageLabel = (UILabel *) [TTUIViewHelper searchInSubviewsOfView:newOverlay.messageContainer forUIViewClass:[UILabel class]];
	newOverlay.messageLabel.text = message;

	[NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(hide) userInfo:nil repeats:NO];

	return newOverlay;
}

- (void)hide {
	[self.messageContainer removeFromSuperview];
}

@end
