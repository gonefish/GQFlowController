//
//  GQFlowControllerTests.m
//  GQFlowControllerTests
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "GQFlowControllerTests.h"
#import <OCMock/OCMock.h>

#import "GQFlowController.h"

@implementation UIViewController (XCTestHelper)

- (void)addChildViewController:(UIViewController *)childController {
    
}

@end

@interface GQFlowControllerTests ()

@property (nonatomic, strong) GQFlowController *flowController;

@property (nonatomic) BOOL isiOS6;

@end

@implementation GQFlowControllerTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    self.flowController = [GQFlowController new];
    
    self.isiOS6 = [[[UIDevice currentDevice] systemVersion] integerValue] > 5;
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
    
    self.flowController = nil;
}


- (void)testFlowControllersIsViewLoaded
{
    XCTAssertFalse([self.flowController isViewLoaded], @"视图不应该被加载");
    
    NSArray *viewControllers = @[[UIViewController new], [UIViewController new]];
    
    self.flowController.viewControllers = viewControllers;
    
    XCTAssertFalse([self.flowController isViewLoaded], @"视图不应该被加载");
    
    [self.flowController flowInViewController:[UIViewController new] animated:YES];
    
    XCTAssertFalse([self.flowController isViewLoaded], @"视图不应该被加载");
    
    [self.flowController flowOutToRootViewControllerAnimated:YES];
    
    XCTAssertFalse([self.flowController isViewLoaded], @"视图不应该被加载");
}

- (void)testSetViewControllersAnimated
{    
    NSArray *aViewControllers = @[[UIViewController new], [UIViewController new]];
    
    self.flowController.viewControllers = aViewControllers;
    
    XCTAssertEqual([self.flowController.viewControllers count], (NSUInteger)2, @"属性设置不正确");
    
    for (UIViewController *controller in self.flowController.viewControllers) {
        XCTAssertEqualObjects(controller.flowController, self.flowController, @"子控制器访问不了");
    }
    
    NSArray *bViewControllers = @[[UIViewController new], [UIViewController new], [GQFlowController new]];
    
    self.flowController.viewControllers = bViewControllers;
    
    XCTAssertEqual([self.flowController.viewControllers count], (NSUInteger)2, @"属性设置不正确");
}

- (void)testTopViewController
{
    NSArray *aViewControllers = @[[UIViewController new], [UIViewController new]];
    
    self.flowController.viewControllers = aViewControllers;
    
    XCTAssertEqualObjects(self.flowController.topViewController, aViewControllers[1], @"");
}

- (void)testInitWithViewControllers
{
    UIViewController *v1 = [UIViewController new];
    UIViewController *v2 = [UIViewController new];
    
    NSArray *aViewControllers = @[v1, v2];
    
    GQFlowController *flowController =[[GQFlowController alloc] initWithViewControllers:aViewControllers];
    
    XCTAssertEqual([flowController.viewControllers count], (NSUInteger)2, @"");
    
    XCTAssertEqualObjects(flowController.topViewController, v2, @"");
    
    XCTAssertEqualObjects(flowController, v1.flowController, @"");
    XCTAssertEqualObjects(flowController, v2.flowController, @"");
}

- (void)testInitWithRootViewController
{
    UIViewController *testController = [UIViewController new];
    GQFlowController *flowController =[[GQFlowController alloc] initWithRootViewController:testController];
    
    XCTAssertEqual([flowController.viewControllers count], (NSUInteger)1, @"");
    
    XCTAssertEqualObjects(flowController.topViewController, testController, @"");
    
    XCTAssertEqualObjects(flowController, testController.flowController, @"");
}

- (void)testFlowInViewControllerAnimated
{
    UIViewController *partial0 = [UIViewController new];
    
    id vc0 = [OCMockObject partialMockForObject:partial0];
    
    self.flowController.viewControllers = @[vc0];
    
    UIViewController *partial1 = [UIViewController new];
    
    id vc1 = [OCMockObject partialMockForObject:partial1];
    
    [[vc1 expect] viewDidLoad];
    
    NSLog(@"dummy %@", self.flowController.view);
    
    [[vc1 expect] viewWillAppear:NO];
    
    [[vc0 expect] viewWillDisappear:NO];
    
    [[vc1 expect] viewDidAppear:NO];
    
    [[vc0 expect] viewDidDisappear:NO];
    
    [self.flowController flowInViewController:vc1 animated:NO];
    
    [vc1 verify];
    
    XCTAssertEqual([self.flowController.viewControllers count], (NSUInteger)2, @"");
    
    XCTAssertEqual([(UIViewController *)vc1 view].frame.origin.x, (CGFloat).0, @"");
}

- (void)testFlowOutViewControllerAnimated
{
    UIViewController *a = [UIViewController new];
    UIViewController *b = [UIViewController new];
    
    XCTAssertNil([self.flowController flowOutViewControllerAnimated:NO], @"没有viewControllers时，应该nil");
    
    self.flowController.viewControllers = @[a, b];
    
    XCTAssertEqualObjects(b.flowController, self.flowController, @"flowController属性没有被设置");
    
    UIViewController *pop = [self.flowController flowOutViewControllerAnimated:NO];
    
    XCTAssertEqualObjects(pop, b, @"滑出的对象不正确");
    
    XCTAssertNil(pop.flowController, @"滑出对象的flowController应该为空");
    
    XCTAssertEqual([self.flowController.viewControllers count], (NSUInteger)1, @"viewControllers没有更新");
    
    XCTAssertNil([self.flowController flowOutViewControllerAnimated:NO], @"至少要有一个");
    

    UIViewController *partial0 = [UIViewController new];
    
    id vc0 = [OCMockObject partialMockForObject:partial0];
    
    UIViewController *partial1 = [UIViewController new];
    
    id vc1 = [OCMockObject partialMockForObject:partial1];
    
    UIViewController *partial2 = [UIViewController new];
    
    id vc2 = [OCMockObject partialMockForObject:partial2];
    
    GQFlowController *flowController = [[GQFlowController alloc] initWithViewControllers:@[vc0, vc1, vc2]];
    
    NSLog(@"dummy %@", flowController.view);
    
    [(UIViewController *)vc1 view].frame = CGRectOffset([(UIViewController *)vc1 view].frame, 100.0, .0);
    
    [[vc1 expect] viewWillAppear:NO];
    [[vc1 expect] viewDidAppear:NO];
    [[vc0 expect] viewWillAppear:NO];
    [[vc0 expect] viewDidAppear:NO];
    [[vc2 expect] viewWillDisappear:NO];
    [[vc2 expect] viewDidDisappear:NO];
    
    [flowController flowOutViewControllerAnimated:NO];
    
    [vc1 verify];
    [vc0 verify];
    [vc2 verify];
}

- (void)testFlowOutToRootViewControllerAnimated
{
    NSArray *aViewControllers = @[[UIViewController new], [UIViewController new], [UIViewController new], [UIViewController new]];
    
    self.flowController.viewControllers = aViewControllers;
    
    XCTAssertEqual([[self.flowController flowOutToRootViewControllerAnimated:NO] count], (NSUInteger)3, @"");
    
    XCTAssertEqual([self.flowController.viewControllers count], (NSUInteger)1, @"viewControllers没有更新");
}

- (void)testFlowOutToViewControllerAnimated
{
    UIViewController *toViewController = [UIViewController new];
    NSArray *aViewControllers = @[[UIViewController new], [UIViewController new], toViewController, [UIViewController new]];
    
    self.flowController.viewControllers = aViewControllers;
    
    XCTAssertEqual([[self.flowController flowOutToViewController:toViewController animated:NO] count], (NSUInteger)1, @"");
    
    XCTAssertEqual([self.flowController.viewControllers count], (NSUInteger)3, @"viewControllers没有更新");
}

- (void)testRotations
{    
    id topViewController = [OCMockObject mockForClass:[UIViewController class]];
    
    if (self.isiOS6) {
        XCTAssertTrue([self.flowController supportedInterfaceOrientations], @"没有调用默认的方法");
    } else {
        XCTAssertTrue([self.flowController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait], @"没有调用默认的方法");
    }
    
    [self.flowController performSelector:@selector(setTopViewController:)
                              withObject:topViewController];
    
    XCTAssertEqualObjects(topViewController, self.flowController.topViewController, @"私有属性设置不正确");
    
    if (!self.isiOS6) {
        [[[topViewController stub] andReturnValue:@YES] shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown];
        
        XCTAssertTrue([self.flowController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown], @"没有调用topViewController的说法");
    }
}

- (void)testDidReceiveMemoryWarning
{
    UIViewController *a = [UIViewController new];
    UIViewController *b = [UIViewController new];
    UIViewController *c = [UIViewController new];
    UIViewController *d = [UIViewController new];
    
    GQFlowController *flowController = nil;
    
    flowController = [[GQFlowController alloc] initWithViewControllers:@[a]];
    NSLog(@"dummy %@", flowController.view);
    
    [flowController didReceiveMemoryWarning];
    
    XCTAssertTrue([a isViewLoaded], @"不能释放");
    
    [flowController flowInViewController:b animated:NO];
    
    [flowController didReceiveMemoryWarning];
    
    XCTAssertFalse([a isViewLoaded], @"安全释放");
    XCTAssertTrue([b isViewLoaded], @"不能释放");
    
    [flowController flowOutViewControllerAnimated:NO];
    
    XCTAssertTrue([a isViewLoaded], @"正常显示");
    
    flowController = [[GQFlowController alloc] initWithViewControllers:@[a, b]];
    NSLog(@"dummy %@", flowController.view);
    
    b.view.backgroundColor = [UIColor clearColor];
    
    [flowController didReceiveMemoryWarning];
    
    XCTAssertTrue([a isViewLoaded], @"不能释放");
    XCTAssertTrue([b isViewLoaded], @"不能释放");
    
    flowController = [[GQFlowController alloc] initWithViewControllers:@[a, b, c, d]];
    NSLog(@"dummy %@", flowController.view);
    
    d.view.frame = CGRectOffset(d.view.frame, 100.0, .0);

    [flowController didReceiveMemoryWarning];

    XCTAssertFalse([a isViewLoaded], @"安全释放");
    XCTAssertFalse([b isViewLoaded], @"安全释放");
    XCTAssertTrue([c isViewLoaded], @"不能释放");
    XCTAssertTrue([d isViewLoaded], @"不能释放");

    UIViewController *e = [UIViewController new];
    
    flowController = [[GQFlowController alloc] initWithViewControllers:@[a, b, c, d, e]];
    NSLog(@"dummy %@", flowController.view);

    [flowController didReceiveMemoryWarning];

    XCTAssertFalse([a isViewLoaded], @"安全释放");
    XCTAssertFalse([b isViewLoaded], @"安全释放");
    XCTAssertFalse([c isViewLoaded], @"安全释放");
    XCTAssertFalse([d isViewLoaded], @"安全释放");
    XCTAssertTrue([e isViewLoaded], @"不能释放");
}

#pragma mark - GQFlowControllerAdditions

- (void)testPrivateFlowControllerSetter
{
    UIViewController *vc = [[UIViewController alloc] init];
    
    XCTAssertNil(vc.flowController, @"don't setting flowController");
    
    GQFlowController *flowController = [[GQFlowController alloc] init];
    
    [vc performSelector:@selector(setFlowController:)
             withObject:flowController];
    
    XCTAssertNotNil(vc.flowController, @"flowController settings");
}

- (void)testFlowInDirection
{
    UIViewController *vc = [[UIViewController alloc] init];
    
    XCTAssertEqual(vc.flowInDirection, GQFlowDirectionLeft, @"默认值不正确");
    
    vc.flowInDirection = GQFlowDirectionRight;
    
    XCTAssertEqual(vc.flowInDirection, GQFlowDirectionRight, @"赋值不不正确");
}

- (void)testFlowOutDirection
{
    UIViewController *vc = [[UIViewController alloc] init];
    
    XCTAssertEqual(vc.flowOutDirection, GQFlowDirectionRight, @"默认值不正确");
    
    vc.flowOutDirection = GQFlowDirectionLeft;
    
    XCTAssertEqual(vc.flowOutDirection, GQFlowDirectionLeft, @"赋值不不正确");
}

- (void)testOverlayContent
{
    UIViewController *vc = [[UIViewController alloc] init];
    
    [vc setOverlayContent:YES];
    
    XCTAssertEqual([[vc.view subviews] count], (NSUInteger)1, @"");
    
    XCTAssertEqual([[[[vc.view subviews] lastObject] subviews] count], (NSUInteger)0, @"透明层已经添加");
    
    XCTAssertEqual(vc.isOverlayContent, YES, @"");
    
    [vc setOverlayContent:NO];
    
    XCTAssertEqual([[vc.view subviews] count], (NSUInteger)0, @"");
    
    [vc setOverlayContent:YES enabledShotView:YES];
    
    XCTAssertEqual([[[[vc.view subviews] lastObject] subviews] count], (NSUInteger)2, @"截图已经添加");
}



#pragma mark - GQViewController Protocol

- (void)testShouldAutomaticallyOverlayContent
{
    UIViewController *vc = [[UIViewController alloc] init];
    
    XCTAssertTrue([self.flowController performSelector:@selector(shouldAutomaticallyOverlayContentForViewController:)
                                           withObject:vc], @"");
    
    id vc2 = [OCMockObject mockForProtocol:@protocol(GQViewController)];
    
    [[[vc2 stub] andReturnValue:@NO] shouldAutomaticallyOverlayContent];
    
    XCTAssertFalse([self.flowController performSelector:@selector(shouldAutomaticallyOverlayContentForViewController:)
                                           withObject:vc2], @"");
    
    id vc3 = [OCMockObject mockForProtocol:@protocol(GQViewController)];
    
    [[[vc3 stub] andReturnValue:@YES] shouldAutomaticallyOverlayContent];
    
    XCTAssertTrue([self.flowController performSelector:@selector(shouldAutomaticallyOverlayContentForViewController:)
                                           withObject:vc3], @"");
}

@end
