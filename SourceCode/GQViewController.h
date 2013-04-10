//
//  GQViewController.h
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GQFlowController;

typedef enum {
    GQFlowDirectionRight,
    GQFlowDirectionLeft,
    GQFlowDirectionUp,
    GQFlowDirectionDown
} GQFlowDirection;

@interface GQViewController : UIViewController

@property (nonatomic) GQFlowDirection outDirection;
@property (nonatomic) GQFlowDirection inDirection;
@property (nonatomic, strong) GQFlowController *flowController;

@end
