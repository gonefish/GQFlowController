//
//  GQFlowController.h
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQViewController.h"

@interface GQFlowController : GQViewController

- (id)initWithRootViewController:(GQViewController *)rootViewController;

- (void)flowInViewController:(GQViewController *)viewController animated:(BOOL)animated;
- (void)flowOutViewControllerAnimated:(BOOL)animated;

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, readonly, weak) GQViewController *topViewController;

@end
