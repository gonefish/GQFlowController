//
//  GQFlowController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "GQFlowController.h"
#import <objc/runtime.h>

BOOL checkIsMainThread() {
    BOOL rel = [NSThread isMainThread];

    if (!rel) {
        NSLog(@"This method must in main thread");
    }
    
    return rel;
}

@interface GQFlowController ()

@property (nonatomic, strong) GQViewController *topViewController;
@property (nonatomic, strong) NSMutableArray *innerViewControllers;

@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) GQFlowDirection flowingDirection;

@property (nonatomic, strong) UILongPressGestureRecognizer *pressGestureRecognizer;

@end

@implementation GQFlowController
@dynamic viewControllers;

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self layoutFlowViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Method

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    
    if (self) {
        self.innerViewControllers = [NSMutableArray arrayWithArray:viewControllers];
        
        self.topViewController = [self.innerViewControllers lastObject];
    }
    
    return self;
}

- (id)initWithRootViewController:(GQViewController *)rootViewController
{
    return [self initWithViewControllers:@[rootViewController]];
}

- (void)flowInViewController:(GQViewController *)viewController animated:(BOOL)animated
{
    if (!checkIsMainThread()) return;
    
    // 添加到容器中，并设置将要滑入的起始位置
    [self addTopViewController:viewController];
    
    CGRect destinationFrame = [self inDestinationRectForViewController:viewController];
    
    CGFloat duration = .0;
    
    if (animated) {
        duration = [self durationForOriginalRect:viewController.view.frame
                                 destinationRect:destinationFrame
                                flowingDirection:self.topViewController.inFlowDirection];
    }
    
    [UIView animateWithDuration:duration
                     animations:^{
                         viewController.view.frame = destinationFrame;
                     }
                     completion:^(BOOL finished){
                         // 添加手势
                         [self addPressGestureRecognizerForTopView];
                     }];
}

- (GQViewController *)flowOutViewControllerAnimated:(BOOL)animated
{
    if ([self.innerViewControllers count] > 1) {
        NSArray *popViewControllers = [self flowOutIndexSet:[NSIndexSet indexSetWithIndex:[self.innerViewControllers count] -1]
                                                   animated:animated];
        if ([popViewControllers count] == 1) {
            return [popViewControllers objectAtIndex:0];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (NSArray *)flowOutToRootViewControllerAnimated:(BOOL)animated
{
    if ([self.innerViewControllers count] > 1) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [self.innerViewControllers count] - 1)];
        
        return [self flowOutIndexSet:indexSet
                            animated:animated];
    } else {
        return nil;
    }
}

- (NSArray *)flowOutToViewController:(GQViewController *)viewController animated:(BOOL)animated
{
    __block NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [self.innerViewControllers enumerateObjectsWithOptions:NSEnumerationReverse
                                                usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                                                    if (obj == viewController) {
                                                        *stop = YES;
                                                    } else {
                                                        [indexSet addIndex:idx];
                                                    }
                                                }];
    
    if ([self.innerViewControllers count] > 0) {
        return [self flowOutIndexSet:indexSet
                            animated:animated];
    } else {
        return nil;
    }
}

- (NSArray *)viewControllers
{
    return [self.innerViewControllers copy];
}

- (void)setViewControllers:(NSArray *)aViewControllers
{
    [self setViewControllers:aViewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    if (!checkIsMainThread()) return;
    
    // 判断是否为GQViewController的子类，如不是丢弃
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if (![obj isKindOfClass:[GQViewController class]]) {
            [indexSet addIndex:idx];
        } else {
            [obj performSelector:@selector(setFlowController:)
                      withObject:self];
        }
    }];
    
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:viewControllers];
    
    [newArray removeObjectsAtIndexes:indexSet];
    
    GQViewController *topmostViewController = [newArray lastObject];
    
    if (animated) {
        if ([self.innerViewControllers containsObject:topmostViewController]) {
            if (topmostViewController == [self.innerViewControllers lastObject]) {
                // No change
                for (GQViewController *vc in self.innerViewControllers) {
                    if (vc != topmostViewController) {
                        [vc.view removeFromSuperview];
                    }
                }
                
                self.innerViewControllers = newArray;
                
                self.topViewController = topmostViewController;
                
                [self layoutViewControllers];
            } else {
                // Flow Out
                for (GQViewController *vc in self.innerViewControllers) {
                    if (vc != [self.innerViewControllers lastObject]) {
                        [vc.view removeFromSuperview];
                    }
                }
                
                [newArray addObject:[self.innerViewControllers lastObject]];
                
                self.innerViewControllers = newArray;
                
                [self layoutViewControllers];
                
                [self flowOutViewControllerAnimated:YES];
            }
        } else {
            // Flow In
            [self addTopViewController:topmostViewController];
            
            CGRect destinationFrame = [self inDestinationRectForViewController:topmostViewController];
            
            CGFloat duration = [self durationForOriginalRect:topmostViewController.view.frame
                                             destinationRect:destinationFrame
                                            flowingDirection:self.topViewController.inFlowDirection];
            
            [UIView animateWithDuration:duration
                             animations:^{
                                 topmostViewController.view.frame = destinationFrame;
                             }
                             completion:^(BOOL finished){
                                 // 添加手势
                                 [self addPressGestureRecognizerForTopView];
                                 
                                 // 处理控制器
                                 for (GQViewController *vc in self.innerViewControllers) {
                                     if (vc != [self.innerViewControllers lastObject]) {
                                         [vc.view removeFromSuperview];
                                     }
                                 }
                                 
                                 self.innerViewControllers = newArray;
                                 
                                 [self layoutViewControllers];
                             }];
        }
    } else {
        for (GQViewController *vc in self.innerViewControllers) {
            [vc.view removeFromSuperview];
        }
        
        self.innerViewControllers = newArray;
        
        self.topViewController = topmostViewController;
        
        [self layoutViewControllers];
    }
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

#pragma mark - Private Method

- (NSMutableArray *)innerViewControllers
{
    if (_innerViewControllers == nil) {
        _innerViewControllers = [NSMutableArray array];
    }
    
    return _innerViewControllers;
}



- (NSArray *)flowOutIndexSet:(NSIndexSet *)indexSet animated:(BOOL)animated
{
    if (!checkIsMainThread()) return nil;
    
    NSArray *popViewControllers = [self.innerViewControllers objectsAtIndexes:indexSet];
    
    [popViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // 设置GQViewController的flowController属性为nil
        [obj performSelector:@selector(setFlowController:)
                  withObject:nil];
        
        // 如果不是topViewController则移除视图
        if (obj != self.topViewController) {
            if ([(GQViewController *)obj isViewLoaded]) {
                [[(GQViewController *)obj view] removeFromSuperview];
            }
        }
    }];
    
    [self.innerViewControllers removeObjectsAtIndexes:indexSet];
    
    if ([self.topViewController isViewLoaded]) {
        CGRect destinationFrame = [self outDestinationRectForViewController:self.topViewController];
        
        CGFloat duration = .0;
        
        if (animated) {
            duration = [self durationForOriginalRect:self.topViewController.view.frame
                                     destinationRect:destinationFrame
                                    flowingDirection:self.topViewController.outFlowDirection];
        }
        
        [UIView animateWithDuration:duration
                         animations:^{
                             self.topViewController.view.frame = [self outDestinationRectForViewController:self.topViewController];
                         }
                         completion:^(BOOL finished){
                             [self removeTopViewController];
                             
                             [self addPressGestureRecognizerForTopView];
                         }];
    }
    
    return popViewControllers;
}



- (void)layoutViewControllers
{
    for (GQViewController *controller in self.innerViewControllers) {
        [self.view addSubview:controller.view];
    }
}

// 将需要添加的view添加的superview中
- (void)layoutFlowViews
{
    for (GQViewController *controller in self.innerViewControllers) {
        //[self addChildViewController:controller];
        
        controller.view.frame = CGRectMake(0,
                                           0,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height);
        
        [self.view addSubview:controller.view];
        
        //[controller didMoveToParentViewController:self];
        
        // 默认为非激活状态
        controller.active = NO;
    }
    
    self.topViewController.active = YES;
    
    // 只有一层是不添加按住手势
    if ([self.innerViewControllers count] > 1) {
        self.topViewController = [self.innerViewControllers lastObject];
        
        [self addPressGestureRecognizerForTopView];
    }
}

- (void)addTopViewController:(GQViewController *)viewController
{
    // 设置GQViewControllerItem
    [viewController performSelector:@selector(setFlowController:)
                         withObject:self];
    
    self.topViewController = viewController;
    
    [self.innerViewControllers addObject:viewController];
    
    //[self addChildViewController:viewController];
    
    viewController.view.frame = [self inOriginRectForViewController:viewController];
    
    [self.view addSubview:viewController.view];
    
    //[viewController didMoveToParentViewController:self];
}

- (void)removeTopViewController
{
    [self removeTopViewPressGestureRecognizer];
    
    //[self.topViewController willMoveToParentViewController:nil];
    
    [self.topViewController.view removeFromSuperview];
    
    //[self.topViewController removeFromParentViewController];
    
    self.topViewController = [self.innerViewControllers lastObject];
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

- (void)resetLongPressStatus
{
    self.startPoint = CGPointZero;
    self.prevPoint = CGPointZero;
    self.originalFrame = CGRectZero;
    self.flowingDirection = GQFlowDirectionUnknow;
}

- (NSTimeInterval)durationForOriginalRect:(CGRect)originalFrame destinationRect:(CGRect)destinationFrame flowingDirection:(GQFlowDirection)flowingDirection
{    
    CGFloat length = .0;
    
    if (flowingDirection == GQFlowDirectionLeft
        || flowingDirection == GQFlowDirectionRight) {
        length = destinationFrame.origin.x - originalFrame.origin.x;
    } else if (flowingDirection == GQFlowDirectionUp
               && flowingDirection == GQFlowDirectionDown){
        length = destinationFrame.origin.y - destinationFrame.origin.y;
    }
    
    // 速度以0.618秒移动一屏为基准
    return 0.00193 * ABS(length);
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
                        [self addTopViewController:controller];
                    }
                }
            }
            
            // 记录移动视图的原始位置
            self.originalFrame = self.topViewController.view.frame;
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
        BOOL shouldMove = NO;
        
        if (self.flowingDirection == self.topViewController.inFlowDirection
            || self.flowingDirection == self.topViewController.outFlowDirection) {
            shouldMove = YES;
        }

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
        
        // 默认为原始位置
        CGRect destinationFrame = self.originalFrame;
        
        BOOL cancelFlowing = NO; // 是否需要取消回退滑动
        
        if ([self.topViewController respondsToSelector:@selector(flowController:destinationRectForFlowDirection:)]) {
            destinationFrame = [(id<GQFlowControllerDelegate>)self.topViewController flowController:self
                                                         destinationRectForFlowDirection:self.flowingDirection];
            
            if (CGRectEqualToRect(CGRectZero, destinationFrame)) {
                cancelFlowing = YES;
            }
        } else {
            if ([self.topViewController respondsToSelector:@selector(flowingBoundary:)]) {
                CGFloat boundary = [(id<GQFlowControllerDelegate>)self.topViewController flowingBoundary:self];

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
                    if (ABS(length) <= self.topViewController.view.frame.size.width * boundary) {
                        cancelFlowing = YES;
                    }
                }
            }
            
            if (!cancelFlowing) {
                if (self.flowingDirection == self.topViewController.inFlowDirection) {                    
                    destinationFrame = [self inDestinationRectForViewController:self.topViewController];
                }
                
                // 如果in和out是同一方向，则以out为主
                if (self.flowingDirection == self.topViewController.outFlowDirection) {         
                    destinationFrame = [self outDestinationRectForViewController:self.topViewController];
                }
            }
        }
        
        CGFloat duration = [self durationForOriginalRect:self.topViewController.view.frame
                                         destinationRect:destinationFrame
                                        flowingDirection:self.flowingDirection];

        [UIView animateWithDuration:duration
                         animations:^{
                             self.topViewController.view.frame = destinationFrame;
                         }
                         completion:^(BOOL finished){                                 
                             if ([self.topViewController respondsToSelector:@selector(didFlowToDestinationRect:)]) {
                                 [(id<GQFlowControllerDelegate>)self.topViewController didFlowToDestinationRect:self];
                             }

                             // 没有取消回滑
                             if (!cancelFlowing) {
                                 if (self.flowingDirection == self.topViewController.outFlowDirection) {
                                     if (!CGRectIntersectsRect(self.view.frame, self.topViewController.view.frame)) {
                                         [self removeTopViewController];
                                         
                                         [self addPressGestureRecognizerForTopView];
                                     }
                                 } else if (self.flowingDirection == self.topViewController.inFlowDirection) {
                                     if (CGRectIntersectsRect(self.view.frame, self.topViewController.view.frame)) {
                                         [self addPressGestureRecognizerForTopView];
                                     }
                                 }
                             }

                             self.topViewController.active = YES;
                             
                             // 重置长按状态信息
                             [self resetLongPressStatus];
                         }];
    }
    
    NSLog(@"%f", pressPoint.x);
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

