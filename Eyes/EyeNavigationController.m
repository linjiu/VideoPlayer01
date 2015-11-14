//
//  EyeNavigationController.m
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//


#import "EyeNavigationController.h"
#import "DownloadController.h"
#import "SearchViewController.h"

@interface EyeNavigationController ()

@end

@implementation EyeNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UILabel *)leftStyle{
    if (!_leftStyle) {
        self.leftStyle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    }
    return _leftStyle;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    //创建设置按钮
    self.set = [UIButton buttonWithType:UIButtonTypeCustom];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.set];
    self.set.frame = CGRectMake(0, 0, 25, 25);
    [self.set setImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
    //做一个判断，如果是DownloadControlle，添加pop方法
    if ([[viewController class] isEqual:[DownloadController class]]) {
        [self.set addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [self.set addTarget:self action:@selector(push:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //左边文字Item
    UIBarButtonItem *labelItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftStyle];
    
    //左边的文字显示
    self.leftStyle.textAlignment = NSTextAlignmentLeft;
//    NSArray *array = [UIFont familyNames];
//    NSLog(@"%@",array);
    self.leftStyle.font = [UIFont systemFontOfSize:17];

    
    viewController.navigationItem.leftBarButtonItems = @[leftItem,labelItem];
    
    //title文字显示
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:@"Zapfino" size:17];
    self.titleLabel.text = @"Best Video";
    viewController.navigationItem.titleView = self.titleLabel;
    
    //创建右边item
    self.book = [UIButton buttonWithType:UIButtonTypeCustom];
    self.book.frame = CGRectMake(0, 0, 25, 25);
    [self.book setImage:[UIImage imageNamed:@"shut"] forState:UIControlStateNormal];
    [self.book setImage:[UIImage imageNamed:@"look"] forState:UIControlStateSelected];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.book];
    viewController.navigationItem.rightBarButtonItem = rightItem;
    
    //使一个图片不做任何渲染  保证原来的状态
    //[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    [super pushViewController:viewController animated:animated];
}

- (void)push:(UIButton *)button{
//    DownloadController *download = [[DownloadController alloc] init];
//    download.hidesBottomBarWhenPushed = YES;
//    [self pushViewController:download animated:YES];
    
    
    SearchViewController *searchVC = [[SearchViewController alloc]init];
    [self presentViewController:searchVC animated:YES completion:^{
        [searchVC showKeyword];
    }];
}

- (void)pop{
    [self popViewControllerAnimated:YES];
}

@end
