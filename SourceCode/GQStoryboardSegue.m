//
//  GQStoryboardSegue.m
//  GQFlowController
//
//  Created by 钱国强 on 14-2-1.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import "GQStoryboardSegue.h"

@implementation GQStoryboardSegue

- (void)perform
{
    if ([self.sourceViewController respondsToSelector:@selector(flowController)]) {
        GQFlowController *flowController = [(UIViewController *)self.sourceViewController flowController];
        
        if (flowController) {
            [flowController flowInViewController:self.destinationViewController
                                        animated:YES];
        }
    }
}

@end
