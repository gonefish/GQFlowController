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
    GQFlowDirectionUnknow,
    GQFlowDirectionRight,
    GQFlowDirectionLeft,
    GQFlowDirectionUp,
    GQFlowDirectionDown
} GQFlowDirection;

@protocol GQViewControllerDelegate <NSObject>

// 目标frame
- (CGRect)flowController:(GQFlowController *)flowController destinationRectForView:(UIView *)view flowDirection:(GQFlowDirection)direction;

@optional

// 滑动的UIView
- (UIView *)flowController:(GQFlowController *)flowController viewForFlowDirection:(GQFlowDirection)direction;

// 是否移动UIView
- (BOOL)flowController:(GQFlowController *)controller shouldMoveView:(UIView *)view toFrame:(CGRect)frame;

// 移动到终点结束
- (void)flowController:(GQFlowController *)controller didMoveViewToDestination:(UIView *)view;

@end
