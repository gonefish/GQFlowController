//
//  Demo2BViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-5-18.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "Demo2BViewController.h"

@interface Demo2BViewController ()

@end

@implementation Demo2BViewController
- (IBAction)backAction:(id)sender {
    [self.flowController flowOutToRootViewControllerAnimated:YES];
    
//    GQViewController *a = [self.flowController.viewControllers objectAtIndex:0];
//    
//    [self.flowController setViewControllers:@[a] animated:NO];

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

#pragma mark - GQFlowControllerDelegate

- (BOOL)flowController:(GQFlowController *)flowController shouldFlowToRect:(CGRect)frame
{
    if (frame.origin.x >= .0) {
        return YES;
    } else {
        return NO;
    }
}

- (CGFloat)flowingBoundary:(GQFlowController *)flowController
{
    return 0.15;
}

@end
