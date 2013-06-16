//
//  GQFlowController.h
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    GQFlowDirectionUnknow,
    GQFlowDirectionRight,
    GQFlowDirectionLeft,
    GQFlowDirectionUp,
    GQFlowDirectionDown
} GQFlowDirection;

@interface GQFlowController : UIViewController <UIGestureRecognizerDelegate>

- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (id)initWithViewControllers:(NSArray *)viewControllers;

- (void)flowInViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)flowOutViewControllerAnimated:(BOOL)animated;
- (NSArray *)flowOutToRootViewControllerAnimated:(BOOL)animated;
- (NSArray *)flowOutToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, strong, readonly) UIViewController *topViewController;

@end

/**
 实现这个协议来激活压住滑动功能
 */
@protocol GQFlowControllerDelegate <NSObject>

@optional

// 目标frame
- (CGRect)flowController:(GQFlowController *)flowController destinationRectForFlowDirection:(GQFlowDirection)direction;


// 滑动的UIViewController
- (UIViewController *)flowController:(GQFlowController *)flowController viewControllerForFlowDirection:(GQFlowDirection)direction;


// 是否移动UIView
- (BOOL)flowController:(GQFlowController *)flowController shouldFlowToRect:(CGRect)frame;

// 移动到终点结束
- (void)didFlowToDestinationRect:(GQFlowController *)flowController;

// .0 ~ 1.0
- (CGFloat)flowingBoundary:(GQFlowController *)flowController;

@end

@interface UIViewController (GQFlowController)

@property (nonatomic, strong, readonly) GQFlowController *flowController;

@property (nonatomic) GQFlowDirection flowInDirection;

@property (nonatomic) GQFlowDirection flowOutDirection;

@property (nonatomic, getter=isOverlayContent) BOOL overlayContent;

@end