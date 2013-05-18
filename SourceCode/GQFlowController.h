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

- (id)initWithViewControllers:(NSArray *)viewControllers;

- (void)flowInViewController:(GQViewController *)viewController animated:(BOOL)animated;
- (void)flowOutViewControllerAnimated:(BOOL)animated;

@property (nonatomic, copy) NSArray *viewControllers;

@property (nonatomic, strong, readonly) GQViewController *topViewController;

@end

@interface GQViewController (GQViewControllerItem)

@property (nonatomic, strong, readonly) GQFlowController *flowController;

@end