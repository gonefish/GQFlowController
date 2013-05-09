//
//  Demo1ViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-4-21.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "Demo1ViewController.h"
#import "GQFlowController.h"

#define OFFSET 70.0

@interface Demo1ViewController ()

@end

@implementation Demo1ViewController

#pragma mark - GQViewControllerDelegate

- (UIView *)flowController:(GQFlowController *)flowController viewForFlowDirection:(GQFlowDirection)direction
{
    // 从起始位置向左滑动
    if (direction == GQFlowDirectionLeft
        && self.view.frame.origin.x == 0) {
        [[[[flowController viewControllers] objectAtIndex:0] view] setHidden:NO];
        [[[[flowController viewControllers] objectAtIndex:1] view] setHidden:YES];
    } else if (direction == GQFlowDirectionRight
               && self.view.frame.origin.x == 0) {
        [[[[flowController viewControllers] objectAtIndex:1] view] setHidden:NO];
        [[[[flowController viewControllers] objectAtIndex:0] view] setHidden:YES];
    }
    
    return self.view;
}

- (BOOL)flowController:(GQFlowController *)controller shouldMoveView:(UIView *)view toFrame:(CGRect)frame
{
    // 不允许上下移动
    if (frame.origin.y != .0) {
        return NO;
    }

    return YES;
}

- (CGRect)flowController:(GQFlowController *)flowController destinationRectForView:(UIView *)view flowDirection:(GQFlowDirection)direction
{
    CGRect destinationFrect = [super flowController:flowController destinationRectForView:view flowDirection:direction];
    
    if (direction == GQFlowDirectionLeft) {
        // 右滑后，左滑回
        if (view.frame.origin.x <= flowController.view.frame.size.width - OFFSET
            && view.frame.origin.x > flowController.view.frame.size.width - OFFSET - OFFSET) {
            destinationFrect = CGRectMake(flowController.view.frame.size.width - OFFSET,
                                          0,
                                          view.frame.size.width,
                                          view.frame.size.height);
        } else if (view.frame.origin.x <= flowController.view.frame.size.width - OFFSET - OFFSET
                   && view.frame.origin.x > 0) {
            destinationFrect = CGRectMake(0,
                                          0,
                                          view.frame.size.width,
                                          view.frame.size.height);
        } else if (view.frame.origin.x < 0
                   && view.frame.origin.x > -OFFSET) {
            // 向左滑动
            destinationFrect = CGRectMake(0,
                                          0,
                                          view.frame.size.width,
                                          view.frame.size.height);
        } else if (view.frame.origin.x <= -OFFSET
                   && view.frame.origin.x >= -flowController.view.frame.size.width) {
            destinationFrect = CGRectMake(-flowController.view.frame.size.width + OFFSET,
                                          0,
                                          view.frame.size.width,
                                          view.frame.size.height);
        }
    } else if (direction == GQFlowDirectionRight) {
        // 向右滑动
        if (view.frame.origin.x > 0
            && view.frame.origin.x < OFFSET) {
            destinationFrect = CGRectMake(0,
                                          0,
                                          view.frame.size.width,
                                          view.frame.size.height);
        } else if (view.frame.origin.x >= OFFSET
               && view.frame.origin.x < flowController.view.frame.size.width) {
            destinationFrect = CGRectMake(flowController.view.frame.size.width - OFFSET,
                                      0,
                                      view.frame.size.width,
                                      view.frame.size.height);
        } else if (view.frame.origin.x > -flowController.view.frame.size.width + OFFSET
                   && view.frame.origin.x < -flowController.view.frame.size.width + OFFSET + OFFSET) {
            // 左滑后，右滑回
            destinationFrect = CGRectMake(-flowController.view.frame.size.width + OFFSET,
                                          0,
                                          view.frame.size.width,
                                          view.frame.size.height);
        } else if (view.frame.origin.x > -flowController.view.frame.size.width + OFFSET + OFFSET
                   && view.frame.origin.x < 0) {
            destinationFrect = CGRectMake(0,
                                          0,
                                          view.frame.size.width,
                                          view.frame.size.height);
        }
    }
    
    return destinationFrect;
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
