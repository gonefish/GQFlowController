//
//  GQNavigationController.h
//  GQFlowController
//
//  Created by 钱国强 on 13-10-21.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "GQFlowController.h"

@interface GQNavigationController : GQFlowController

@property (nonatomic, strong, readonly) UINavigationController *gqNavigationController;

- (id)initWithNavigationControllers:(NSArray *)viewControllers belowViewControllers:(NSArray *)belowViewControllers;

@end
