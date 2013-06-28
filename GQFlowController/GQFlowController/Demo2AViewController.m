//
//  Demo2AViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-5-14.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "Demo2AViewController.h"
#import "Demo2BViewController.h"

@interface Demo2AViewController ()

@end

@implementation Demo2AViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)backAction:(id)sender {
    [self.flowController flowOutViewControllerAnimated:YES];
}
- (IBAction)flowbAction:(id)sender {
    Demo2BViewController *b = [[Demo2BViewController alloc] initWithNibName:@"Demo2BViewController" bundle:nil];
    [self.flowController flowInViewController:b
                                     animated:YES];
    
//    UIViewController *a = [self.flowController.viewControllers objectAtIndex:0];
//    
//    [self.flowController setViewControllers:@[a] animated:YES];
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

#pragma mark - GQFlowControllerDelegate

- (CGFloat)flowingBoundary:(GQFlowController *)flowController
{
    return 0.15;
}

- (UIViewController *)flowController:(GQFlowController *)flowController viewControllerForFlowDirection:(GQFlowDirection)direction
{
    if (direction == GQFlowDirectionLeft) {
        return [[Demo2BViewController alloc] initWithNibName:@"Demo2BViewController" bundle:nil];
    } else {
        return self;
    }
}


#pragma mark - UITableViewDataSource Protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
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
        cell.textLabel.text = @"flowOutViewControllerAnimated:";
        cell.detailTextLabel.text = @"Press to right moveing";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"setViewControllers:animated:";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"flowInViewController:animated:";
        cell.detailTextLabel.text = @"Press to left moveing";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.row == 0) {
        [self.flowController flowOutViewControllerAnimated:YES];
    } else if (indexPath.row == 1) {        
        UIViewController *a = [self.flowController.viewControllers objectAtIndex:0];

        [self.flowController setViewControllers:@[a] animated:YES];
    } else if (indexPath.row == 2) {
        Demo2BViewController *b = [[Demo2BViewController alloc] init];
        
        [self.flowController flowInViewController:b
                                         animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
    
}

@end
