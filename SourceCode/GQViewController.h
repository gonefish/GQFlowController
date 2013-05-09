//
//  GQViewController.h
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQViewControllerDelegate.h"

@class GQFlowController;

@interface GQViewController : UIViewController <GQViewControllerDelegate>

@property (nonatomic, strong) GQFlowController *flowController;

@property (nonatomic, getter=isActive) BOOL active;

@end

