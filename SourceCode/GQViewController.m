//
//  GQViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "GQViewController.h"

@interface GQViewController ()

@property (nonatomic, strong) UIView *flowingOverlayView;

@end

@implementation GQViewController

- (id)init
{
    self = [super init];
    
    if (self) {
        self.inFlowDirection = GQFlowDirectionLeft;
        self.outFlowDirection = GQFlowDirectionRight;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.inFlowDirection = GQFlowDirectionLeft;
        self.outFlowDirection = GQFlowDirectionRight;
    }
    
    return self;
}

- (UIView *)flowingOverlayView
{
    if (_flowingOverlayView == nil) {
        _flowingOverlayView = [[UIView alloc] initWithFrame:self.view.frame];
    }
    
    return _flowingOverlayView;
}

- (void)setActive:(BOOL)active
{
    _active = active;
    
    if (self.isActive) {
        [self.flowingOverlayView removeFromSuperview];
    } else {
        [self.view addSubview:self.flowingOverlayView];
    }
}

@end
