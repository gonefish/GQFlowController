//
//  Demo3ViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-7-17.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "Demo3ViewController.h"
#import "Demo3AViewController.h"
#import "Demo3BViewController.h"

@interface Demo3ViewController ()

@end

@implementation Demo3ViewController

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)flowAAction:(id)sender {
    Demo3AViewController *a = [[Demo3AViewController alloc] init];
    
    [self.flowController flowInViewController:a animated:YES];
}
- (IBAction)flowBAction:(id)sender {
    Demo3BViewController *a = [[Demo3BViewController alloc] init];
    a.flowOutDirection = GQFlowDirectionLeft;
    
    [self.flowController flowInViewController:a animated:YES];
}

@end
