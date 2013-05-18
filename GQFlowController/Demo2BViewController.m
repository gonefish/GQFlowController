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

@end
