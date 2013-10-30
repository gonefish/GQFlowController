//
//  GQNavigationController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-10-21.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "GQNavigationController.h"

@interface GQNavigationController ()

@property (nonatomic, strong) UINavigationController *gqNavigationController;

@end

@implementation GQNavigationController

- (NSArray *)flowViewControllers
{
    return [super viewControllers];
}

- (void)setFlowViewControllers:(NSArray *)viewControllers
{
    [super setViewControllers:viewControllers animated:NO];
}

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self = [super initWithViewControllers:viewControllers];
    } else {
        self = [super init];
        
        if (self) {
            UINavigationController *navigationController = [[UINavigationController alloc] init];
            
            [viewControllers makeObjectsPerformSelector:@selector(setFlowController:) withObject:self];
            
            navigationController.viewControllers = viewControllers;
            
            [self setFlowViewControllers:@[navigationController]];
            
            self.gqNavigationController = navigationController;
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)flowInViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [super flowInViewController:viewController animated:animated];
    } else {
        [viewController performSelector:@selector(setFlowController:) withObject:self];
        
        [self.gqNavigationController pushViewController:viewController animated:animated];
    }
}
- (UIViewController *)flowOutViewControllerAnimated:(BOOL)animated
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return [super flowOutViewControllerAnimated:animated];
    } else {
        return [self.gqNavigationController popViewControllerAnimated:animated];
    }
}
- (NSArray *)flowOutToRootViewControllerAnimated:(BOOL)animated
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return [super flowOutToRootViewControllerAnimated:animated];
    } else {
        return [self.gqNavigationController popToRootViewControllerAnimated:animated];
    }
}
- (NSArray *)flowOutToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return [super flowOutToViewController:viewController animated:animated];
    } else {
        return [self.gqNavigationController popToViewController:viewController animated:animated];
    }
}

- (NSArray *)viewControllers
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return [super viewControllers];
    } else {
        return self.gqNavigationController.viewControllers;
    }
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [super setViewControllers:viewControllers animated:animated];
    } else {
        [viewControllers makeObjectsPerformSelector:@selector(setFlowController:) withObject:self];
        
        [self.gqNavigationController setViewControllers:viewControllers animated:animated];
    }
}

@end
