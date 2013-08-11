//
//  Demo3CViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-7-20.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "Demo3CViewController.h"

@interface Demo3CViewController ()

@end

@implementation Demo3CViewController

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

- (CGFloat)flowingBoundary
{
    return 0.15;
}

@end
