//
//  GQAppDelegate.h
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQFlowController.h"
#import "GQNavigationController.h"

@interface GQAppDelegate : UIResponder <
UIApplicationDelegate,
UIActionSheetDelegate
>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GQFlowController *flowController;
@property (strong, nonatomic) GQNavigationController *navigationController;

- (void)showSelectDemoActionSheet;

@end
