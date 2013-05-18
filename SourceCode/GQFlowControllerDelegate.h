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

@protocol GQFlowControllerDelegate <NSObject>

// 目标frame
- (CGRect)flowController:(GQFlowController *)flowController destinationRectForViewController:(GQViewController *)viewController flowDirection:(GQFlowDirection)direction;

@optional

// 滑动的GQViewController
- (GQViewController *)flowController:(GQFlowController *)flowController moveViewControllerForFlowDirection:(GQFlowDirection)direction;


// 是否移动UIView
- (BOOL)flowController:(GQFlowController *)flowController shouldMoveViewController:(GQViewController *)viewController toFrame:(CGRect)frame;

// 移动到终点结束
- (void)flowController:(GQFlowController *)flowController didMoveViewController:(GQViewController *)viewController;

@end
