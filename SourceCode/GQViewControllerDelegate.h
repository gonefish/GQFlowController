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
    GQFlowDirectionRight    = UISwipeGestureRecognizerDirectionRight,
    GQFlowDirectionLeft     = UISwipeGestureRecognizerDirectionLeft,
    GQFlowDirectionUp       = UISwipeGestureRecognizerDirectionUp,
    GQFlowDirectionDown     = UISwipeGestureRecognizerDirectionDown
} GQFlowDirection;

@protocol GQViewControllerDelegate <NSObject>

// 目标frame
- (CGRect)flowController:(GQFlowController *)flowController destinationRectForView:(UIView *)view;

@optional

// 滑动的UIView
- (UIView *)flowController:(GQFlowController *)flowController viewForFlowDirection:(GQFlowDirection)direction;

// 是否移动UIView
- (BOOL)flowController:(GQFlowController *)controller shouldMoveView:(UIView *)view toFrame:(CGRect)frame;

@end