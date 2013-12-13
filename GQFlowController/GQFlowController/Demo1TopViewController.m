//
//  Demo1ViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-4-21.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "Demo1TopViewController.h"
#import "GQFlowController.h"
#import "GQAppDelegate.h"

#define OFFSET 70.0

@interface Demo1TopViewController ()

@end

@implementation Demo1TopViewController

#pragma mark - GQViewController

- (UIViewController *)viewControllerForFlowDirection:(GQFlowDirection)direction
{
    UIViewController *leftViewController = [self.flowController viewControllers][0];
    leftViewController.overlayContent = YES;
    UIViewController *rightViewController = [self.flowController viewControllers][1];
    rightViewController.overlayContent = YES;
    
    if (direction == GQFlowDirectionLeft
        && self.view.frame.origin.x == 0) {
        leftViewController.view.hidden = NO;
        rightViewController.view.hidden = YES;
    } else if (direction == GQFlowDirectionRight
               && self.view.frame.origin.x == 0) {
        leftViewController.view.hidden = YES;
        rightViewController.view.hidden = NO;
    }
    
    return self;
}

- (CGRect)destinationRectForFlowDirection:(GQFlowDirection)direction
{
    CGRect destinationFrect = CGRectZero;
    
    if (direction == GQFlowDirectionLeft) {
        // 右滑后，左滑回
        if (self.view.frame.origin.x <= self.flowController.view.frame.size.width - OFFSET
            && self.view.frame.origin.x > self.flowController.view.frame.size.width - OFFSET - OFFSET) {
            destinationFrect = CGRectMake(self.flowController.view.frame.size.width - OFFSET,
                                          0,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
        } else if (self.view.frame.origin.x <= self.flowController.view.frame.size.width - OFFSET - OFFSET
                   && self.view.frame.origin.x > 0) {
            destinationFrect = CGRectMake(0,
                                          0,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
        } else if (self.view.frame.origin.x < 0
                   && self.view.frame.origin.x > -OFFSET) {
            // 向左滑动
            destinationFrect = CGRectMake(0,
                                          0,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
        } else if (self.view.frame.origin.x <= -OFFSET
                   && self.view.frame.origin.x >= -self.flowController.view.frame.size.width) {
            destinationFrect = CGRectMake(-self.flowController.view.frame.size.width + OFFSET,
                                          0,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
        }
    } else if (direction == GQFlowDirectionRight) {
        // 向右滑动
        if (self.view.frame.origin.x > 0
            && self.view.frame.origin.x < OFFSET) {
            destinationFrect = CGRectMake(0,
                                          0,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
        } else if (self.view.frame.origin.x >= OFFSET
               && self.view.frame.origin.x < self.flowController.view.frame.size.width) {
            destinationFrect = CGRectMake(self.flowController.view.frame.size.width - OFFSET,
                                      0,
                                      self.view.frame.size.width,
                                      self.view.frame.size.height);
        } else if (self.view.frame.origin.x > -self.flowController.view.frame.size.width + OFFSET
                   && self.view.frame.origin.x < -self.flowController.view.frame.size.width + OFFSET + OFFSET) {
            // 左滑后，右滑回
            destinationFrect = CGRectMake(-self.flowController.view.frame.size.width + OFFSET,
                                          0,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
        } else if (self.view.frame.origin.x > -self.flowController.view.frame.size.width + OFFSET + OFFSET
                   && self.view.frame.origin.x < 0) {
            destinationFrect = CGRectMake(0,
                                          0,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
        }
    }
    
    return destinationFrect;
}

- (void)updateOverlayContent
{
    UIViewController *leftViewController = [self.flowController viewControllers][0];
    UIViewController *rightViewController = [self.flowController viewControllers][1];
    UIViewController *topViewController = [self.flowController viewControllers][2];
    
    if (self.view.frame.origin.x > 0) {
        rightViewController.overlayContent = NO;
        topViewController.overlayContent = YES;
    } else if (self.view.frame.origin.x < 0) {
        leftViewController.overlayContent = NO;
        topViewController.overlayContent = YES;
    } else {
        leftViewController.overlayContent = YES;
        rightViewController.overlayContent = YES;
        topViewController.overlayContent = NO;
    }
}

- (void)didFlowToDestinationRect
{
    [self updateOverlayContent];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)clickAction:(id)sender {
    CGRect frame = CGRectMake(self.flowController.view.frame.size.width - OFFSET,
                              0,
                              self.view.frame.size.width,
                              self.view.frame.size.height);
    
    [self.flowController flowingViewController:self
                                       toFrame:frame
                               animationsBlock:nil
                               completionBlock:^(BOOL finished){
                                   [self updateOverlayContent];
                               }];
}
- (IBAction)selectDemos:(id)sender {
    [(GQAppDelegate *)[[UIApplication sharedApplication] delegate] showSelectDemoActionSheet];
}

- (void)overlayContentTapAction:(UITapGestureRecognizer *)gestureRecognizer
{
    CGRect frame = CGRectMake(0,
                              0,
                              self.view.frame.size.width,
                              self.view.frame.size.height);
    
    [self.flowController flowingViewController:self
                                       toFrame:frame
                               animationsBlock:nil
                               completionBlock:^(BOOL finished){
                                   [self updateOverlayContent];
                               }];
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
