//
//  GQFlowController.h
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 Qian GuoQiang (gonefish@gmail.com). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    GQFlowDirectionUnknow,
    GQFlowDirectionRight,
    GQFlowDirectionLeft,
    GQFlowDirectionUp,
    GQFlowDirectionDown
} GQFlowDirection;

@interface GQFlowController : UIViewController

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
@protocol GQEnhancementViewController <NSObject>

@optional

// 目标frame
- (CGRect)destinationRectForFlowDirection:(GQFlowDirection)direction;


// 滑动的UIViewController
- (UIViewController *)viewControllerForFlowDirection:(GQFlowDirection)direction;


// 是否移动UIView
- (BOOL)shouldFlowToRect:(CGRect)frame;

// 移动到终点结束
- (void)didFlowToDestinationRect;

// .0 ~ 1.0
- (CGFloat)flowingBoundary;

// 默认为YES
- (BOOL)shouldScaleView;

@end

@interface UIViewController (GQViewController)

@property (nonatomic, strong, readonly) GQFlowController *flowController;

@property (nonatomic) GQFlowDirection flowInDirection;

@property (nonatomic) GQFlowDirection flowOutDirection;

@property (nonatomic, getter=isOverlayContent) BOOL overlayContent;

- (void)setShotViewScale:(CGFloat)scale;

@end