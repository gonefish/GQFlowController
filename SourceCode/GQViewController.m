//
//  GQViewController.m
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "GQViewController.h"

@interface GQViewController ()

@property (nonatomic, strong) UIView *coverView;

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

- (UIView *)coverView
{
    if (_coverView == nil) {
        _coverView = [[UIView alloc] initWithFrame:self.view.frame];
    }
    
    return _coverView;
}

- (void)setActive:(BOOL)active
{
    _active = active;
    
    if (self.isActive) {
        [self.coverView removeFromSuperview];
    } else {
        [self.view addSubview:self.coverView];
    }
}

@end
