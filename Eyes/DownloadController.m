//
//  DownloadController.m
//  Eyes
//
//  Created by apple on 15/10/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "DownloadController.h"
#import "TotalDownloaderController.h"



//下载不可做
@interface DownloadController ()

@end

@implementation DownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(100, 100, 100, 100);
    [button setTitle:@"我的缓存" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)download{
    TotalDownloaderController *total = [[TotalDownloaderController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:total animated:YES];
}

@end
