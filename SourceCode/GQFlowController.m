//
//  GQFlowController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "GQFlowController.h"
#import <objc/runtime.h>

@interface GQFlowController ()

- (void)addPressGestureRecognizerForTopView;
- (void)removeTopViewPressGestureRecognizer;

- (void)layoutFlowViews;

/** 计算移动到目标位置所需要的时间

*/
- (NSTimeInterval)durationForMovePressViewToFrame:(CGRect)aRect;

- (NSTimeInterval)durationForMoveLength:(CGFloat)length;

- (void)resetLongPressStatus;

@property (nonatomic, strong) GQViewController *topViewController;
@property (nonatomic, strong) NSMutableArray *innerViewControllers;

@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGRect originalRect;
@property (nonatomic) GQFlowDirection flowingDirection;

@property (nonatomic, strong) UILongPressGestureRecognizer *pressGestureRecognizer;

@end

@implementation GQFlowController
@dynamic viewControllers;

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    
    if (self) {
        self.viewControllers = viewControllers;
    }
    
    return self;
}

- (NSArray *)viewControllers
{
    return [self.innerViewControllers copy];
}

- (void)setViewControllers:(NSArray *)aViewControllers
{
    // 判断是否为GQViewController的子类，如不是丢弃
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [aViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if (![obj isKindOfClass:[GQViewController class]]) {
            [indexSet addIndex:idx];
        } else {
            [obj performSelector:@selector(setFlowController:)
                      withObject:self];
        }
    }];
    
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:aViewControllers];
    
    [newArray removeObjectsAtIndexes:indexSet];
    
    self.innerViewControllers = newArray;
    
    [self layoutFlowViews];
}


- (void)flowOutViewControllerAnimated:(BOOL)animated
{
    if (![NSThread isMainThread]) {
        NSLog(@"This method must in main thread");
        return;
    }
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.topViewController.view.frame = [self outDestinationRectForViewController:self.topViewController];
                     }
                     completion:^(BOOL finished){
                         [self.topViewController willMoveToParentViewController:nil];
                         [self.topViewController.view removeFromSuperview];
                         [self.topViewController removeFromParentViewController];
                         
                         [self.innerViewControllers removeLastObject];

                         [self removeTopViewPressGestureRecognizer];
                         
                         self.topViewController = [self.innerViewControllers lastObject];
                     }];
}

- (void)addViewController:(GQViewController *)viewController
{
    // 设置GQViewControllerItem
    [viewController performSelector:@selector(setFlowController:)
                         withObject:self];
    
    self.topViewController = viewController;

    [self.innerViewControllers addObject:viewController];
    
    [self addChildViewController:viewController];
    
    viewController.view.frame = [self inOriginRectForViewController:viewController];
    
    [self.view addSubview:viewController.view];
    
    [viewController didMoveToParentViewController:self];
}

- (void)flowInViewController:(GQViewController *)viewController animated:(BOOL)animated
{
    if (![NSThread isMainThread]) {
        NSLog(@"This method must in main thread");
        return;
    }
    
    // 添加到容器中，并设置将要滑入的起始位置
    [self addViewController:viewController];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         viewController.view.frame = [self inDestinationRectForViewController:viewController];
                     }
                     completion:^(BOOL finished){
                         // 添加手势
                         [self addPressGestureRecognizerForTopView];
                     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self layoutFlowViews];
}

// 将需要添加的view添加的superview中
- (void)layoutFlowViews
{
    for (GQViewController *controller in self.innerViewControllers) {
        [self addChildViewController:controller];
        
        controller.view.frame = CGRectMake(0,
                                           0,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height);
        
        [self.view addSubview:controller.view];
        
        [controller didMoveToParentViewController:self];
        
        // 默认为非激活状态
        controller.active = NO;
    }
    
    self.topViewController = [self.innerViewControllers lastObject];
    self.topViewController.active = YES;
    
    // 只有一层是不添加按住手势
    if ([self.innerViewControllers count] > 1) {
        self.topViewController = [self.innerViewControllers lastObject];
        
        [self addPressGestureRecognizerForTopView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method



- (void)resetLongPressStatus
{
    self.startPoint = CGPointZero;
    self.prevPoint = CGPointZero;
    self.originalRect = CGRectZero;
    self.flowingDirection = GQFlowDirectionUnknow;
}

- (NSTimeInterval)durationForMovePressViewToFrame:(CGRect)aRect;
{
    CGFloat range = .0;
    
    // TODO:需要处理斜线运动
//    if (self.moveViewDirection == GQFlowDirectionRight
//        || self.moveViewDirection == GQFlowDirectionLeft) {
//        range = aRect.origin.x - self.moveViewController.view.frame.origin.x;
//    } else {
//        range = aRect.origin.y - self.moveViewController.view.frame.origin.y;
//    }
    
    // 速度以0.618秒移动一屏为基准
    return 0.618 / 320.0 * ABS(range);
}

- (NSTimeInterval)durationForMoveLength:(CGFloat)length
{
    // 速度以0.618秒移动一屏为基准
    return 0.618 / 320.0 * ABS(length);
}

// 添加手势
- (void)addPressGestureRecognizerForTopView
{
    // 判断是否实现GQFlowControllerDelegate
    if (![self.topViewController conformsToProtocol:@protocol(GQFlowControllerDelegate)]) {
        return;
    }
    
    if (self.pressGestureRecognizer == nil) {
        self.pressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(pressMoveGesture)];
        self.pressGestureRecognizer.delegate = self;
        self.pressGestureRecognizer.minimumPressDuration = .0;
    }
    
    [self.topViewController.view addGestureRecognizer:self.pressGestureRecognizer];
}

- (void)removeTopViewPressGestureRecognizer
{
    // 判断是否实现GQFlowControllerDelegate
    if (![self.topViewController conformsToProtocol:@protocol(GQFlowControllerDelegate)]) {
        return;
    }
    
    if (self.pressGestureRecognizer) {
        [self.topViewController.view removeGestureRecognizer:self.pressGestureRecognizer];
    }
}

- (void)pressMoveGesture
{
    CGPoint pressPoint = [self.pressGestureRecognizer locationInView:nil];
    
    if (self.pressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // 设置初始点
        self.startPoint = pressPoint;
        self.prevPoint = pressPoint;
        
        self.topViewController.active = NO;
    } else if (self.pressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // 判断移动的视图
        if (self.flowingDirection == GQFlowDirectionUnknow) {            
            // 判断移动的方向
            CGFloat x = pressPoint.x - self.startPoint.x;
            CGFloat y = pressPoint.y - self.startPoint.y;
            
            if (ABS(x) > ABS(y)) {
                if (x > .0) {
                    self.flowingDirection = GQFlowDirectionRight;
                } else {
                    self.flowingDirection = GQFlowDirectionLeft;
                }
            } else {
                if (y > .0) {
                    self.flowingDirection = GQFlowDirectionUp;
                } else {
                    self.flowingDirection = GQFlowDirectionDown;
                }
            }

            // 移动的View可能不是Top View
            if ([self.topViewController respondsToSelector:@selector(flowController:viewControllerForFlowDirection:)]) {
                GQViewController *controller = [(id<GQFlowControllerDelegate>)self.topViewController flowController:self
                                                                                     viewControllerForFlowDirection:self.flowingDirection];
                
                // 判断是否实现GQFlowControllerDelegate
                if (![controller conformsToProtocol:@protocol(GQFlowControllerDelegate)]) {
                    NSLog(@"滑出其它的控制器必须实现GQFlowControllerDelegate");
                } else {
                    // 校验不是topViewController，并添加到容器中
                    if (controller != self.topViewController) {
                        // 这个代码可以合成一步
                        [self addViewController:controller];
                    }
                }
            }
            
            // 记录移动视图的原始位置
            self.originalRect = self.topViewController.view.frame;
        }

        CGRect newFrame = CGRectZero;
        
        if (self.flowingDirection == GQFlowDirectionLeft
            || self.flowingDirection == GQFlowDirectionRight) {
            CGFloat x = pressPoint.x - self.prevPoint.x;
            
            newFrame = CGRectOffset(self.topViewController.view.frame, x, .0);
        } else if (self.flowingDirection == GQFlowDirectionUp
                   || self.flowingDirection == GQFlowDirectionDown) {
            CGFloat y = pressPoint.y - self.prevPoint.y;
            newFrame = CGRectOffset(self.topViewController.view.frame, .0, y);
        }
        
        // 能否移动
        BOOL shouldMove = YES;
        
        if ([self.topViewController respondsToSelector:@selector(flowController:shouldFlowToRect:)]) {
            shouldMove = [(id<GQFlowControllerDelegate>)self.topViewController flowController:self
                                                                             shouldFlowToRect:newFrame];
        }
        
        if (shouldMove) {
            self.topViewController.view.frame = newFrame;
        }
        
        // 记住上一个点
        self.prevPoint = pressPoint;
    } else if (self.pressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // 如果没有发生移动就什么也不做
        if (CGPointEqualToPoint(self.startPoint, self.prevPoint)) {
            // 重置长按状态信息
            [self resetLongPressStatus];
            
            self.topViewController.active = YES;
            
            return;
        }
        
        CGRect destinationRect = CGRectZero;
        
        if ([self.topViewController respondsToSelector:@selector(flowController:destinationRectForFlowDirection:)]) {
            destinationRect = [(id<GQFlowControllerDelegate>)self.topViewController flowController:self
                                                         destinationRectForFlowDirection:self.flowingDirection];
        } else {
            BOOL cancelFlowing = NO; // 是否需要取消回退滑动
            
            if ([self.topViewController respondsToSelector:@selector(boundaryFlowController:)]) {
                CGFloat boundary = [(id<GQFlowControllerDelegate>)self.topViewController boundaryFlowController:self];

                if (boundary > .0
                    && boundary < 1.0) {
                    CGFloat length = .0;
                    
                    // 计算移动的距离
                    if (self.flowingDirection == GQFlowDirectionLeft
                        || self.flowingDirection == GQFlowDirectionRight) {
                        length = pressPoint.x - self.startPoint.x;
                    } else if (self.flowingDirection == GQFlowDirectionUp
                               || self.flowingDirection == GQFlowDirectionDown) {
                        length = pressPoint.y - self.startPoint.y;
                    }
                    
                    // 如果移动的距离没有超过边界值，则回退到原始位置
                    if (length <= self.topViewController.view.frame.size.width * boundary) {
                        cancelFlowing = YES;
                    }
                }
            }
            
            if (cancelFlowing) {
                // 回退到事件开始的rect
                destinationRect = self.originalRect;
            } else {
                if (self.flowingDirection == self.topViewController.inFlowDirection) {                    
                    destinationRect = [self inDestinationRectForViewController:self.topViewController];
                }
                
                // 如果in和out是同一方向，则以out为主
                if (self.flowingDirection == self.topViewController.outFlowDirection) {         
                    destinationRect = [self outDestinationRectForViewController:self.topViewController];
                }
            }
        }

        [UIView animateWithDuration:0.5
                         animations:^{
                             self.topViewController.view.frame = destinationRect;
                         }
                         completion:^(BOOL finished){                                 
                             self.topViewController.active = YES;
                             
                             if ([self.topViewController respondsToSelector:@selector(didFlowToDestinationRect:)]) {
                                 [(id<GQFlowControllerDelegate>)self.topViewController didFlowToDestinationRect:self];
                             }
                             
                             // 重置长按状态信息
                             [self resetLongPressStatus];
                             
                             // 怎样移除滑出的top view controller
                         }];

    }
    
    NSLog(@"%f", pressPoint.x);
}

// 滑入的起初位置
- (CGRect)inOriginRectForViewController:(GQViewController *)viewController
{
    CGRect viewFrame = viewController.view.frame;
    
    CGRect originFrame = CGRectZero;
    
    switch (viewController.inFlowDirection) {
        case GQFlowDirectionLeft:
            originFrame = CGRectMake(self.view.frame.size.width,
                                     viewFrame.origin.y,
                                     viewFrame.size.width,
                                     viewFrame.size.height);
            break;
        case GQFlowDirectionRight:
            originFrame = CGRectMake(-viewFrame.size.width,
                                     viewFrame.origin.y,
                                     viewFrame.size.width,
                                     viewFrame.size.height);
            break;
        case GQFlowDirectionUp:
            originFrame = CGRectMake(viewFrame.origin.x,
                                     self.view.frame.size.height,
                                     viewFrame.size.width,
                                     viewFrame.size.height);
            break;
        case GQFlowDirectionDown:
            originFrame = CGRectMake(viewFrame.origin.x,
                                     -viewFrame.size.height,
                                     viewFrame.size.width,
                                     viewFrame.size.height);
            break;
        default:
            originFrame = viewFrame;
            break;
    }
    
    return originFrame;
}

// 滑入的目标位置
- (CGRect)inDestinationRectForViewController:(GQViewController *)viewController
{
    CGRect viewFrame = viewController.view.frame;
    CGRect destinationFrame = CGRectZero;
    
    switch (viewController.inFlowDirection) {
        case GQFlowDirectionLeft:
            destinationFrame = CGRectMake(self.view.frame.size.width - viewFrame.size.width,
                                          viewFrame.origin.y,
                                          viewFrame.size.width,
                                          viewFrame.size.height);
            break;
        case GQFlowDirectionRight:
            destinationFrame = CGRectMake(.0,
                                          viewFrame.origin.y,
                                          viewFrame.size.width,
                                          viewFrame.size.height);
            break;
        case GQFlowDirectionUp:
            destinationFrame = CGRectMake(viewFrame.origin.x,
                                          self.view.frame.size.height - viewFrame.size.height,
                                          viewFrame.size.width,
                                          viewFrame.size.height);
            break;
        case GQFlowDirectionDown:
            destinationFrame = CGRectMake(viewFrame.origin.x,
                                          .0,
                                          viewFrame.size.width,
                                          viewFrame.size.height);
            break;
        default:
            destinationFrame = viewFrame;
            break;
    }
    
    return destinationFrame;
}

//// 滑出的默认初始位置
//- (CGRect)outOriginRectForViewController:(GQViewController *)viewController
//{
//    CGRect viewFrame = viewController.view.frame;
//    CGRect originFrame = CGRectZero;
//    
//    return originFrame;
//}

// 滑出的目标位置、任意位置都能滑出
- (CGRect)outDestinationRectForViewController:(GQViewController *)viewController
{
    CGRect viewFrame = viewController.view.frame;
    CGRect destinationFrame = CGRectZero;
    
    switch (viewController.outFlowDirection) {
        case GQFlowDirectionLeft:
            destinationFrame = CGRectMake(-viewFrame.size.width,
                                          viewFrame.origin.y,
                                          viewFrame.size.width,
                                          viewFrame.size.height);
            break;
        case GQFlowDirectionRight:
            destinationFrame = CGRectMake(self.view.frame.size.width,
                                          viewFrame.origin.y,
                                          viewFrame.size.width,
                                          viewFrame.size.height);
            
            break;
        case GQFlowDirectionUp:
            destinationFrame = CGRectMake(viewFrame.origin.x,
                                          -viewFrame.size.height,
                                          viewFrame.size.width,
                                          viewFrame.size.height);
            break;
        case GQFlowDirectionDown:
            destinationFrame = CGRectMake(viewFrame.origin.x,
                                          self.view.frame.size.height,
                                          viewFrame.size.width,
                                          viewFrame.size.height);
            break;
        default:
            destinationFrame = viewFrame;
            break;
    }
    
    return destinationFrame;
}

#pragma mark - UIGestureRecognizerDelegate Protocol

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.topViewController.view == touch.view) {
        return YES;
    } else {
        return NO;
    }
}

@end

#pragma mark - GQViewControllerItem Category

static char kGQFlowControllerObjectKey;

@implementation GQViewController (GQViewControllerItem)

@dynamic flowController;

- (GQFlowController *)flowController
{    
    return (GQFlowController *)objc_getAssociatedObject(self, &kGQFlowControllerObjectKey);
}

- (void)setFlowController:(GQFlowController *)flowController
{
    objc_setAssociatedObject(self, &kGQFlowControllerObjectKey, flowController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

