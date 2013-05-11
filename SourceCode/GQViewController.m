//
//  GQViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "GQViewController.h"
#import "GQFlowController.h"

@interface GQViewController ()

- (void)_setFlowController:(GQFlowController *)flowController;

- (void)_setActiveViewController:(GQViewController *)viewController;

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) GQViewController *activeViewController;

@property (nonatomic, strong) GQFlowController *flowController;

@end

@implementation GQViewController

- (UIView *)coverView
{
    if (_coverView == nil) {
        _coverView = [[UIView alloc] initWithFrame:self.view.frame];
    }
    
    return _coverView;
}

- (void)setActive:(BOOL)active
{
    _active = active;
    
    if (self.isActive) {
        [self.coverView removeFromSuperview];
    } else {
        [self.view addSubview:self.coverView];
    }
}

#pragma mark - GQViewControllerDelegate

- (CGRect)flowController:(GQFlowController *)flowController destinationRectForView:(UIView *)view flowDirection:(GQFlowDirection)direction
{
    // 默认保持不动
    return view.frame;
}

#pragma mark - Priveate Method

- (void)_setFlowController:(GQFlowController *)flowController
{
    self.flowController = flowController;
}

- (void)_setActiveViewController:(GQViewController *)viewController
{
    self.activeViewController = viewController;
}

@end
