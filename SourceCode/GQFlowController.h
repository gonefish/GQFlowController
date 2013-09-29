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


/** 滑动已经添加的视图控制器到指定位置
 
 */
- (void)flowingViewController:(UIViewController *)viewController toFrame:(CGRect)frame;

- (void)flowingViewController:(UIViewController *)viewController toFrame:(CGRect)toFrame animationsBlock:(void(^)(void))animationsBlock completionBlock:(void(^)(BOOL finished))completionBlock;

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, strong, readonly) UIViewController *topViewController;

/** 每秒的移动速度，默认为640 Point
 */
@property (nonatomic) NSUInteger viewFlowingSpeed;

@property (nonatomic) CGFloat viewFlowingBoundary;

@end

/**
 实现这个协议来激活压住滑动功能
 */
@protocol GQViewController <NSObject>

@optional

/** 返回当前滑动方法的目标位置
 
 @param direction 滑动方位
 @return 目标位置
 */
- (CGRect)destinationRectForFlowDirection:(GQFlowDirection)direction;


/** 手势滑动时的UIViewController
 
 @param direction 滑动方位
 @return 滑动的视图控制器
 */
- (UIViewController *)viewControllerForFlowDirection:(GQFlowDirection)direction;


/** 滑动时是否移动到指定的位置
 
 @param frame 目标位置
 @return 是否应该滑动
 */
- (BOOL)shouldFlowToRect:(CGRect)frame;

/** 滑动手势结束
 */
- (void)didFlowToDestinationRect;

/** 触发自动滑动到目标位置的系数 
 
 @return 返回值在.0 ~ 1.0之间
 */
- (CGFloat)flowingBoundary;

/** 当滑动时是否需要缩放下层的视图
 
 @return 是否需要缩放，默认为YES
 */
- (BOOL)shouldScaleView;

/** 自定义的滑动的速度，默认640
 
 @return 滑动的速度，以每秒滑动多少点
 */
- (NSUInteger)flowingSpeed;

@end

@interface UIViewController (GQFlowControllerAdditions)

@property (nonatomic, strong, readonly) GQFlowController *flowController;

@property (nonatomic) GQFlowDirection flowInDirection;

@property (nonatomic) GQFlowDirection flowOutDirection;

@property (nonatomic, getter=isOverlayContent) BOOL overlayContent;

- (void)setShotViewScale:(CGFloat)scale;

- (void)setOverlayContent:(BOOL)yesOrNo enabledShotView:(BOOL)yesOrNoShotView;

@end