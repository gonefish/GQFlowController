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

- (void)setGqNavigationController:(UINavigationController *)gqNavigationController
{
    [gqNavigationController.viewControllers makeObjectsPerformSelector:@selector(setFlowController:)
                                                            withObject:self];
    
    _gqNavigationController = gqNavigationController;
}


- (id)initWithViewControllers:(NSArray *)viewControllers
{
    return [self initWithNavigationControllers:viewControllers belowViewControllers:nil];
}

- (id)initWithNavigationControllers:(NSArray *)viewControllers belowViewControllers:(NSArray *)belowViewControllers
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        NSArray *newViewController = viewControllers;
        
        if (belowViewControllers) {
            newViewController = [belowViewControllers arrayByAddingObjectsFromArray:viewControllers];
        }
        
        self = [super initWithViewControllers:newViewController];
    } else {
        self = [super init];
        
        if (self) {
            UINavigationController *navigationController = [[UINavigationController alloc] init];
            
            navigationController.viewControllers = viewControllers;
            
            self.gqNavigationController = navigationController;
            
            NSArray *newViewControllers = @[navigationController];
            
            if (belowViewControllers) {
                newViewControllers = [belowViewControllers arrayByAddingObject:navigationController];
            }
            
            [super setViewControllers:newViewControllers animated:NO];
        }
    }
    
    return self;
}

- (id)initWithNavigationController:(UINavigationController *)navigationController belowViewControllers:(NSArray *)viewControllers
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        NSArray *newViewController = nil;
        
        if (viewControllers) {
            newViewController = [viewControllers arrayByAddingObject:navigationController.viewControllers];
        } else {
            newViewController = navigationController.viewControllers;
        }
        
        self = [super initWithViewControllers:newViewController];
    } else {
        self = [super init];
        
        if (self) {
            NSArray *newViewControllers = nil;
            
            if (viewControllers) {
                newViewControllers = [viewControllers arrayByAddingObject:navigationController];
            } else {
                newViewControllers = @[navigationController];
            }
            
            [super setViewControllers:newViewControllers animated:NO];
            
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
