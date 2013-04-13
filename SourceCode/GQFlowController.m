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

@property (nonatomic) CGFloat prevX;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic, strong) UIView *pressView;
@property (nonatomic, strong) UILongPressGestureRecognizer *pressGestureRecognizer;

- (void)addPressGestureRecognizerForTopView;
- (void)removeTopViewPressGestureRecognizer;

- (void)layoutFlowViews;

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

- (NSArray *)viewControllers
{
    return [self.innerViewControllers copy];
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

#pragma mark - 

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
        self.startPoint = pressPoint;
    } else if (self.pressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (self.pressView == nil) {
            GQViewControllerFlowDirection direction = GQViewControllerFlowDirectionRight;
            
            // 判断移动的方向
            CGFloat x = pressPoint.x - self.startPoint.x;
            CGFloat y = pressPoint.y - self.startPoint.y;
            
            if (ABS(x) > ABS(y)) {
                if (x > .0) {
                    direction = GQViewControllerFlowDirectionRight;
                } else if (x < .0) {
                    direction = GQViewControllerFlowDirectionLeft;
                }
            } else if (ABS(x) < ABS(y)) {
                if (y > 0) {
                    direction = GQViewControllerFlowDirectionUp;
                } else if (y < .0) {
                    direction = GQViewControllerFlowDirectionDown;
                }
            }
            
            if (self.topViewController.delegate
                && [self.topViewController.delegate respondsToSelector:@selector(viewForFlowController:direction:)]) {
                self.pressView = [self.topViewController.delegate viewForFlowController:self
                                                                              direction:direction];
            } else {
                self.pressView = self.pressGestureRecognizer.view;
            }
        } else {
            CGFloat offset = pressPoint.x - self.prevX;
            
            if (offset != .0) {
                CGRect frame = self.pressView.frame;
                frame = CGRectMake(frame.origin.x + offset,
                                   frame.origin.y,
                                   frame.size.width,
                                   frame.size.height);
                
                self.pressView.frame = frame;
                
                self.prevX = pressPoint.x;
                
                NSLog(@"move");
            }
        }
    } else if (self.pressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        BOOL shouldFlowing = YES;
        
        if (self.topViewController.delegate
            && [self.topViewController.delegate respondsToSelector:@selector(flowController:shouldFlowingView:atOffset:)]) {
            // offset怎么算？
            shouldFlowing = [self.topViewController.delegate flowController:self
                                                          shouldFlowingView:self.pressView
                                                                   atOffset:.0];
        }
        
        CGRect frame2;
        
        if (shouldFlowing) {
            // 自动移动到最终点
            frame2 = CGRectMake(320, self.pressView.frame.origin.y, self.pressView.frame.size.width, self.pressView.frame.size.height);
        } else {
            // 回退到最终点
            frame2 = CGRectMake(0, self.pressView.frame.origin.x, self.pressView.frame.size.width, self.pressView.frame.size.height);
        }
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.pressView.frame = frame2;
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
    
    NSLog(@"%f", pressPoint.x);
}

@end
