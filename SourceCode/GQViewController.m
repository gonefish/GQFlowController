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

@end

@implementation GQViewController

#pragma mark - GQViewControllerDelegate

- (CGRect)flowController:(GQFlowController *)flowController destinationRectForView:(UIView *)view flowDirection:(GQFlowDirection)direction
{
    // 默认保持不动
    return view.frame;
}

@end
