//
//  Demo2ViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-5-11.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "Demo2ViewController.h"
#import "Demo2AViewController.h"
#import "Demo2BViewController.h"
#import "GQAppDelegate.h"

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

- (void)dealloc
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDataSource Protocol


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"Demo1Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:MyIdentifier];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"flowInViewController:animated:";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"setViewControllers:animated:";
            cell.detailTextLabel.text = @"setViewControllers:@[a, b] animated:YES";
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"Select Demos";
        cell.detailTextLabel.text = nil;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        Demo2AViewController *a = [[Demo2AViewController alloc] init];
        
        if (indexPath.row == 0) {
            [self.flowController flowInViewController:a animated:YES];
        } else if (indexPath.row == 1) {
            Demo2BViewController *b = [[Demo2BViewController alloc] init];
            [self.flowController setViewControllers:@[a, b] animated:YES];
        }
    } else if (indexPath.section == 1) {
        [(GQAppDelegate *)[[UIApplication sharedApplication] delegate] showSelectDemoActionSheet];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
