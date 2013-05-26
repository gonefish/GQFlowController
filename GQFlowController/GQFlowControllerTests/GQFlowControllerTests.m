//
//  GQFlowControllerTests.m
//  GQFlowControllerTests
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 gonefish@gmail.com. All rights reserved.
//

#import "GQFlowControllerTests.h"

@implementation GQFlowControllerTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    self.flowController = [GQFlowController new];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
    
    self.flowController = nil;
}

- (void)testViewControllersSetter
{    
    NSArray *aViewControllers = @[[UIViewController new], [GQViewController new]];
    
    self.flowController.viewControllers = aViewControllers;
    
    STAssertEquals([self.flowController.viewControllers count], (NSUInteger)1, @"");
    
    for (GQViewController *controller in self.flowController.viewControllers) {
        STAssertEqualObjects(controller.flowController, self.flowController, @"");
    }
}

- (void)testTopViewController
{
    NSArray *aViewControllers = @[[GQViewController new], [GQViewController new]];
    
    self.flowController.viewControllers = aViewControllers;
    
    STAssertEqualObjects(self.flowController.topViewController, [aViewControllers objectAtIndex:1], @"");
}

- (void)testInitWithViewControllers
{
    NSArray *aViewControllers = @[[GQViewController new], [GQViewController new]];
    
    GQFlowController *flowController =[[GQFlowController alloc] initWithViewControllers:aViewControllers];
    
    STAssertEqualObjects(flowController.topViewController, [aViewControllers objectAtIndex:1], @"");
}

@end
