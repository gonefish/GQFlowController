//
//  Demo2AViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-5-14.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "Demo2AViewController.h"
#import "Demo2BViewController.h"

@interface Demo2AViewController ()

@end

@implementation Demo2AViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)backAction:(id)sender {
    [self.flowController flowOutViewControllerAnimated:YES];
}
- (IBAction)flowbAction:(id)sender {
    Demo2BViewController *b = [[Demo2BViewController alloc] initWithNibName:@"Demo2BViewController" bundle:nil];
    [self.flowController flowInViewController:b
                                     animated:YES];
    
//    GQViewController *a = [self.flowController.viewControllers objectAtIndex:0];
//    
//    [self.flowController setViewControllers:@[a] animated:YES];
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

- (CGFloat)flowingBoundary:(GQFlowController *)flowController
{
    return 0.15;
}

- (GQViewController *)flowController:(GQFlowController *)flowController viewControllerForFlowDirection:(GQFlowDirection)direction
{
    if (direction == GQFlowDirectionLeft) {
        return [[Demo2BViewController alloc] initWithNibName:@"Demo2BViewController" bundle:nil];
    } else {
        return self;
    }
}

@end
