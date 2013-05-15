//
//  GQViewController.h
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQViewControllerDelegate.h"

@interface GQViewController : UIViewController <GQViewControllerDelegate>

@property (nonatomic, getter=isActive) BOOL active;


@end

