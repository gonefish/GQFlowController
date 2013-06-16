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

- (void)testSetViewControllersAnimated
{    
    NSArray *aViewControllers = @[[UIViewController new], [UIViewController new]];
    
    self.flowController.viewControllers = aViewControllers;
    
    STAssertEquals([self.flowController.viewControllers count], (NSUInteger)1, @"");
    
    for (UIViewController *controller in self.flowController.viewControllers) {
        STAssertEqualObjects(controller.flowController, self.flowController, @"");
    }
}

- (void)testTopViewController
{
    NSArray *aViewControllers = @[[UIViewController new], [UIViewController new]];
    
    self.flowController.viewControllers = aViewControllers;
    
    STAssertEqualObjects(self.flowController.topViewController, [aViewControllers objectAtIndex:1], @"");
}

- (void)testInitWithViewControllers
{
    UIViewController *v1 = [UIViewController new];
    UIViewController *v2 = [UIViewController new];
    
    NSArray *aViewControllers = @[v1, v2];
    
    GQFlowController *flowController =[[GQFlowController alloc] initWithViewControllers:aViewControllers];
    
    STAssertEquals([flowController.viewControllers count], (NSUInteger)2, @"");
    
    STAssertEqualObjects(flowController.topViewController, v2, @"");
    
    STAssertEqualObjects(flowController, v1.flowController, @"");
    STAssertEqualObjects(flowController, v2.flowController, @"");
}

- (void)testInitWithRootViewController
{
    UIViewController *testController = [UIViewController new];
    GQFlowController *flowController =[[GQFlowController alloc] initWithRootViewController:testController];
    
    STAssertEquals([flowController.viewControllers count], (NSUInteger)1, @"");
    
    STAssertEqualObjects(flowController.topViewController, testController, @"");
    
    STAssertEqualObjects(flowController, testController.flowController, @"");
}

- (void)testFlowInViewControllerAnimated
{
    UIViewController *testController = [UIViewController new];
    
    [self.flowController flowInViewController:testController animated:NO];
    
    STAssertEquals([self.flowController.viewControllers count], (NSUInteger)1, @"");
}

- (void)testFlowOutViewControllerAnimated
{
    UIViewController *a = [UIViewController new];
    UIViewController *b = [UIViewController new];
    
    STAssertNil([self.flowController flowOutViewControllerAnimated:NO], @"没有viewControllers时，应该nil");
    
    self.flowController.viewControllers = @[a, b];
    
    STAssertEqualObjects(b.flowController, self.flowController, @"flowController属性没有被设置");
    
    UIViewController *pop = [self.flowController flowOutViewControllerAnimated:NO];
    
    STAssertEqualObjects(pop, b, @"滑出的对象不正确");
    
    STAssertNil(pop.flowController, @"滑出对象的flowController应该为空");
    
    STAssertEquals([self.flowController.viewControllers count], (NSUInteger)1, @"viewControllers没有更新");
    
    STAssertNil([self.flowController flowOutViewControllerAnimated:NO], @"至少要有一个");
}

- (void)testFlowOutToRootViewControllerAnimated
{
    NSArray *aViewControllers = @[[UIViewController new], [UIViewController new], [UIViewController new], [UIViewController new]];
    
    self.flowController.viewControllers = aViewControllers;
    
    STAssertEquals([[self.flowController flowOutToRootViewControllerAnimated:NO] count], (NSUInteger)3, @"");
    
    STAssertEquals([self.flowController.viewControllers count], (NSUInteger)1, @"viewControllers没有更新");
}

- (void)testFlowOutToViewControllerAnimated
{
    UIViewController *toViewController = [UIViewController new];
    NSArray *aViewControllers = @[[UIViewController new], [UIViewController new], toViewController, [UIViewController new]];
    
    self.flowController.viewControllers = aViewControllers;
    
    STAssertEquals([[self.flowController flowOutToViewController:toViewController animated:NO] count], (NSUInteger)1, @"");
    
    STAssertEquals([self.flowController.viewControllers count], (NSUInteger)3, @"viewControllers没有更新");
}

@end
