//
//  GQFlowController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
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

@property (nonatomic, strong) UIViewController *topViewController;
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
    CGRect initFrame = [[UIScreen mainScreen] bounds];

    if (self.wantsFullScreenLayout == NO) {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        initFrame = CGRectMake(.0,
                               statusBarFrame.size.height,
                               initFrame.size.width,
                               initFrame.size.height - statusBarFrame.size.height);
    }
    
    self.view = [[UIView alloc] initWithFrame:initFrame];
    self.view.backgroundColor = [UIColor whiteColor];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //[self layoutViewControllers];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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
        self.viewControllers = viewControllers;
    }
    
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    return [self initWithViewControllers:@[rootViewController]];
}

- (void)flowInViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[GQFlowController class]]) {
        return;
    }
    
    viewController.overlayContent = YES;
    
    [self flowInViewController:viewController
                      animated:animated
               completionBlock:^{
                   // 添加手势
                   [self addPressGestureRecognizerForTopView];
                   
                   viewController.overlayContent = NO;
               }];
}

- (UIViewController *)flowOutViewControllerAnimated:(BOOL)animated
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

- (NSArray *)flowOutToViewController:(UIViewController *)viewController animated:(BOOL)animated
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
    
    // 判断是否为UIViewController的子类，如不是丢弃
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if (![obj isKindOfClass:[UIViewController class]]) {
            [indexSet addIndex:idx];
        } else {
            [obj performSelector:@selector(setFlowController:)
                      withObject:self];
        }
    }];
    
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:viewControllers];
    
    [newArray removeObjectsAtIndexes:indexSet];
    
    if (animated) {
        if ([self.innerViewControllers containsObject:[newArray lastObject]]) {
            if ([newArray lastObject] == [self.innerViewControllers lastObject]) {
                // No Animate
                [self holdViewControllers:@[[newArray lastObject]]];
                
                [self updateChildViewControllers:newArray];
                
                [self addPressGestureRecognizerForTopView];
            } else {
                // Flow Out
                // 保留最上面的视图控制器
                [self holdViewControllers:@[[self.innerViewControllers lastObject]]];
                
                [newArray addObject:[self.innerViewControllers lastObject]];
                
                [self updateChildViewControllers:newArray];
                
                [self flowOutViewControllerAnimated:YES];
            }
        } else {
            // Flow In
            
            // 保留最上层的视图控制器
            UIViewController *topmostViewController = [self.innerViewControllers lastObject];
            
            [self holdViewControllers:@[topmostViewController]];
            
            // 重构层级中的视图控制器
            UIViewController *flowInViewController = [newArray lastObject];
            
            [newArray removeLastObject];
            
            [newArray addObject:topmostViewController];
            
            [self updateChildViewControllers:newArray];
            
            [self flowInViewController:flowInViewController
                              animated:animated
                       completionBlock:^(){
                           // 添加手势
                           [self addPressGestureRecognizerForTopView];
                           
                           // 移除原最上层的视图控制器
                           [self removeContentViewControler:topmostViewController];
                           
                           [self.innerViewControllers removeObject:topmostViewController];
            }];
        }
    } else {
        // 移除现在的视图控制器
        [self holdViewControllers:nil];
        
        [self updateChildViewControllers:newArray];
        
        [self addPressGestureRecognizerForTopView];
    }
}

#pragma mark - UIGestureRecognizerDelegate Protocol

#pragma mark - UIViewController Container Method

- (void)holdViewControllers:(NSArray *)viewControllers
{
    // 移除没有指定的视图控制器
    for (UIViewController *vc in self.innerViewControllers) {
        if (viewControllers == nil
            || ![viewControllers containsObject:vc]) {
            [self removeContentViewControler:vc];
        }
    }
}

- (void)addContentViewController:(UIViewController *)viewController
{
    [self addChildViewController:viewController];
    
    [self.view addSubview:viewController.view];
    
    [viewController didMoveToParentViewController:self];
}

- (void)removeContentViewControler:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    
    [viewController.view removeFromSuperview];
    
    [viewController removeFromParentViewController];
}

/**
 更新子控制器
 */
- (void)updateChildViewControllers:(NSMutableArray *)viewControllers
{
    for (UIViewController *vc in viewControllers) {
        [self addContentViewController:vc];
    }
    
    self.innerViewControllers = viewControllers;
    
    self.topViewController = [viewControllers lastObject];
}

- (void)addTopViewController:(UIViewController *)viewController
{
    // 设置UIViewControllerItem
    [viewController performSelector:@selector(setFlowController:)
                         withObject:self];
    
    self.topViewController = viewController;
    
    [self.innerViewControllers addObject:viewController];
    
    [self addChildViewController:viewController];
    
    viewController.view.frame = [self inOriginRectForViewController:viewController];
    
    [self.view addSubview:viewController.view];
    
    [viewController didMoveToParentViewController:self];
}

- (void)removeTopViewController
{
    [self removeTopViewPressGestureRecognizer];
    
    [self.topViewController willMoveToParentViewController:nil];
    
    [self.topViewController.view removeFromSuperview];
    
    [self.topViewController removeFromParentViewController];
    
    // 不自己删除lastObject是因为确保viewControllers被设置时的正确性
    self.topViewController = [self.innerViewControllers lastObject];
}

#pragma mark - Other Method

- (NSMutableArray *)innerViewControllers
{
    if (_innerViewControllers == nil) {
        _innerViewControllers = [NSMutableArray array];
    }
    
    return _innerViewControllers;
}

- (void)flowInViewController:(UIViewController *)viewController animated:(BOOL)animated completionBlock:(void (^)(void))block
{
    if (!checkIsMainThread()) return;
    
    // 添加到容器中，并设置将要滑入的起始位置
    [self addTopViewController:viewController];
    
    CGRect destinationFrame = [self inDestinationRectForViewController:viewController];
    
    CGFloat duration = .0;
    
    if (animated) {
        duration = [self durationForOriginalRect:viewController.view.frame
                                 destinationRect:destinationFrame
                                flowingDirection:self.topViewController.flowInDirection];
    }
    
    [UIView animateWithDuration:duration
                     animations:^{
                         viewController.view.frame = destinationFrame;
                     }
                     completion:^(BOOL finished){
                         block();
                     }];
}


- (NSArray *)flowOutIndexSet:(NSIndexSet *)indexSet animated:(BOOL)animated
{
    if (!checkIsMainThread()) return nil;
    
    // 准备移除控制器
    NSArray *popViewControllers = [self.innerViewControllers objectsAtIndexes:indexSet];
    
    for (UIViewController *vc in popViewControllers) {
        // 设置UIViewController的flowController属性为nil
        [vc performSelector:@selector(setFlowController:)
                  withObject:nil];
        
        // 如果不是topViewController则移除视图
        if (vc != self.topViewController) {
            [vc willMoveToParentViewController:nil];
            
            [vc.view removeFromSuperview];
            
            [vc removeFromParentViewController];
        }
    }
    
    [self.innerViewControllers removeObjectsAtIndexes:indexSet];
    
    //if ([self.topViewController isViewLoaded]) {
        CGRect destinationFrame = [self outDestinationRectForViewController:self.topViewController];
        
        CGFloat duration = .0;
        
        if (animated) {
            duration = [self durationForOriginalRect:self.topViewController.view.frame
                                     destinationRect:destinationFrame
                                    flowingDirection:self.topViewController.flowOutDirection];
        }
    
    self.topViewController.overlayContent = YES;
    
        [UIView animateWithDuration:duration
                         animations:^{
                             self.topViewController.view.frame = [self outDestinationRectForViewController:self.topViewController];
                         }
                         completion:^(BOOL finished){
                             [self removeTopViewController];
                             
                             [self addPressGestureRecognizerForTopView];
                         }];
    //}
    
    return popViewControllers;
}



/**
 重新对视图进行布局
 */
- (void)layoutViewControllers
{
    for (UIViewController *controller in self.innerViewControllers) {
        [self.view addSubview:controller.view];
    }
}



// 滑入的起初位置
- (CGRect)inOriginRectForViewController:(UIViewController *)viewController
{
    CGRect viewFrame = viewController.view.frame;
    
    CGRect originFrame = CGRectZero;
    
    switch (viewController.flowInDirection) {
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
- (CGRect)inDestinationRectForViewController:(UIViewController *)viewController
{
    CGRect viewFrame = viewController.view.frame;
    CGRect destinationFrame = CGRectZero;
    
    switch (viewController.flowInDirection) {
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
//- (CGRect)outOriginRectForViewController:(UIViewController *)viewController
//{
//    CGRect viewFrame = viewController.view.frame;
//    CGRect originFrame = CGRectZero;
//
//    return originFrame;
//}

// 滑出的目标位置、任意位置都能滑出
- (CGRect)outDestinationRectForViewController:(UIViewController *)viewController
{
    CGRect viewFrame = viewController.view.frame;
    CGRect destinationFrame = CGRectZero;
    
    switch (viewController.flowOutDirection) {
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
    
    // 速度以0.5秒移动一屏为基准
    return 0.00156 * ABS(length);
}

// 添加手势
- (void)addPressGestureRecognizerForTopView
{
    // 判断是否实现GQFlowControllerDelegate
    if (![self.topViewController conformsToProtocol:@protocol(GQViewControllerDelegate)]) {
        return;
    }
    
    // 仅有1个视图控制器时总是不添加手势
    if ([self.viewControllers count] < 2) {
        return;
    }
    
    if (self.pressGestureRecognizer == nil) {
        self.pressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(pressMoveGesture)];
        self.pressGestureRecognizer.delegate = self;
        self.pressGestureRecognizer.minimumPressDuration = .0;
        self.pressGestureRecognizer.cancelsTouchesInView = NO;
    }
    
    [self.topViewController.view addGestureRecognizer:self.pressGestureRecognizer];
}

- (void)removeTopViewPressGestureRecognizer
{
    // 判断是否实现GQFlowControllerDelegate
    if (![self.topViewController conformsToProtocol:@protocol(GQViewControllerDelegate)]) {
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
        
        // 滑动时激活遮罩层
        self.topViewController.overlayContent = YES;
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
                UIViewController *controller = [(id<GQViewControllerDelegate>)self.topViewController flowController:self
                                                                                     viewControllerForFlowDirection:self.flowingDirection];
                
                // 判断是否实现GQFlowControllerDelegate
                if (![controller conformsToProtocol:@protocol(GQViewControllerDelegate)]) {
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

        if ([self.topViewController respondsToSelector:@selector(flowController:shouldFlowToRect:)]) {
            shouldMove = [(id<GQViewControllerDelegate>)self.topViewController flowController:self
                                                                             shouldFlowToRect:newFrame];
        } else {
            // 仅仅允许设置的移动方位
            if (self.flowingDirection == self.topViewController.flowInDirection
                || self.flowingDirection == self.topViewController.flowOutDirection) {
                shouldMove = YES;
            }
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
            

            self.topViewController.overlayContent = NO;

            return;
        }
        
        // 默认为原始位置
        CGRect destinationFrame = self.originalFrame;
        
        BOOL cancelFlowing = NO; // 是否需要取消回退滑动
        
        if ([self.topViewController respondsToSelector:@selector(flowController:destinationRectForFlowDirection:)]) {
            // 自定义视图控制器最终停止移动的位置
            destinationFrame = [(id<GQViewControllerDelegate>)self.topViewController flowController:self
                                                         destinationRectForFlowDirection:self.flowingDirection];
            
            if (CGRectEqualToRect(CGRectZero, destinationFrame)) {
                cancelFlowing = YES;
                
                destinationFrame = self.originalFrame;
            }
        } else {
            if ([self.topViewController respondsToSelector:@selector(flowingBoundary:)]) {
                CGFloat boundary = [(id<GQViewControllerDelegate>)self.topViewController flowingBoundary:self];

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
                if (self.flowingDirection == self.topViewController.flowInDirection) {                    
                    destinationFrame = [self inDestinationRectForViewController:self.topViewController];
                }
                
                // 如果in和out是同一方向，则以out为主
                if (self.flowingDirection == self.topViewController.flowOutDirection) {         
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
                                 [(id <GQViewControllerDelegate>)self.topViewController didFlowToDestinationRect:self];
                             }
                             
                             if (![self.topViewController respondsToSelector:@selector(flowController:destinationRectForFlowDirection:)]) {

                                 // 如果topViewController已经移出窗口，则进行删除操作
                                 if (!CGRectIntersectsRect(self.view.frame, self.topViewController.view.frame)) {
                                     [self.innerViewControllers removeLastObject];
                                     
                                     [self removeTopViewController];
                                 }
                                 
                                 self.topViewController.overlayContent = NO;
                             }
                             
                             // 重新添加top view的手势
                             [self addPressGestureRecognizerForTopView];
                             
                             // 重置长按状态信息
                             [self resetLongPressStatus];
                         }];
    }
}

@end

#pragma mark - GQFlowController Category

static char kGQFlowControllerObjectKey;
static char kGQFlowInDirectionObjectKey;
static char kGQFlowOutDirectionObjectKey;
static char kQGOverlayContentObjectKey;
static char kQGOverlayViewObjectKey;

@implementation UIViewController (GQViewController)

@dynamic flowController;
@dynamic flowInDirection;
@dynamic flowOutDirection;
@dynamic overlayContent;

- (GQFlowController *)flowController
{    
    return (GQFlowController *)objc_getAssociatedObject(self, &kGQFlowControllerObjectKey);
}

- (void)setFlowController:(GQFlowController *)flowController
{
    objc_setAssociatedObject(self, &kGQFlowControllerObjectKey, flowController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GQFlowDirection)flowInDirection
{
    NSNumber *direction = (NSNumber *)objc_getAssociatedObject(self, &kGQFlowInDirectionObjectKey);
    
    if (direction == nil) {
        self.flowInDirection = GQFlowDirectionLeft;
        
        direction = [NSNumber numberWithInt:GQFlowDirectionLeft];
    }
    
    return [direction intValue];
}

- (void)setFlowInDirection:(GQFlowDirection)flowInDirection
{
    objc_setAssociatedObject(self, &kGQFlowInDirectionObjectKey, [NSNumber numberWithInt:flowInDirection], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GQFlowDirection)flowOutDirection
{
    NSNumber *direction = (NSNumber *)objc_getAssociatedObject(self, &kGQFlowOutDirectionObjectKey);
    
    if (direction == nil) {
        self.flowOutDirection = GQFlowDirectionRight;
        
        direction = [NSNumber numberWithInt:GQFlowDirectionRight];
    }
    
    return [direction intValue];
}

- (void)setFlowOutDirection:(GQFlowDirection)flowOutDirection
{
    objc_setAssociatedObject(self, &kGQFlowOutDirectionObjectKey, [NSNumber numberWithInt:flowOutDirection], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setOverlayContent:(BOOL)yesOrNo
{
    if (self.isOverlayContent == yesOrNo) {
        return;
    }
    
    objc_setAssociatedObject(self, &kQGOverlayContentObjectKey, [NSNumber numberWithInt:yesOrNo], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIView *overlayView = objc_getAssociatedObject(self, &kQGOverlayViewObjectKey);
    
    if (overlayView == nil) {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
//        [(UIView *)overlayView setBackgroundColor:[UIColor redColor]];
//        [(UIView *)overlayView setAlpha:.5];
        
        objc_setAssociatedObject(self, &kQGOverlayViewObjectKey, overlayView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if (yesOrNo) {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [self.view.layer renderInContext:context];
        
        UIImage *contentShot = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        UIImageView* shotView = [[UIImageView alloc] initWithImage:contentShot];
        
        [overlayView addSubview:shotView];
        
        [self.view addSubview:overlayView];
    } else {
        [overlayView removeFromSuperview];
        
        [overlayView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            [(UIView *)obj removeFromSuperview];
        }];
    }
}

- (BOOL)isOverlayContent
{
    return [(NSNumber *)objc_getAssociatedObject(self, &kQGOverlayContentObjectKey) boolValue];
}

@end

