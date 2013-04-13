//
//  GQViewControllerDelegate.h
//  GQFlowController
//
//  Created by 钱国强 on 13-4-11.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GQFlowController;

typedef enum {
    GQViewControllerFlowDirectionRight  = UISwipeGestureRecognizerDirectionRight,
    GQViewControllerFlowDirectionLeft   = UISwipeGestureRecognizerDirectionLeft,
    GQViewControllerFlowDirectionUp     = UISwipeGestureRecognizerDirectionUp,
    GQViewControllerFlowDirectionDown   = UISwipeGestureRecognizerDirectionDown
} GQViewControllerFlowDirection;

@protocol GQViewControllerDelegate <NSObject>

@optional
// 滑动的UIView
- (UIView *)viewForFlowController:(GQFlowController *)controller direction:(GQViewControllerFlowDirection)direction;

// 判断是否到达目标位置
- (BOOL)flowController:(GQFlowController *)controller shouldFlowingView:(UIView *)view atOffset:(CGFloat)offset;


@end
