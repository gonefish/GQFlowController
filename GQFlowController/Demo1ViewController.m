//
//  Demo1ViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-4-21.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "Demo1ViewController.h"
#import "GQFlowController.h"

@interface Demo1ViewController ()

@end

@implementation Demo1ViewController

#pragma mark - GQViewControllerDelegate

- (CGRect)flowController:(GQFlowController *)flowController destinationRectForView:(UIView *)view
{
    CGRect destinationFrect = [super flowController:flowController destinationRectForView:view];
        
    if (view.frame.origin.x > 0
        && view.frame.origin.x < 100) {
        destinationFrect = CGRectMake(0,
                                      0,
                                      view.frame.size.width,
                                      view.frame.size.height);
        
        [[[[flowController viewControllers] objectAtIndex:1] view] setHidden:NO];
        [[[[flowController viewControllers] objectAtIndex:0] view] setHidden:YES];

    } else if (view.frame.origin.x > 100
               && view.frame.origin.x < view.frame.size.width) {
        destinationFrect = CGRectMake(view.frame.size.width - 100,
                                      0,
                                      view.frame.size.width,
                                      view.frame.size.height);
        [[[[flowController viewControllers] objectAtIndex:1] view] setHidden:NO];
        [[[[flowController viewControllers] objectAtIndex:0] view] setHidden:YES];
    } else if (view.frame.origin.x < -100) {
        destinationFrect = CGRectMake(-view.frame.size.width + 100,
                                      0,
                                      view.frame.size.width,
                                      view.frame.size.height);
        [[[[flowController viewControllers] objectAtIndex:0] view] setHidden:NO];
        [[[[flowController viewControllers] objectAtIndex:1] view] setHidden:YES];
    } else if (view.frame.origin.x > -100
               && view.frame.origin.x < 0) {
        destinationFrect = CGRectMake(0,
                                      0,
                                      view.frame.size.width,
                                      view.frame.size.height);
        [[[[flowController viewControllers] objectAtIndex:0] view] setHidden:NO];
        [[[[flowController viewControllers] objectAtIndex:1] view] setHidden:YES];
    }
    
    return destinationFrect;
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

@end
