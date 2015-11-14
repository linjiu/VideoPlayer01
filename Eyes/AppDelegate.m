//
//  AppDelegate.m
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//


#import "AppDelegate.h"
#import "EyeNavigationController.h"
#import "EyeTabBarController.h"
#import "TotalDownloader.h"
#import "TodayModel.h"
#import "DB.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //创建一个Window，frame全屏显示
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //设置白色背景  防止以后视图出现问题
    self.window.backgroundColor = [UIColor whiteColor];
    
    //设置tabbar控制器作为子视图
    self.window.rootViewController = [[EyeTabBarController alloc] init];
    
    
    NSArray *array = [DB allDownloading];
    //下载器单例类
    TotalDownloader *total = [TotalDownloader shareTotalDownloader];
    for (TodayModel *model in array) {
        //程序进入的时候，单例里面添加下载
        //这里添加的下载是数据库的正在下载，是没有下载完成的。
        //把它们添加到单例里面
        [total addDownloadingWithURL:model.playUrl];
    }
    
    //显示Window
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark 支持横竖屏切换的方法
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if (_isRotation) {
        //如果是YES，只支持横屏
        return UIInterfaceOrientationMaskLandscape;
    }
    //只支持竖屏
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //在这里暂停我们的下载  进行一个数据保存
    NSArray *array = [[TotalDownloader shareTotalDownloader] allDownloading];
    for (Download *download in array) {
        //暂停所有的下载。进行数据保存
        [download suspend];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
