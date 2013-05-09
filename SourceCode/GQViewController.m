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

@property (nonatomic, strong) UIView *activeView;

@end

@implementation GQViewController

- (UIView *)activeView
{
    if (_activeView == nil) {
        _activeView = [[UIView alloc] initWithFrame:self.view.frame];
    }
    
    return _activeView;
}

- (void)setActive:(BOOL)active
{
    _active = active;
    
    if (self.isActive) {
        [self.activeView removeFromSuperview];
    } else {
        [self.view addSubview:self.activeView];
    }
}

#pragma mark - GQViewControllerDelegate

- (CGRect)flowController:(GQFlowController *)flowController destinationRectForView:(UIView *)view flowDirection:(GQFlowDirection)direction
{
    // 默认保持不动
    return view.frame;
}

@end
