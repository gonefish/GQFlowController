//
//  Demo2AViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-5-14.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "Demo2AViewController.h"


@interface Demo2AViewController ()

@end

@implementation Demo2AViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.bViewController = [[Demo2BViewController alloc] initWithNibName:@"Demo2BViewController" bundle:nil];;
    }
    return self;
}

- (IBAction)backAction:(id)sender {
    [self.flowController flowOutViewControllerAnimated:YES];
}
- (IBAction)flowbAction:(id)sender {
    [self.flowController flowInViewController:self.bViewController animated:YES];
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

//- (CGRect)flowController:(GQFlowController *)flowController destinationRectForViewController:(GQViewController *)viewController flowDirection:(GQFlowDirection)direction
//{
//    return self.view.frame;
//}

//- (GQViewController *)flowController:(GQFlowController *)flowController moveViewControllerForFlowDirection:(GQFlowDirection)direction
//{
//    if (direction == GQFlowDirectionLeft) {
//        return self.bViewController;
//    } else {
//        return self;
//    }
//}

@end
