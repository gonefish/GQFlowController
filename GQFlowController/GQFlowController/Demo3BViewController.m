//
//  Demo3BViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-7-20.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "Demo3BViewController.h"

@interface Demo3BViewController ()

@end

@implementation Demo3BViewController

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

- (IBAction)outAction:(id)sender {
    [self.flowController flowOutViewControllerAnimated:YES];
}

#pragma mark - GQFlowControllerDelegate

- (CGRect)flowController:(GQFlowController *)flowController destinationRectForFlowDirection:(GQFlowDirection)direction;
{
    CGFloat w = 400.0;
    CGFloat h = 300.0;
    
    return CGRectMake((flowController.view.bounds.size.width - w) / 2.0,
                      (flowController.view.bounds.size.height - h) / 2.0,
                      w,
                      h);
}

@end
