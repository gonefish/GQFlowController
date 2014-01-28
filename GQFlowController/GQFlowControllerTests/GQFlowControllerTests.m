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

@interface MockGQViewController : UIViewController <GQViewController>

- (CGRect)destinationRectForFlowDirection:(GQFlowDirection)direction;

@end

@implementation MockGQViewController

- (CGRect)destinationRectForFlowDirection:(GQFlowDirection)direction
{
    return CGRectZero;
}

@end

@implementation UIViewController (GQFlowControllerAdditionsHelper)

- (void)addChildViewController:(UIViewController *)childController {
    
}

- (UIView *)overlayContentView {
    return nil;
}

@end

@interface GQFlowControllerTests ()

@property (nonatomic, strong) GQFlowController *flowController;

@property (nonatomic) BOOL isiOS6;

@property (nonatomic, weak) UIView *dummyView;

@end

@implementation GQFlowControllerTests

+ (id)mockViewController
{
    UIViewController *mockVC = [[UIViewController alloc] init];
    
    return [OCMockObject partialMockForObject:mockVC];
}

+ (id)mockGQViewController
{
    MockGQViewController *mockVC = [[MockGQViewController alloc] init];
    
    return [OCMockObject partialMockForObject:mockVC];
}

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
    id vc0 = [GQFlowControllerTests mockViewController];
    id vc1 = [GQFlowControllerTests mockViewController];
    
    self.flowController.viewControllers = @[vc0, vc1];
    
    XCTAssertEqual([self.flowController.viewControllers count], (NSUInteger)2, @"属性设置不正确");
    
    self.flowController.viewControllers = @[vc0, vc1, [GQFlowController new]];
    
    XCTAssertEqual([self.flowController.viewControllers count], (NSUInteger)2, @"非法视图控制器没有过滤");
    
    self.dummyView = self.flowController.view;
    
    id vc2 = [GQFlowControllerTests mockViewController];
    
    self.flowController.viewControllers = @[vc2, vc1];
    
    XCTAssertFalse([vc2 isViewLoaded], @"vc2应该延迟加载");
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
    id vc0 = [GQFlowControllerTests mockViewController];
    
    self.flowController.viewControllers = @[vc0];
    
    id vc1 = [GQFlowControllerTests mockViewController];
    
    [[vc1 expect] viewDidLoad];
    
    self.dummyView = self.flowController.view;
    
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
    

    id vc0 = [GQFlowControllerTests mockViewController];
    
    id vc1 = [GQFlowControllerTests mockViewController];
    
    id vc2 = [GQFlowControllerTests mockViewController];
    
    GQFlowController *flowController = [[GQFlowController alloc] initWithViewControllers:@[vc0, vc1, vc2]];
    
    self.dummyView = flowController.view;
    
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
    self.dummyView = flowController.view;
    
    [flowController didReceiveMemoryWarning];
    
    XCTAssertTrue([a isViewLoaded], @"不能释放");
    
    [flowController flowInViewController:b animated:NO];
    
    [flowController didReceiveMemoryWarning];
    
    XCTAssertFalse([a isViewLoaded], @"安全释放");
    XCTAssertTrue([b isViewLoaded], @"不能释放");
    
    [flowController flowOutViewControllerAnimated:NO];
    
    XCTAssertTrue([a isViewLoaded], @"正常显示");
    
    flowController = [[GQFlowController alloc] initWithViewControllers:@[a, b]];
    self.dummyView = flowController.view;
    
    b.view.backgroundColor = [UIColor clearColor];
    
    [flowController didReceiveMemoryWarning];
    
    XCTAssertTrue([a isViewLoaded], @"不能释放");
    XCTAssertTrue([b isViewLoaded], @"不能释放");
    
    CGRect frame = CGRectMake(10, 10, 10, 10);
    
    id dmock = [GQFlowControllerTests mockGQViewController];
    
    [[[dmock stub] andReturnValue:OCMOCK_VALUE(frame)] destinationRectForFlowDirection:GQFlowDirectionLeft];
    
    flowController = [[GQFlowController alloc] initWithViewControllers:@[a, b, c, dmock]];
    
    self.dummyView = flowController.view;

    [flowController didReceiveMemoryWarning];

    XCTAssertFalse([a isViewLoaded], @"安全释放");
    XCTAssertFalse([b isViewLoaded], @"安全释放");
    XCTAssertTrue([c isViewLoaded], @"不能释放");
    XCTAssertTrue([dmock isViewLoaded], @"不能释放");

    UIViewController *e = [UIViewController new];
    
    flowController = [[GQFlowController alloc] initWithViewControllers:@[a, b, c, d, e]];
    self.dummyView = flowController.view;

    [flowController didReceiveMemoryWarning];

    XCTAssertFalse([a isViewLoaded], @"安全释放");
    XCTAssertFalse([b isViewLoaded], @"安全释放");
    XCTAssertFalse([c isViewLoaded], @"安全释放");
    XCTAssertFalse([d isViewLoaded], @"安全释放");
    XCTAssertTrue([e isViewLoaded], @"不能释放");
}

- (void)testViewDidLoadViewControllers
{
    UIViewController *vc0 = [[UIViewController alloc] init];
    UIViewController *vc1 = [[UIViewController alloc] init];
    GQFlowController *flowController = [[GQFlowController alloc] initWithViewControllers:@[vc0, vc1]];
    
    NSArray *vcs = [flowController performSelector:@selector(viewDidLoadViewControllers)];
    
    XCTAssertEqual([vcs count], (NSUInteger)1, @"只需要加载vc1");
    XCTAssertEqualObjects(vc1, vcs[0], @"加载的视图是vc1");
    
    UIViewController *vc2 = [[UIViewController alloc] init];
    
    CGRect frame = CGRectMake(10, 10, 10, 10);
    
    id vc3mock = [GQFlowControllerTests mockGQViewController];
    
    [[[vc3mock stub] andReturnValue:OCMOCK_VALUE(frame)] destinationRectForFlowDirection:GQFlowDirectionLeft];
    
    GQFlowController *flowController2 = [[GQFlowController alloc] initWithViewControllers:@[vc2, vc3mock]];
    
    NSArray *vcs2 = [flowController2 performSelector:@selector(viewDidLoadViewControllers)];
    
    XCTAssertEqual([vcs2 count], (NSUInteger)2, @"需要加载vc2, vc3");
    XCTAssertEqualObjects(vc2, vcs2[0], @"加载的视图是vc2");
    XCTAssertEqualObjects(vc3mock, vcs2[1], @"加载的视图是vc3mock");
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

- (void)testFlowController
{
    id vc0 = [GQFlowControllerTests mockViewController];
    id vc1 = [GQFlowControllerTests mockViewController];
    
    NSArray *aViewControllers = @[vc0, vc1];
    
    self.flowController.viewControllers = aViewControllers;
    
    for (UIViewController *controller in self.flowController.viewControllers) {
        XCTAssertEqualObjects(controller.flowController, self.flowController, @"flowController控制器访问不了");
    }
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
    
    
    UIViewController *vc1 = [[UIViewController alloc] init];
    
    [self.flowController flowInViewController:vc1 animated:NO];
    
    self.dummyView = self.flowController.view;
    
    UIViewController *vc2 = [[UIViewController alloc] init];
    
    [self.flowController flowInViewController:vc2 animated:NO];
    
    XCTAssertTrue(vc1.isOverlayContent, @"有遮罩层");
    
    UIViewController *vc3 = [[UIViewController alloc] init];
    
    [self.flowController flowInViewController:vc3 animated:NO];
    
    XCTAssertTrue(vc1.isOverlayContent, @"有遮罩层");
    XCTAssertTrue(vc2.isOverlayContent, @"有遮罩层");
    
    [self.flowController didReceiveMemoryWarning];
    
    [self.flowController flowOutViewControllerAnimated:NO];
    
    XCTAssertTrue(vc1.isOverlayContent, @"有遮罩层");
    XCTAssertFalse(vc2.isOverlayContent, @"没有遮罩层");
    
    
    id vc4 = [GQFlowControllerTests mockViewController];
    UIView *aOverlayView = [[UIView alloc] init];
    aOverlayView.backgroundColor = [UIColor redColor];
    [[[vc4 stub] andReturn:aOverlayView] overlayContentView];
    
    [vc4 setOverlayContent:YES];
    
    XCTAssertEqualObjects([[[(UIViewController *)vc4 view] subviews] lastObject], aOverlayView, @"自定义遮罩层无效");
    XCTAssertEqualObjects([[[[(UIViewController *)vc4 view] subviews] lastObject] backgroundColor], [UIColor redColor], @"自定义遮罩层颜色正常");
    
    id vc5 = [GQFlowControllerTests mockViewController];
    UIView *aOverlayView5 = [[UIView alloc] init];
    aOverlayView5.backgroundColor = [UIColor redColor];
    [[[vc5 stub] andReturn:nil] overlayContentView];
    
    XCTAssertNotEqualObjects([[[[(UIViewController *)vc5 view] subviews] lastObject] backgroundColor], [UIColor redColor], @"自定义遮罩层颜色正常");
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
