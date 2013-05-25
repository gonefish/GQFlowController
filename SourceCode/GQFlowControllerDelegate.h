//
//  GQFlowControllerDelegate.h
//  GQFlowController
//
//  Created by 钱国强 on 13-5-18.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GQFlowController;
@class GQViewController;

/**
 实现这个协议来激活压住滑动功能
 */
@protocol GQFlowControllerDelegate <NSObject>

@optional

// 目标frame
- (CGRect)flowController:(GQFlowController *)flowController destinationRectForFlowDirection:(GQFlowDirection)direction;


// 滑动的GQViewController
- (GQViewController *)flowController:(GQFlowController *)flowController viewControllerForFlowDirection:(GQFlowDirection)direction;


// 是否移动UIView
- (BOOL)flowController:(GQFlowController *)flowController shouldFlowToRect:(CGRect)frame;

// 移动到终点结束
- (void)didFlowToDestinationRect:(GQFlowController *)flowController;

// .0 ~ 1.0
- (CGFloat)flowingBoundary:(GQFlowController *)flowController;

@end
