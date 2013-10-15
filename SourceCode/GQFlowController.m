//
//  GQFlowController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 Qian GuoQiang (gonefish@gmail.com). All rights reserved.
//

#import "GQFlowController.h"
#import <objc/runtime.h>

#define MASK_VIEW_ALPHA .4

@interface GQFlowController ()

@property (nonatomic, strong) UIViewController *topViewController;
@property (nonatomic, strong) NSMutableArray *innerViewControllers;

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) GQFlowDirection flowingDirection;

@property (nonatomic, strong) UIPanGestureRecognizer *pressGestureRecognizer;

@property (nonatomic) BOOL isAnimating;

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
    
    [self layoutViewControllers];
    
    [self addPressGestureRecognizerForTopView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    for (UIViewController *vc in self.innerViewControllers) {
        [self removeContentViewControler:vc];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // 安全释放已经不在显示的视图
    __block BOOL safeReleaseView = NO;
    
    __block CGRect checkFrame = CGRectZero;
    
    [self.innerViewControllers enumerateObjectsWithOptions:NSEnumerationReverse
                                                usingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop){
                                                    if (safeReleaseView) {
                                                        if (![obj isViewLoaded]) return;
                                                        
                                                        [obj.view removeFromSuperview];
                                                        
                                                        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
                                                            [obj viewWillUnload];
                                                        }
                                                        
                                                        obj.view = nil;
                                                        
                                                        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
                                                            [obj viewDidUnload];
                                                        }
                                                    } else {
                                                        CGRect viewFrame = [[(UIViewController *)obj view] frame];
                                                        
                                                        if (CGRectEqualToRect(checkFrame, CGRectZero)) {
                                                            checkFrame = viewFrame;
                                                        } else {
                                                            checkFrame = CGRectIntersection(checkFrame, viewFrame);
                                                        }
                                                        
                                                        // 检测是否遮盖住其它视图
                                                        if (CGRectContainsRect(checkFrame, self.view.bounds)) {
                                                            safeReleaseView = YES;
                                                        }
                                                    }
                                                }];
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return NO;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return YES;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.topViewController respondsToSelector:@selector(beginAppearanceTransition:animated:)]) {
        [self.topViewController beginAppearanceTransition:YES
                                                 animated:animated];
    } else {
        [self.topViewController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.topViewController respondsToSelector:@selector(endAppearanceTransition)]) {
        [self.topViewController endAppearanceTransition];
    } else {
        [self.topViewController viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.topViewController respondsToSelector:@selector(beginAppearanceTransition:animated:)]) {
        [self.topViewController beginAppearanceTransition:NO
                                                 animated:animated];
    } else {
        [self.topViewController viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([self.topViewController respondsToSelector:@selector(endAppearanceTransition)]) {
        [self.topViewController endAppearanceTransition];
    } else {
        [self.topViewController viewDidDisappear:animated];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (self.topViewController) {
        return [self.topViewController supportedInterfaceOrientations];
    } else {
        return [super supportedInterfaceOrientations];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.topViewController) {
        return [self.topViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    } else {
        return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation
                                   duration:duration];
    
    // iOS 5手动处理
    if ([[[UIDevice currentDevice] systemVersion] integerValue] == 5) {
        for (UIViewController *vc in self.innerViewControllers) {
            if ([vc shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
                [vc willRotateToInterfaceOrientation:toInterfaceOrientation
                                            duration:duration];
            }
        }
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation
                                            duration:duration];
    
    // iOS 5手动处理
    if ([[[UIDevice currentDevice] systemVersion] integerValue] == 5) {
        for (UIViewController *vc in self.innerViewControllers) {
            if ([vc shouldAutorotateToInterfaceOrientation:interfaceOrientation]) {
                [vc willAnimateRotationToInterfaceOrientation:interfaceOrientation
                                                     duration:duration];
            }
        };
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // iOS 5手动处理
    if ([[[UIDevice currentDevice] systemVersion] integerValue] == 5) {
        for (UIViewController *vc in self.innerViewControllers) {
            if ([vc shouldAutorotateToInterfaceOrientation:fromInterfaceOrientation]) {
                [vc didRotateFromInterfaceOrientation:fromInterfaceOrientation];
            }  
        };
    }
}

#pragma mark - Public Method

- (id)init
{
    self = [super init];
    
    if (self) {
        self.viewFlowingSpeed = 640;

        self.viewFlowingBoundary = 0.15;
    }
    
    return self;
}

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [self init];
    
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
    NSAssert([NSThread isMainThread], @"必须在主线程调用");
    
    if ([viewController isKindOfClass:[self class]]
        || self.isAnimating == YES) {
        return;
    }
    
    if ([self isViewLoaded]) {
        [self flowInViewController:viewController
                          animated:animated
                   completionBlock:nil];
    } else {
        [self.innerViewControllers addObject:viewController];
        
        self.topViewController = viewController;
    }
}

- (UIViewController *)flowOutViewControllerAnimated:(BOOL)animated
{
    NSAssert([NSThread isMainThread], @"必须在主线程调用");
    
    if (self.isAnimating == YES) {
        return nil;
    }
    
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
    NSAssert([NSThread isMainThread], @"必须在主线程调用");
    
    if (self.isAnimating == YES) {
        return nil;
    }
    
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
    NSAssert([NSThread isMainThread], @"必须在主线程调用");
    
    if (self.isAnimating == YES) {
        return nil;
    }
    
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
    NSAssert([NSThread isMainThread], @"必须在主线程调用");
    
    if (self.isAnimating == YES) {
        return;
    }
    
    // 如果不是UIViewController的子类或自己，则过滤掉
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];

    [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if (![obj isKindOfClass:[UIViewController class]]
            || [obj isKindOfClass:[self class]]) {
            [indexSet addIndex:idx];
        } else {
            [obj performSelector:@selector(setFlowController:)
                      withObject:self];
        }
    }];
    
    NSMutableArray *newArray = [viewControllers mutableCopy];
    
    [newArray removeObjectsAtIndexes:indexSet];
    
    if ([self isViewLoaded]) {
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
                // 重构层级中的视图控制器
                UIViewController *flowInViewController = [newArray lastObject];
                
                [self flowInViewController:flowInViewController
                                  animated:animated
                           completionBlock:^(){
                               // 同上面 No Animate
                               [self holdViewControllers:@[[newArray lastObject]]];
                               
                               [self updateChildViewControllers:newArray];
                               
                               // 添加手势
                               [self addPressGestureRecognizerForTopView];
                           }];
            }
        } else {
            // 移除现在的视图控制器
            [self holdViewControllers:nil];
            
            [self updateChildViewControllers:newArray];
            
            [self addPressGestureRecognizerForTopView];
        }
    } else {
        self.innerViewControllers = newArray;
        
        self.topViewController = [newArray lastObject];
    }
}

- (void)flowingViewController:(UIViewController *)viewController toFrame:(CGRect)toFrame animationsBlock:(void(^)(void))animationsBlock completionBlock:(void(^)(BOOL finished))completionBlock
{
    NSAssert([NSThread isMainThread], @"必须在主线程调用");
    
    if (viewController.view.superview == nil
        || self.isAnimating) {
        return;
    }
    
    CGRect currentFrame = viewController.view.frame;
    
    CGFloat duration = [self durationForOriginalRect:currentFrame
                                     destinationRect:toFrame
                                    flowingDirection:[self flowDirectionWithPoint:currentFrame.origin otherPoint:toFrame.origin]
                                        flowingSpeed:[self flowingSpeedWithViewController:viewController]];
    
    self.isAnimating = YES;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         viewController.view.frame = toFrame;
                         
                         if (animationsBlock) {
                             animationsBlock();
                         }
                     }
                     completion:^(BOOL finished){
                         if (completionBlock) {
                             completionBlock(finished);
                         }
                         
                         self.isAnimating = NO;
                     }];
}

- (void)flowingViewController:(UIViewController *)viewController toFrame:(CGRect)toFrame
{
    [self flowingViewController:viewController
                        toFrame:toFrame
                animationsBlock:nil
                completionBlock:nil];
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
    
    viewController.view.frame = self.view.bounds;
    
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
    self.innerViewControllers = viewControllers;
    
    self.topViewController = [viewControllers lastObject];
    
    [self layoutViewControllers];
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

/**
 重新对视图进行布局
 */
- (void)layoutViewControllers
{
    [self.innerViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [self addContentViewController:obj];
    }];
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
    UIViewController *oldTopViewController = self.topViewController;
    
    [oldTopViewController setOverlayContent:YES
                            enabledShotView:YES];
    
    // 添加到容器中，并设置将要滑入的起始位置
    [self addTopViewController:viewController];
    
    viewController.overlayContent = YES;
    
    if ([viewController respondsToSelector:@selector(beginAppearanceTransition:animated:)]) {
        [viewController beginAppearanceTransition:YES
                                         animated:animated];
        
        [oldTopViewController beginAppearanceTransition:NO
                                               animated:animated];
    } else {
        [viewController viewWillAppear:animated];
        
        [oldTopViewController viewWillDisappear:animated];
    }
    
    if (animated) {
        [self flowingViewController:viewController
                            toFrame:[self inDestinationRectForViewController:viewController]
                    animationsBlock:^{
                        if ([self shouldScaleView:oldTopViewController]) {
                            [oldTopViewController setShotViewScale:0.95];
                        }
                    }
                    completionBlock:^(BOOL finished){
                        if ([viewController respondsToSelector:@selector(endAppearanceTransition)]) {
                            [viewController endAppearanceTransition];
                            
                            [oldTopViewController endAppearanceTransition];
                        } else {
                            [viewController viewDidAppear:animated];
                            
                            [oldTopViewController viewDidAppear:animated];
                        }
                        
                        viewController.overlayContent = NO;
                        
                        [self addPressGestureRecognizerForTopView];
                        
                        if (block) {
                            block();
                        }
                    }];
    } else {
        if (block) {
            block();
        }
        
        viewController.overlayContent = NO;
    }
}

- (NSArray *)flowOutIndexSet:(NSIndexSet *)indexSet animated:(BOOL)animated
{
    // 准备移除控制器
    NSArray *popViewControllers = [self.innerViewControllers objectsAtIndexes:indexSet];
    
    [self.innerViewControllers removeObjectsAtIndexes:indexSet];
    
    if ([self isViewLoaded]) {
        [popViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            // 设置UIViewController的flowController属性为nil
            [obj performSelector:@selector(setFlowController:)
                      withObject:nil];
            
            // 如果不是topViewController则移除视图
            if (obj != self.topViewController) {
                [obj willMoveToParentViewController:nil];
                
                [[obj view] removeFromSuperview];
                
                [obj removeFromParentViewController];
            }
        }];

        UIViewController *lastController = [self.innerViewControllers lastObject];
        
        // 确保视图已经添加
        if (lastController.view.superview == nil) {
            lastController.view.frame = self.view.bounds;
            
            [self.view insertSubview:lastController.view
                        belowSubview:self.topViewController.view];
        }
        
        if ([self.topViewController respondsToSelector:@selector(beginAppearanceTransition:animated:)]) {
            [self.topViewController beginAppearanceTransition:NO
                                                     animated:animated];
            
            [lastController beginAppearanceTransition:YES
                                             animated:animated];
        } else {
            [self.topViewController viewWillDisappear:animated];
            
            [lastController viewWillAppear:animated];
        }
        
        self.topViewController.overlayContent = YES;
        lastController.overlayContent = YES;

        void (^animationsBlock)(void) = ^{
            if ([self shouldScaleView:lastController]) {
                [lastController setShotViewScale:1.0];
            }
        };
        
        void (^completionBlock)(BOOL) = ^(BOOL finished) {
            if ([self.topViewController respondsToSelector:@selector(endAppearanceTransition)]) {
                [self.topViewController endAppearanceTransition];
                
                [lastController endAppearanceTransition];
            } else {
                [self.topViewController viewDidDisappear:animated];
                
                [lastController viewDidAppear:animated];
            }
            
            [self removeTopViewController];
            
            [self addPressGestureRecognizerForTopView];
            
            lastController.overlayContent = NO;
        };
        
        if (animated) {
            [self flowingViewController:self.topViewController
                                toFrame:[self outDestinationRectForViewController:self.topViewController]
                        animationsBlock:animationsBlock
                        completionBlock:completionBlock];
        } else {
            animationsBlock();
            completionBlock(YES);
        }
        
        
    } else {
        // 设置UIViewController的flowController属性为nil
        [popViewControllers makeObjectsPerformSelector:@selector(setFlowController:)
                                            withObject:nil];
    }
    
    return popViewControllers;
}

// 滑入的起初位置
- (CGRect)inOriginRectForViewController:(UIViewController *)viewController
{
    // 默认的目标frame以容器为基准
    CGRect destinationFrame = self.view.bounds;
    
    // 允许自定义滑入时的最终frame
    if ([self.topViewController respondsToSelector:@selector(destinationRectForFlowDirection:)]) {
        destinationFrame = [(id <GQViewController>)self.topViewController
                                                                 destinationRectForFlowDirection:viewController.flowInDirection];
    }
    
    // 根据滑入的最终frame计算起点
    CGRect originFrame = CGRectZero;
    
    switch (viewController.flowInDirection) {
        case GQFlowDirectionLeft:
            originFrame = CGRectMake(self.view.bounds.size.width,
                                     destinationFrame.origin.y,
                                     destinationFrame.size.width,
                                     destinationFrame.size.height);
            break;
        case GQFlowDirectionRight:
            originFrame = CGRectMake(-destinationFrame.size.width,
                                     destinationFrame.origin.y,
                                     destinationFrame.size.width,
                                     destinationFrame.size.height);
            break;
        case GQFlowDirectionUp:
            originFrame = CGRectMake(destinationFrame.origin.x,
                                     self.view.bounds.size.height,
                                     destinationFrame.size.width,
                                     destinationFrame.size.height);
            break;
        case GQFlowDirectionDown:
            originFrame = CGRectMake(destinationFrame.origin.x,
                                     -destinationFrame.size.height,
                                     destinationFrame.size.width,
                                     destinationFrame.size.height);
            break;
        default:
            originFrame = destinationFrame;
            break;
    }
    
    return originFrame;
}

// 滑入的目标位置
- (CGRect)inDestinationRectForViewController:(UIViewController *)viewController
{
    CGRect destinationFrame = CGRectZero;
    
    // 允许自定义滑入时的最终frame
    if ([self.topViewController respondsToSelector:@selector(destinationRectForFlowDirection:)]) {
        destinationFrame = [(id <GQViewController>)self.topViewController
                                                                 destinationRectForFlowDirection:viewController.flowInDirection];
    } else {
        // 默认的目标frame以容器为基准
        CGRect viewBounds = self.view.bounds;
        
        // 通过容器的bounds计算滑入的frame
        switch (viewController.flowInDirection) {
            case GQFlowDirectionLeft:
                destinationFrame = CGRectMake(self.view.bounds.size.width - viewBounds.size.width,
                                              viewBounds.origin.y,
                                              viewBounds.size.width,
                                              viewBounds.size.height);
                break;
            case GQFlowDirectionRight:
                destinationFrame = CGRectMake(.0,
                                              viewBounds.origin.y,
                                              viewBounds.size.width,
                                              viewBounds.size.height);
                break;
            case GQFlowDirectionUp:
                destinationFrame = CGRectMake(viewBounds.origin.x,
                                              self.view.bounds.size.height - viewBounds.size.height,
                                              viewBounds.size.width,
                                              viewBounds.size.height);
                break;
            case GQFlowDirectionDown:
                destinationFrame = CGRectMake(viewBounds.origin.x,
                                              .0,
                                              viewBounds.size.width,
                                              viewBounds.size.height);
                break;
            default:
                destinationFrame = viewBounds;
                break;
        }
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
            destinationFrame = CGRectMake(self.view.bounds.size.width,
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
                                          self.view.bounds.size.height,
                                          viewFrame.size.width,
                                          viewFrame.size.height);
            break;
        default:
            destinationFrame = viewFrame;
            break;
    }
    
    return destinationFrame;
}

- (void)resetPressStatus
{
    self.startPoint = CGPointZero;
    self.originalFrame = CGRectZero;
    self.flowingDirection = GQFlowDirectionUnknow;
}

- (CGFloat)flowingSpeedWithViewController:(UIViewController *)viewController
{
    CGFloat speed = self.viewFlowingSpeed;
    
    if ([viewController respondsToSelector:@selector(flowingSpeed)]) {
        speed = [(id <GQViewController>)viewController flowingSpeed];
        
        if (speed == 0) {
            speed = self.viewFlowingSpeed;
        }
    }
    
    return speed;
}

- (NSTimeInterval)durationForOriginalRect:(CGRect)originalFrame destinationRect:(CGRect)destinationFrame flowingDirection:(GQFlowDirection)flowingDirection flowingSpeed:(CGFloat)speed
{
    CGFloat length = .0;
    
    if (flowingDirection == GQFlowDirectionLeft
        || flowingDirection == GQFlowDirectionRight) {
        length = destinationFrame.origin.x - originalFrame.origin.x;
    } else if (flowingDirection == GQFlowDirectionUp
               && flowingDirection == GQFlowDirectionDown){
        length = destinationFrame.origin.y - destinationFrame.origin.y;
    }
    
    return ABS(length) / speed;
}

// 添加手势
- (void)addPressGestureRecognizerForTopView
{
    // 判断是否实现GQViewController Protocol
    if (![self.topViewController conformsToProtocol:@protocol(GQViewController)]) {
        return;
    }
    
    // 仅有1个视图控制器时总是不添加手势
    if ([self.viewControllers count] < 2) {
        return;
    }
    
    if (self.pressGestureRecognizer == nil) {
        self.pressGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(pressMoveGesture)];
    }
    
    [self.topViewController.view addGestureRecognizer:self.pressGestureRecognizer];
}

- (void)removeTopViewPressGestureRecognizer
{
    // 判断是否实现GQViewControllerProtocol
    if (![self.topViewController conformsToProtocol:@protocol(GQViewController)]) {
        return;
    }
    
    if (self.pressGestureRecognizer) {
        [self.topViewController.view removeGestureRecognizer:self.pressGestureRecognizer];
    }
}

- (void)pressMoveGesture
{
    CGPoint pressPoint = [self.pressGestureRecognizer translationInView:self.view];
    
    if (self.pressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // 设置初始点
        self.startPoint = pressPoint;
        
        // 确保下层视图是否已经添加
        UIViewController *vc = [self belowTopViewController];
        
        if (vc.view.superview == nil) {
            vc.view.frame = self.view.bounds;
            
            [self.view insertSubview:vc.view
                        belowSubview:self.topViewController.view];
        }
    } else if (self.pressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // 判断移动的视图
        if (self.flowingDirection == GQFlowDirectionUnknow) {
            // 判断移动的方向            
            if (ABS(pressPoint.x) > ABS(pressPoint.y)) {
                if (pressPoint.x > .0) {
                    self.flowingDirection = GQFlowDirectionRight;
                } else {
                    self.flowingDirection = GQFlowDirectionLeft;
                }
            } else {
                if (pressPoint.y > .0) {
                    self.flowingDirection = GQFlowDirectionDown;
                } else {
                    self.flowingDirection = GQFlowDirectionUp;
                }
            }

            // 滑动的View可能不是Top View
            if ([self.topViewController respondsToSelector:@selector(viewControllerForFlowDirection:)]) {
                UIViewController *controller = [(id<GQViewController>)self.topViewController viewControllerForFlowDirection:self.flowingDirection];
                
                // 校验不是topViewController，并添加到容器中
                if (controller != self.topViewController) {
                    // 判断是否实现GQViewController Protocol
                    if (![controller conformsToProtocol:@protocol(GQViewController)]) {
                        NSLog(@"滑出其它的控制器必须实现GQViewController Protocol");
                    } else {
                        self.topViewController.overlayContent = YES;
                        
                        [self addTopViewController:controller];
                        
                        // TODO: viewWillAppear
                    }
                }
            }
            
            // 记录移动视图的原始位置
            self.originalFrame = self.topViewController.view.frame;
        }

        CGRect newFrame = CGRectZero;
        
        if (self.flowingDirection == GQFlowDirectionLeft
            || self.flowingDirection == GQFlowDirectionRight) {
            
            newFrame = CGRectOffset(self.originalFrame, pressPoint.x, .0);
            
        } else if (self.flowingDirection == GQFlowDirectionUp
                   || self.flowingDirection == GQFlowDirectionDown) {
            
            newFrame = CGRectOffset(self.originalFrame, .0, pressPoint.y);
            
        }
        
        // 能否移动
        BOOL shouldMove = NO;
        
        // 仅仅允许设置的移动方位
        if (self.flowingDirection == self.topViewController.flowInDirection
            || self.flowingDirection == self.topViewController.flowOutDirection) {
            shouldMove = YES;
            
            // 可通过实现GQEnhancementViewController来进一步的控制
            if ([self.topViewController respondsToSelector:@selector(shouldFlowToRect:)]) {
                shouldMove = [(id<GQViewController>)self.topViewController shouldFlowToRect:newFrame];
            }
        }
        
        if (shouldMove) {
            // 滑动时激活遮罩层
            self.topViewController.overlayContent = YES;
            
            self.topViewController.view.frame = newFrame;
            
            UIViewController *belowVC = [self belowTopViewController];
            
            if (belowVC) {
                // 对topViewController下面一层内容进行overlay
                belowVC.overlayContent = YES;
                
                if ([self shouldScaleView:belowVC]) {
                    // 计算缩放
                    float x = ABS(pressPoint.x - self.startPoint.x);
                    
                    float scale = 1.0;
                    
                    float scaleFactor = self.topViewController.view.frame.size.width * 20.0;
                    
                    if (self.flowingDirection == self.topViewController.flowInDirection) {
                        scale = 1.0 - x / scaleFactor;
                    } else if (self.flowingDirection == self.topViewController.flowOutDirection) {
                        scale = 0.95 + x / scaleFactor;
                    }
                    
                    [belowVC setShotViewScale:scale];
                }
            }
        }
    } else if (self.pressGestureRecognizer.state == UIGestureRecognizerStateEnded) {        
        // 默认为原始位置
        CGRect destinationFrame = self.originalFrame;
        
        BOOL cancelFlowing = NO; // 是否需要取消回退滑动
        
        BOOL skipCancelFlowingCheck = NO; // 是否跳过回退的检测
        
        if ([self.topViewController respondsToSelector:@selector(destinationRectForFlowDirection:)]) {
            // 自定义视图控制器最终停止移动的位置
            destinationFrame = [(id<GQViewController>)self.topViewController destinationRectForFlowDirection:self.flowingDirection];
            
            // 对返回的结果进行验证
            if (CGRectEqualToRect(CGRectZero, destinationFrame)) {
                destinationFrame = self.originalFrame;
            } else {
                // delegate返回有效的值时，忽略viewFlowingBoundary
                skipCancelFlowingCheck = YES;
            }
        }
        
        if (skipCancelFlowingCheck == NO) {
            CGFloat boundary = self.viewFlowingBoundary;
            
            // delegate返回滑回的触发距离
            if ([self.topViewController respondsToSelector:@selector(flowingBoundary)]) {
                boundary = [(id<GQViewController>)self.topViewController flowingBoundary];
            }
            
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
        
        UIViewController *belowVC = [self belowTopViewController];
        
        [self flowingViewController:self.topViewController
                            toFrame:destinationFrame
                    animationsBlock:^{
                        if ([self shouldScaleView:belowVC]) {
                            if (self.flowingDirection == self.topViewController.flowInDirection) {
                                [belowVC setShotViewScale:0.95];
                            } else if (self.flowingDirection == self.topViewController.flowOutDirection) {
                                [belowVC setShotViewScale:1.0];
                            }
                        }
                    }
                    completionBlock:^(BOOL finished){
                        if ([self.topViewController respondsToSelector:@selector(didFlowToDestinationRect)]) {
                            [(id <GQViewController>)self.topViewController didFlowToDestinationRect];
                        }
                        
                        // 如果topViewController已经移出窗口，则进行删除操作
                        if (!CGRectIntersectsRect(self.view.frame, self.topViewController.view.frame)) {
                            [self.innerViewControllers removeLastObject];
                            
                            [self removeTopViewController];
                        }
                        
                        self.topViewController.overlayContent = NO;
                        
                        // 重新添加top view的手势
                        [self addPressGestureRecognizerForTopView];
                        
                        // 重置长按状态信息
                        [self resetPressStatus];
                    }];
    } else if (self.pressGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        
    }
}

- (UIViewController *)belowTopViewController
{
    NSUInteger vcCount = [self.viewControllers count];
    
    if (vcCount > 1) {
        return (UIViewController *)[self.viewControllers objectAtIndex:vcCount - 2];
    } else {
        return nil;
    }
}

- (BOOL)shouldScaleView:(UIViewController *)controller
{
    BOOL isScale = YES;
    
    if ([controller respondsToSelector:@selector(shouldScaleView)]) {
        isScale = [(id<GQViewController>)controller shouldScaleView];
    }
    
    return isScale;
}

- (GQFlowDirection)flowDirectionWithPoint:(CGPoint)point otherPoint:(CGPoint)otherPoint
{
    GQFlowDirection flowingDirection = GQFlowDirectionUnknow;
    
    if (point.x == otherPoint.x) {
        if (point.y < otherPoint.y) {
            flowingDirection = GQFlowDirectionUp;
        } else if (point.y > otherPoint.y) {
            flowingDirection = GQFlowDirectionDown;
        }
    } else if (point.y == otherPoint.y) {
        if (point.x > otherPoint.x) {
            flowingDirection = GQFlowDirectionRight;
        } else if (point.x < otherPoint.x) {
            flowingDirection = GQFlowDirectionLeft;
        }
    }
    
    return flowingDirection;
}

@end

#pragma mark - GQFlowController Category

static char kGQFlowControllerObjectKey;
static char kGQFlowInDirectionObjectKey;
static char kGQFlowOutDirectionObjectKey;
static char kQGOverlayContentObjectKey;
static char kQGOverlayViewObjectKey;

@implementation UIViewController (GQFlowControllerAdditions)

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
    [self setOverlayContent:yesOrNo enabledShotView:NO];
}

- (void)setOverlayContent:(BOOL)yesOrNo enabledShotView:(BOOL)yesOrNoShotView
{
    // 优化状态处理
    if (self.isOverlayContent == yesOrNo) {
        return;
    }
    
    objc_setAssociatedObject(self, &kQGOverlayContentObjectKey, [NSNumber numberWithInt:yesOrNo], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIView *overlayView = objc_getAssociatedObject(self, &kQGOverlayViewObjectKey);
    
    if (overlayView == nil) {
        overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        
        if ([self respondsToSelector:@selector(overlayContentTapAction:)]) {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(overlayContentTapAction:)];
            [overlayView addGestureRecognizer:tapGestureRecognizer];
        }

        objc_setAssociatedObject(self, &kQGOverlayViewObjectKey, overlayView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if (yesOrNo) {
        if (yesOrNoShotView) {
            [overlayView setBackgroundColor:[UIColor blackColor]];
            
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.0);
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            [self.view.layer renderInContext:context];
            
            UIImage *contentShot = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            UIImageView *shotView = [[UIImageView alloc] initWithImage:contentShot];
            
            [overlayView addSubview:shotView];
            
            UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
            
            maskView.backgroundColor = [UIColor blackColor];
            
            maskView.alpha = MASK_VIEW_ALPHA;
            
            [overlayView addSubview:maskView];
        } else {
            [overlayView setBackgroundColor:[UIColor clearColor]];
        }
        
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

- (void)setShotViewScale:(CGFloat)scale
{
    if ([self isOverlayContent] == YES) {
        UIView *overlayView = objc_getAssociatedObject(self, &kQGOverlayViewObjectKey);
        
        if ([overlayView.subviews count] == 2) {
            UIView *shotView = [overlayView.subviews objectAtIndex:0];
            
            UIView *maskView = [overlayView.subviews objectAtIndex:1];
            
            // 保证缩放时的间隙相同
            CGFloat offsetX = shotView.frame.size.width * (1.0 - scale) * 0.5;
            
            CGFloat sy = 1.0 - offsetX * 2.0 / shotView.frame.size.height;
            
            shotView.transform = CGAffineTransformMakeScale(scale, sy);
            
            maskView.alpha = MASK_VIEW_ALPHA * (1.0 - scale);
        }
    }
}

@end

