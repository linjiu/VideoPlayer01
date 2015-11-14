//
//  EyeTabBarController.m
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "EyeTabBarController.h"
#import "EyeNavigationController.h"
#import "TodayController.h"
#import "PastController.h"

@interface EyeTabBarController ()

@end

@implementation EyeTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建每日精选 子控制器
    EyeNavigationController *today = [[EyeNavigationController alloc] initWithRootViewController:[[TodayController alloc] initWithStyle:UITableViewStyleGrouped]];
    today.title = @"每日精选";
    today.tabBarItem.image=[[UIImage imageNamed:@"每日"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self addChildViewController:today];
    
    //创建 往期分类 控制器
    EyeNavigationController *past = [[EyeNavigationController alloc] initWithRootViewController:[[PastController alloc] init]];
    past.title = @"往期分类";
    past.tabBarItem.image=[[UIImage imageNamed:@"分类"] imageWithRenderingMode:UIImageRenderingModeAutomatic];

    [self addChildViewController:past];
}

@end
