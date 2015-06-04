//
//  AppDelegate.m
//  NewProject
//
//  Created by xss on 15/5/12.
//  Copyright (c) 2015年 beyond.com All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    ViewController * ctrl = [[ViewController alloc]init];
    self.window.rootViewController =ctrl;
    self.window.backgroundColor = [UIColor purpleColor];
    [self.window makeKeyAndVisible];
    return YES;
}
-(void)applicationDidBecomeActive:(UIApplication *)application
{
    // 发出通知，继续扫描
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notice_reStartScan" object:nil];
}
@end
