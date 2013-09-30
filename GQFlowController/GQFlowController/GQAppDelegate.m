//
//  GQAppDelegate.m
//  GQFlowController
//
//  Created by 钱国强 on 13-3-24.
//  Copyright (c) 2013年 Qian GuoQiang. All rights reserved.
//

#import "GQAppDelegate.h"
#import "Demo1TopViewController.h"
#import "Demo1LeftViewController.h"
#import "Demo1RightViewController.h"
#import "Demo2ViewController.h"
#import "Demo3ViewController.h"

@implementation GQAppDelegate

- (NSArray *)demo1ViewControllers
{
    Demo1TopViewController *d1 = [[Demo1TopViewController alloc] init];
    Demo1LeftViewController *d2 = [[Demo1LeftViewController alloc] init];
    Demo1RightViewController *d3 = [[Demo1RightViewController alloc] init];
    
    return @[d3, d2, d1];
}

- (NSArray *)demo2ViewControllers
{
    Demo2ViewController *d1 = [[Demo2ViewController alloc] init];
    
    return @[d1];
}

- (NSArray *)demo3ViewControllers
{
    Demo3ViewController *d1 = [[Demo3ViewController alloc] init];
    
    return @[d1];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.flowController = [[GQFlowController alloc] initWithViewControllers:[self demo1ViewControllers]];
    } else {
        self.flowController = [[GQFlowController alloc] initWithViewControllers:[self demo3ViewControllers]];
    }
    
    self.window.rootViewController = self.flowController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
