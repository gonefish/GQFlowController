//
//  Demo3AViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-7-18.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "Demo3AViewController.h"

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

#pragma mark - GQFlowControllerDelegate

- (CGRect)flowController:(GQFlowController *)flowController destinationRectForFlowDirection:(GQFlowDirection)direction;
{
    CGFloat w = 300.0;
    
    return CGRectMake(w, .0, flowController.view.bounds.size.width - w, flowController.view.bounds.size.height);
}

@end
