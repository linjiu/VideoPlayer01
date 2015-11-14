//
//  DetailController.m
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "DetailController.h"
#import "MoviePlayerController.h"
#import "EyeNavigationController.h"
#import "AppDelegate.h"
#import "DetailView.h"

@interface DetailController ()<DetailViewDelegate>

@end

@implementation DetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EyeNavigationController *eyeNaC = (EyeNavigationController *)self.navigationController;
    eyeNaC.book.selected = YES;
    
    [eyeNaC.book addTarget:self action:@selector(pop:) forControlEvents:UIControlEventTouchUpInside];
    
    DetailView *detail =  [[DetailView alloc] initWithFrame:self.view.bounds];

    detail.model = self.model;
    detail.delegate = self;
    [self.view addSubview:detail];

}

- (void)pop:(UIButton *)book{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 代理方法，点击播放 进行视图跳转
- (void)playMovie:(TodayModel *)model{
    MoviePlayerController *playVC = [[MoviePlayerController alloc] init];
    //使用传过来的model，里面做过修改
    playVC.model = model;
    //拿到appDelegate
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    //设置属性，仅支持横屏切换
    appdelegate.isRotation = YES;
    //在跳转以前，给appdelegate的属性赋值
    [self presentViewController:playVC animated:YES completion:nil];
}

@end
