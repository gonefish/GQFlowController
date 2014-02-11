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

@property (nonatomic, strong) NSMutableArray *autoVerifiedObjects;

@end

@implementation GQFlowControllerTests

- (id)mockViewController
{
    UIViewController *mockVC = [[UIViewController alloc] init];
    
    id mockObject = [OCMockObject partialMockForObject:mockVC];
    
    [self.autoVerifiedObjects addObject:mockObject];
    
    return mockObject;
}

- (id)mockGQViewController
{
    MockGQViewController *mockVC = [[MockGQViewController alloc] init];
    
    id mockObject = [OCMockObject partialMockForObject:mockVC];
    
    [self.autoVerifiedObjects addObject:mockObject];
    
    return mockObject;
}

- (id)niceMockForClass:(Class)aClass;
{
    id mockObject = [OCMockObject niceMockForClass:aClass];
    
    [self.autoVerifiedObjects addObject:mockObject];
    
    return mockObject;
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    self.flowController = [GQFlowController new];
    
    self.isiOS6 = [[[UIDevice currentDevice] systemVersion] integerValue] > 5;
    
    if (self.autoVerifiedObjects == nil) {
        self.autoVerifiedObjects = [NSMutableArray array];
    }
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
    
    self.flowController = nil;
    
    [self.autoVerifiedObjects makeObjectsPerformSelector:@selector(verify)];
    
    [self.autoVerifiedObjects removeAllObjects];
}

#pragma mark - Public API

- (void)testInitWithViewControllers
{
    UIViewController *vc0 = [[UIViewController alloc] init];
    
    UIViewController *vc1 = [[UIViewController alloc] init];
    
    GQFlowController *flowController =[[GQFlowController alloc] initWithViewControllers:@[vc0, vc1]];
    
    XCTAssertEqual([flowController.viewControllers count], (NSUInteger)2, @"视图控制器初始化失败");
    
    XCTAssertEqualObjects(flowController.topViewController, vc1, @"topViewController属性错误");
}

- (void)testInitWithRootViewController
{
    UIViewController *vc0 = [[UIViewController alloc] init];
    
    GQFlowController *flowController =[[GQFlowController alloc] initWithRootViewController:vc0];
    
    XCTAssertEqual([flowController.viewControllers count], (NSUInteger)1, @"视图控制器初始化失败");
}

- (void)testSetViewControllersAnimated
{
    id vc0 = [self mockViewController];
    id vc1 = [self mockViewController];
    
    self.flowController.viewControllers = @[vc0, vc1];
    
    XCTAssertEqual([self.flowController.viewControllers count], (NSUInteger)2, @"属性设置不正确");
    
    self.flowController.viewControllers = @[vc0, vc1, [GQFlowController new]];
    
    XCTAssertEqual([self.flowController.viewControllers count], (NSUInteger)2, @"非法视图控制器没有过滤");
    
    self.dummyView = self.flowController.view;
    
    id vc2 = [self mockViewController];
    
    self.flowController.viewControllers = @[vc2, vc1];
    
    XCTAssertFalse([vc2 isViewLoaded], @"vc2应该延迟加载");
}

- (void)testFlowInViewControllerAnimated
{
    id vc0 = [self mockViewController];
    
    GQFlowController *flowController = [[GQFlowController alloc] initWithViewControllers:@[vc0]];
    
    self.dummyView = flowController.view;
    
    id vc1 = [self mockViewController];
    
    [[vc1 expect] viewDidLoad];
    
    [[vc1 expect] viewWillAppear:NO];
    
    [[vc0 expect] viewWillDisappear:NO];
    
    [[vc1 expect] viewDidAppear:NO];
    
    [[vc0 expect] viewDidDisappear:NO];
    
    [flowController flowInViewController:vc1 animated:NO];
    [flowController flowInViewController:vc1 animated:NO];
    
    XCTAssertEqual([flowController.viewControllers count], (NSUInteger)2, @"viewControllers错误");
    
    XCTAssertNotNil([[(UIViewController *)vc1 view] superview], @"vc1的view没有正确添加");
    
    XCTAssertEqual(flowController.topViewController, vc1, @"topViewController属性错误");
}

- (void)testFlowOutViewControllerAnimated
{
    UIViewController *vca = [[UIViewController alloc] init];
    UIViewController *vcb = [[UIViewController alloc] init];
    
    GQFlowController *flowController = [[GQFlowController alloc] initWithViewControllers:@[vca, vcb]];
    
    UIViewController *flowOutVC = [flowController flowOutViewControllerAnimated:NO];
    
    XCTAssertEqualObjects(flowOutVC, vcb, @"滑出对象不正确");
    
    XCTAssertNil(flowOutVC.flowController, @"滑出对象的flowController应该为空");
    
    XCTAssertEqual([flowController.viewControllers count], (NSUInteger)1, @"viewControllers错误");
    
    XCTAssertNil([flowController flowOutViewControllerAnimated:NO], @"至少要有一个");
    
    
    id vc0 = [self mockViewController];
    
    id vc1 = [self mockGQViewController];
    CGRect frame = CGRectMake(10.0, 10.0, 100.0, 100.0);
    [[[vc1 stub] andReturnValue:OCMOCK_VALUE(frame)] destinationRectForFlowDirection:GQFlowDirectionLeft];
    
    id vc2 = [self mockViewController];
    
    id vc3 = [self niceMockForClass:[UIViewController class]];
    
    id vc4 = [self mockViewController];
    
    flowController = [[GQFlowController alloc] initWithViewControllers:@[vc4, vc0, vc1, vc2]];
    
    self.dummyView = flowController.view;
    
    [[vc2 expect] viewWillDisappear:NO];
    [[vc2 expect] viewDidDisappear:NO];
    [[vc1 expect] viewWillAppear:NO];
    [[vc1 expect] viewDidAppear:NO];
    [[vc0 expect] viewWillAppear:NO];
    [[vc0 expect] viewDidAppear:NO];
    [[vc4 expect] viewWillAppear:NO];
    [[vc4 expect] viewDidAppear:NO];
//    [[vc3 reject] viewWillAppear:NO];
//    [[vc3 reject] viewDidAppear:NO];
    
    [flowController flowOutViewControllerAnimated:NO];
}

- (void)testFlowOutToRootViewControllerAnimated
{
    UIViewController *vc0 = [[UIViewController alloc] init];
    UIViewController *vc1 = [[UIViewController alloc] init];
    UIViewController *vc2 = [[UIViewController alloc] init];
    UIViewController *vc3 = [[UIViewController alloc] init];
    
    GQFlowController *flowController = [[GQFlowController alloc] initWithViewControllers:@[vc0, vc1, vc2, vc3]];
    
    XCTAssertEqual([[flowController flowOutToRootViewControllerAnimated:NO] count], (NSUInteger)3, @"滑出的视图控制器不对");
    
    XCTAssertEqual([flowController.viewControllers count], (NSUInteger)1, @"viewControllers属性错误");
}

- (void)testFlowOutToViewControllerAnimated
{
    UIViewController *vc0 = [[UIViewController alloc] init];
    UIViewController *vc1 = [[UIViewController alloc] init];
    UIViewController *vc2 = [[UIViewController alloc] init];
    UIViewController *vc3 = [[UIViewController alloc] init];
    
    GQFlowController *flowController = [[GQFlowController alloc] initWithViewControllers:@[vc0, vc1, vc2, vc3]];
    
    XCTAssertEqual([[flowController flowOutToViewController:vc2 animated:NO] count], (NSUInteger)1, @"滑出的视图控制器不对");
    
    XCTAssertEqual([flowController.viewControllers count], (NSUInteger)3, @"viewControllers属性错误");
}

#pragma mark -


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



- (void)testTopViewController
{
    NSArray *aViewControllers = @[[UIViewController new], [UIViewController new]];
    
    self.flowController.viewControllers = aViewControllers;
    
    XCTAssertEqualObjects(self.flowController.topViewController, aViewControllers[1], @"");
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
    XCTAssertTrue(a.view.superview, @"a的视图没有被添加");
    
    flowController = [[GQFlowController alloc] initWithViewControllers:@[a, b]];
    self.dummyView = flowController.view;
    
    b.view.backgroundColor = [UIColor clearColor];
    
    [flowController didReceiveMemoryWarning];
    
    XCTAssertTrue([a isViewLoaded], @"不能释放");
    XCTAssertTrue([b isViewLoaded], @"不能释放");
    
    CGRect frame = CGRectMake(10, 10, 10, 10);
    
    id dmock = [self mockGQViewController];
    
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

- (void)testViewVisibleViewControllers
{
    UIViewController *vc0 = [[UIViewController alloc] init];
    UIViewController *vc1 = [[UIViewController alloc] init];
    GQFlowController *flowController = [[GQFlowController alloc] initWithViewControllers:@[vc0, vc1]];
    
    NSArray *vcs = [flowController performSelector:@selector(visibleViewControllers)];
    
    XCTAssertEqual([vcs count], (NSUInteger)1, @"只需要加载vc1");
    XCTAssertEqualObjects(vc1, vcs[0], @"加载的视图是vc1");
    
    vc1.view.alpha = .5;
    
    vcs = [flowController performSelector:@selector(visibleViewControllers)];
    
    XCTAssertEqual([vcs count], (NSUInteger)2, @"需要加载vc1和vc2");
    
    UIViewController *vc2 = [[UIViewController alloc] init];
    
    CGRect frame = CGRectMake(10, 10, 10, 10);
    
    id vc3mock = [self mockGQViewController];
    
    [[[vc3mock stub] andReturnValue:OCMOCK_VALUE(frame)] destinationRectForFlowDirection:GQFlowDirectionLeft];
    
    GQFlowController *flowController2 = [[GQFlowController alloc] initWithViewControllers:@[vc2, vc3mock]];
    
    NSArray *vcs2 = [flowController2 performSelector:@selector(visibleViewControllers)];
    
    XCTAssertEqual([vcs2 count], (NSUInteger)2, @"需要加载vc2, vc3");
    XCTAssertEqualObjects(vc2, vcs2[0], @"加载的视图是vc2");
    XCTAssertEqualObjects(vc3mock, vcs2[1], @"加载的视图是vc3mock");
    XCTAssertNotEqual(vc2.view.frame.origin.x, (CGFloat)10.0, @"下文视图默认偏移");
}

- (void)testViewWillAppear
{
    id vc0 = [self mockViewController];
    id vc1 = [self mockGQViewController];
    
    CGRect frame = CGRectMake(10, 10, 10, 10);
    [[[vc1 stub] andReturnValue:OCMOCK_VALUE(frame)] destinationRectForFlowDirection:GQFlowDirectionLeft];
    
    GQFlowController *flowController = [[GQFlowController alloc] initWithViewControllers:@[vc0, vc1]];
    
    [[vc0 expect] viewWillAppear:NO];
    [[vc1 expect] viewWillAppear:NO];
    
    [flowController viewWillAppear:NO];
    
    
    [[vc0 expect] viewDidAppear:NO];
    [[vc1 expect] viewDidAppear:NO];
    
    [flowController viewDidAppear:NO];
    
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
    id vc0 = [[UIViewController alloc] init];
    id vc1 = [[UIViewController alloc] init];
    
    GQFlowController *flowController = [[GQFlowController alloc] initWithViewControllers:@[vc0, vc1]];
    
    for (UIViewController *vc in flowController.viewControllers) {
        XCTAssertEqualObjects(vc.flowController, flowController, @"flowController控制器访问不了");
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
    
    
    id vc4 = [self mockViewController];
    UIView *aOverlayView = [[UIView alloc] init];
    aOverlayView.backgroundColor = [UIColor redColor];
    [[[vc4 stub] andReturn:aOverlayView] overlayContentView];
    
    [vc4 setOverlayContent:YES];
    
    XCTAssertEqualObjects([[[(UIViewController *)vc4 view] subviews] lastObject], aOverlayView, @"自定义遮罩层无效");
    XCTAssertEqualObjects([[[[(UIViewController *)vc4 view] subviews] lastObject] backgroundColor], [UIColor redColor], @"自定义遮罩层颜色正常");
    
    id vc5 = [self mockViewController];
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
