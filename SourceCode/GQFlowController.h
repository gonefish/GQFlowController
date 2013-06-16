//
//  GQFlowController.h
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQViewController.h"
#import "GQFlowControllerDelegate.h"



@interface GQFlowController : UIViewController <UIGestureRecognizerDelegate>

- (id)initWithRootViewController:(GQViewController *)rootViewController;
- (id)initWithViewControllers:(NSArray *)viewControllers;

- (void)flowInViewController:(GQViewController *)viewController animated:(BOOL)animated;
- (GQViewController *)flowOutViewControllerAnimated:(BOOL)animated;
- (NSArray *)flowOutToRootViewControllerAnimated:(BOOL)animated;
- (NSArray *)flowOutToViewController:(GQViewController *)viewController animated:(BOOL)animated;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, strong, readonly) GQViewController *topViewController;

@end

@interface UIViewController (GQFlowController)

@property (nonatomic, strong, readonly) GQFlowController *flowController;

@property (nonatomic) GQFlowDirection flowInDirection;

@property (nonatomic) GQFlowDirection flowOutDirection;

@property (nonatomic, getter=isOverlayContent) BOOL overlayContent;

@end