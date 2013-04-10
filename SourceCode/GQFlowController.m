//
//  GQFlowController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "GQFlowController.h"

@interface GQFlowController ()

@property (nonatomic, weak) GQViewController *topViewController;
@property (nonatomic, strong) NSMutableArray *innerViewControllers;

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

- (void)setViewControllers:(NSArray *)viewControllers
{
    self.innerViewControllers = [viewControllers mutableCopy];
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
                         
                         self.topViewController = [self.innerViewControllers lastObject];
                     }];
}

- (void)flowInViewController:(GQViewController *)viewController animated:(BOOL)animated
{
    self.topViewController = viewController;
    viewController.flowController = self;
    [self addChildViewController:viewController];
    
    viewController.view.frame = CGRectMake(self.view.frame.size.width,
                                           0,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height);
    
    [self.view addSubview:viewController.view];
    
    [viewController didMoveToParentViewController:self];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         viewController.view.frame = CGRectMake(0,
                                                                0,
                                                                self.view.frame.size.width,
                                                                self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                     
                     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    for (UIViewController *controller in self.innerViewControllers) {
        [self addChildViewController:controller];
        
        controller.view.frame = CGRectMake(0,
                                           0,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height);
        
        [self.view addSubview:controller.view];
        
        [controller didMoveToParentViewController:self]; 
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
