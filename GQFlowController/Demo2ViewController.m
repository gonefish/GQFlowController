//
//  Demo2ViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-5-11.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "Demo2ViewController.h"
#import "Demo2AViewController.h"

@interface Demo2ViewController ()

@end

@implementation Demo2ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)flowAction:(id)sender {
    Demo2AViewController *controller = [[Demo2AViewController alloc] initWithNibName:@"Demo2AViewController" bundle:nil];
    [self.flowController flowInViewController:controller animated:YES];
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
