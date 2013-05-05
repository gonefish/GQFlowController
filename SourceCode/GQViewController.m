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

- (CGRect)flowController:(GQFlowController *)flowController destinationRectForView:(UIView *)view
{
    // 默认滑出GQFlowController的显示界面
    return CGRectMake(flowController.view.frame.size.width,
                      0,
                      view.frame.size.width,
                      view.frame.size.height);
}

@end
