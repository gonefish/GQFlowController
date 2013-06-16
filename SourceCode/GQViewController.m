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



- (UIView *)flowingOverlayView
{
    if (_flowingOverlayView == nil) {
        _flowingOverlayView = [[UIView alloc] initWithFrame:self.view.frame];
    }
    
    return _flowingOverlayView;
}

@end
