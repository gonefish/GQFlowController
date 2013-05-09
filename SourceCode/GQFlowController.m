//
//  GQFlowController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "GQFlowController.h"

@interface GQFlowController ()

@property (nonatomic, strong) GQViewController *topViewController;
@property (nonatomic, strong) NSMutableArray *innerViewControllers;

@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGPoint basePoint;
@property (nonatomic, strong) UIView *pressView;
@property (nonatomic) GQFlowDirection pressViewDirection;
@property (nonatomic, strong) UILongPressGestureRecognizer *pressGestureRecognizer;

- (void)addPressGestureRecognizerForTopView;
- (void)removeTopViewPressGestureRecognizer;

- (void)layoutFlowViews;

/**
 * 计算移动到目标位置所需要的时间
 */
- (NSTimeInterval)durationForMovePressViewToFrame:(CGRect)aRect;

@end

@implementation GQFlowController

- (id)init
{
    self = [super init];
    
    if (self) {
        self.innerViewControllers = [NSMutableArray array];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    
    if (self) {
        self.innerViewControllers = [NSMutableArray array];
    }
    
    return self;
}

- (NSArray *)viewControllers
{
    return [self.innerViewControllers copy];
}

- (void)setViewControllers:(NSArray *)aViewControllers
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [aViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if (![obj isKindOfClass:[GQViewController class]]) {
            [indexSet addIndex:idx];
        }
    }];
    
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:aViewControllers];
    
    [newArray removeObjectsAtIndexes:indexSet];
    
    self.innerViewControllers = newArray;
    
    [self layoutFlowViews];
}

- (id)initWithRootViewController:(GQViewController *)rootViewController
{
    self = [self init];
    
    if (self) {
        rootViewController.flowController = self;
        [self.innerViewControllers addObject:rootViewController];
        self.topViewController = rootViewController;
    }
    
    return self;
}

- (void)flowOutViewControllerAnimated:(BOOL)animated
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect destFrame = CGRectMake(self.view.frame.size.width,
                                                       0,
                                                       self.view.frame.size.width,
                                                       self.view.frame.size.height);

                         self.topViewController.view.frame = destFrame;
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

- (void)flowInViewController:(GQViewController *)viewController animated:(BOOL)animated
{
    viewController.flowController = self;
    
    [self addChildViewController:viewController];
    
    viewController.view.frame = CGRectMake(self.view.frame.size.width,
                                           0,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height);
    
    [self.view addSubview:viewController.view];
    
    [viewController didMoveToParentViewController:self];
    
    self.topViewController = viewController;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         viewController.view.frame = CGRectMake(0,
                                                                0,
                                                                self.view.frame.size.width,
                                                                self.view.frame.size.height);
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
    for (UIViewController *controller in self.innerViewControllers) {
        [self addChildViewController:controller];
        
        controller.view.frame = CGRectMake(0,
                                           0,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height);
        
        [self.view addSubview:controller.view];
        
        [controller didMoveToParentViewController:self];
    }
    
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

- (NSTimeInterval)durationForMovePressViewToFrame:(CGRect)aRect;
{
    CGFloat range = .0;
    
    // TODO:需要处理斜线运动
    if (self.pressViewDirection == GQFlowDirectionRight
        || self.pressViewDirection == GQFlowDirectionLeft) {
        range = aRect.origin.x - self.pressView.frame.origin.x;
    } else {
        range = aRect.origin.y - self.pressView.frame.origin.y;
    }
    
    // 速度以1秒移动一屏为基准
    return 1.0 / 320.0 * ABS(range);
}

// 添加手势
- (void)addPressGestureRecognizerForTopView
{
    if (self.pressGestureRecognizer == nil) {
        self.pressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(pressMoveGesture)];
        self.pressGestureRecognizer.minimumPressDuration = .0;
    }
    
    [self.topViewController.view addGestureRecognizer:self.pressGestureRecognizer];
}

- (void)removeTopViewPressGestureRecognizer
{
    if (self.pressGestureRecognizer) {
        [self.topViewController.view removeGestureRecognizer:self.pressGestureRecognizer];
    }
}

- (void)pressMoveGesture
{
    CGPoint pressPoint = [self.pressGestureRecognizer locationInView:nil];
    
    if (self.pressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // 设置初始点
        self.basePoint = pressPoint;
        self.prevPoint = pressPoint;
    } else if (self.pressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // 判断移动的视图
        if (self.pressView == nil) {
            self.pressViewDirection = GQFlowDirectionUnknow;
            
            // 判断移动的方向
            CGFloat x = pressPoint.x - self.basePoint.x;
            CGFloat y = pressPoint.y - self.basePoint.y;
            
            if (ABS(x) > ABS(y)) {
                if (x > .0) {
                    self.pressViewDirection = GQFlowDirectionRight;
                } else if (x < .0) {
                    self.pressViewDirection = GQFlowDirectionLeft;
                }
            } else if (ABS(x) < ABS(y)) {
                if (y > .0) {
                    self.pressViewDirection = GQFlowDirectionUp;
                } else if (y < .0) {
                    self.pressViewDirection = GQFlowDirectionDown;
                }
            }
            
            // 没有变化
            if (self.pressViewDirection == GQFlowDirectionUnknow) {
                return;
            }

            if ([self.topViewController respondsToSelector:@selector(flowController:viewForFlowDirection:)]) {
                self.pressView = [self.topViewController flowController:self
                                                   viewForFlowDirection:self.pressViewDirection];
            } else {
                self.pressView = self.pressGestureRecognizer.view;
            }
        }
        
        if (self.pressView) {
            // 移动到的frame
            CGRect newFrame = CGRectZero;
            
            if (self.pressViewDirection == GQFlowDirectionLeft
                || self.pressViewDirection == GQFlowDirectionRight) {
                CGFloat x = pressPoint.x - self.prevPoint.x;
                
                newFrame = CGRectOffset(self.pressView.frame, x, .0);
            } else if (self.pressViewDirection == GQFlowDirectionUp
                       || self.pressViewDirection == GQFlowDirectionDown) {
                CGFloat y = pressPoint.y - self.prevPoint.y;
                newFrame = CGRectOffset(self.pressView.frame, .0, y);
            }
            
            // 能否移动
            BOOL shouldMove = YES;
            
            if ([self.topViewController respondsToSelector:@selector(flowController:shouldMoveView:toFrame:)]) {
                shouldMove = [self.topViewController flowController:self
                                                     shouldMoveView:self.pressView
                                                            toFrame:newFrame];
            }
            
            if (shouldMove) {
                self.pressView.frame = newFrame;
            }
        }
        
        // 记住上一个点
        self.prevPoint = pressPoint;

    } else if (self.pressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.topViewController conformsToProtocol:@protocol(GQViewControllerDelegate)]) {
            CGRect frame = [self.topViewController flowController:self
                                           destinationRectForView:self.pressView
                                                    flowDirection:self.pressViewDirection];
            
            [UIView animateWithDuration:[self durationForMovePressViewToFrame:frame]
                             animations:^{
                                 self.pressView.frame = frame;
                             }
                             completion:^(BOOL finished){
                                 // 重新处理top view
                                 
                                 self.pressView = nil;
                             }];
        } else {
            NSAssert(NO, @"?");
        }
    }
    
    NSLog(@"%f", pressPoint.x);
}

@end
