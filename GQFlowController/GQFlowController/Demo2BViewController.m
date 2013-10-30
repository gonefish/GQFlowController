//
//  Demo2BViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-5-18.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "Demo2BViewController.h"

@interface Demo2BViewController ()

@end

@implementation Demo2BViewController


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

- (void)dealloc
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"%@ viewWillAppear", NSStringFromClass([self class]));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"%@ viewDidAppear", NSStringFromClass([self class]));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSLog(@"%@ viewWillDisappear", NSStringFromClass([self class]));
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSLog(@"%@ viewDidDisappear", NSStringFromClass([self class]));
}

#pragma mark - GQViewController

- (BOOL)shouldFlowToRect:(CGRect)frame
{
    if (frame.origin.x >= .0) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UITableViewDataSource Protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"Demo1Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:MyIdentifier];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"flowOutToRootViewControllerAnimated:";
        cell.detailTextLabel.text = @"Press to right moveing";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"setViewControllers:animated:";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.row == 0) {
        [self.flowController flowOutToRootViewControllerAnimated:YES];
    } else if (indexPath.row == 1) {
        UIViewController *a = [self.flowController.viewControllers objectAtIndex:0];

        [self.flowController setViewControllers:@[a] animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
