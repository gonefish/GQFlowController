//
//  Demo4ViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-10-14.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "Demo4ViewController.h"
#import "GQAppDelegate.h"

@interface Demo4ViewController ()

@end

@implementation Demo4ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Demo4";
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

- (IBAction)selectDemoAction:(id)sender {
   [(GQAppDelegate *)[[UIApplication sharedApplication] delegate] showSelectDemoActionSheet];
}

- (IBAction)pushAction:(id)sender {
    UIViewController *vc = [[Demo4ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
