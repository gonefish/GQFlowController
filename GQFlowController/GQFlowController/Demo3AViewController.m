//
//  Demo3AViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-7-18.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "Demo3AViewController.h"
#import "Demo3CViewController.h"

@interface Demo3AViewController ()

@end

@implementation Demo3AViewController

- (IBAction)backAction:(id)sender {
    [self.flowController flowOutViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GQViewController

- (UIViewController *)viewControllerForFlowDirection:(GQFlowDirection)direction
{
    if (direction == GQFlowDirectionLeft) {
        return [[Demo3CViewController alloc] initWithNibName:@"Demo3CViewController" bundle:nil];
    } else {
        return self;
    }
}

- (BOOL)shouldFollowAboveViewFlowing
{
    return NO;
}

- (CGFloat)flowingBoundary
{
    return 0.15;
}

- (CGRect) destinationRectForFlowDirection:(GQFlowDirection)direction;
{
    if (direction == self.flowInDirection) {
        CGFloat w = 300.0;
        
        return CGRectMake(w, .0, self.flowController.view.bounds.size.width - w, self.flowController.view.bounds.size.height);
    } else {
        return CGRectZero;
    }
}

@end
