//
//  Demo2AViewController.h
//  GQFlowController
//
//  Created by 钱国强 on 13-5-14.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "GQFlowController.h"
#import "GQFlowControllerDelegate.h"
#import "Demo2BViewController.h"

@interface Demo2AViewController : GQViewController <GQFlowControllerDelegate>

@property (nonatomic, strong) Demo2BViewController *bViewController;

@end
