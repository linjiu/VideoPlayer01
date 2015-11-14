//
//  TotalDownloaderController.m
//  Eyes
//
//  Created by apple on 15/10/29.
//  Copyright © 2015年 apple. All rights reserved.
//


#import "TotalDownloaderController.h"
#import "DownloadCell.h"
#import "DetailController.h"
#import "Define.h"
#import "DB.h"

@interface TotalDownloaderController ()<UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *totalArray;//总数组，存储正在下载和下载完成
@property (strong, nonatomic) NSMutableArray *downloadingArray;//正在下载的数组
@property (strong, nonatomic) NSMutableArray *downloadComplatedArray;//下载完成的数组


@end

@implementation TotalDownloaderController

static NSString *download = @"download";
static NSString *header = @"header";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //注册cell和header
    [self.tableView registerClass:[DownloadCell class] forCellReuseIdentifier:download];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:header];
    
    self.tableView.rowHeight = (int)(kScreenWidth / 1242 * 777);
    
    //数组赋值
    
    self.downloadingArray = (NSMutableArray *)[DB allDownloading];
    self.downloadComplatedArray = (NSMutableArray *)[DB allDownloadComplated];
    self.totalArray = [NSMutableArray arrayWithObjects:self.downloadingArray, self.downloadComplatedArray, nil];
    
    //隐藏设置按钮，让下载页面可以返回
    self.navigationItem.leftBarButtonItems = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.totalArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.totalArray[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:download forIndexPath:indexPath];
    cell.model = self.totalArray[indexPath.section][indexPath.row];
    cell.indexPath = indexPath;
    [cell downloadComplated:^(NSIndexPath *indePath) {
        TodayModel *model = self.downloadingArray[indexPath.row];
        //先插入一条数据。在删除
        [self.downloadComplatedArray insertObject:model atIndex:0];
        //删除
        [self.downloadingArray removeObject:model];
        //刷新
        [self.tableView reloadData];
    } delete:^(NSIndexPath *indexPath) {
        //做一个提示框
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 1000 + indexPath.row;
        [alert show];
    }];
    return cell;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (1 == buttonIndex) {
        //删除
        TodayModel *model = self.downloadComplatedArray[alertView.tag - 1000];
        [DB deleteDownloadComplated:model.playUrl];
        [self.downloadComplatedArray removeObject:model];
        [self.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    headerView.textLabel.textAlignment = NSTextAlignmentCenter;
    headerView.textLabel.font = [UIFont boldSystemFontOfSize:18];
    if (section == 0) {
        headerView.textLabel.text = @"正在下载";
    }else{
        headerView.textLabel.text = @"下载完成";
    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailController *detail = [[DetailController alloc] init];
    detail.model = self.totalArray[indexPath.section][indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];
}

@end
