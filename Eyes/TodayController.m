//
//  TodayController.m
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "TodayController.h"
#import "DetailController.h"
#import "EyeNavigationController.h"
#import "UILabel+Detail.h"
#import "TodayViewCell.h"
#import "TodayModel.h"
#import "HeaderView.h"
#import "MJRefresh.h"
#import "NetHandler.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface TodayController ()

@property (strong, nonatomic) EyeNavigationController *eyeNaC;
//上提加载更多的借口
@property (strong, nonatomic) NSString *nextPageUrl;
//存储model的数组
@property (strong, nonatomic) NSMutableArray *array;

@end

@implementation TodayController

static NSString *today = @"today";
static NSString *heaer = @"header";


//数据懒加载，上提加载更多需要用到
//(懒加载的使用场景：当我不知道什么时候创建的时候，使用懒加载)
- (NSMutableArray *)array{
    if (!_array) {
        self.array = [NSMutableArray array];
    }
    return _array;
}
-(void)dismiss:(UIAlertController *)alertC
{
    [alertC dismissViewControllerAnimated:YES completion:nil];
}

- (void)setLoading
{
    UIColor *ballColor = [UIColor colorWithRed:0.47 green:0.60 blue:0.89 alpha:1];
    self.pendulum = [[PendulumView alloc] initWithFrame:self.view.bounds ballColor:ballColor];
    [self.view addSubview:self.pendulum];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = NO;
    
    //对EyeNavigationController做一个强转。是我们能够使用自己定义的属性
    self.eyeNaC = (EyeNavigationController *)self.navigationController;
    self.eyeNaC.leftStyle.text = @"Today";
    [self.eyeNaC.book addTarget:self action:@selector(push:) forControlEvents:UIControlEventTouchUpInside];

    //注册cell
    [self.tableView registerClass:[TodayViewCell class] forCellReuseIdentifier:today];
    //注册Header
    [self.tableView registerClass:[HeaderView class] forHeaderFooterViewReuseIdentifier:heaer];
    //设置Row的高度.
    self.tableView.rowHeight = (int)(kScreenWidth / 1242 * 777);
    
    
    self.tableView.delegate = self;
    //网络请求
    //动态获取当天时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //给他一个格式
    formatter.dateFormat = @"yyyyMMdd";
    formatter.timeZone = [NSTimeZone systemTimeZone];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://baobab.wandoujia.com/api/v1/feed?date=%@&num=10",date];
    //做个判断 区别 是否是 每日精选 和 往期分类的详情
    //第一种判断方法    //如果是往期分类跳转进来的话
    if (self.isDetail) {
        urlStr = self.url;
        
        //更改leftItem样式和执行的方法 ，让它可以POP
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 25, 25);
        [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        //更改leftItem文字的现实
        self.eyeNaC.leftStyle.text = @"Past";
    }
    //第二种判断方法
//    if (self.url) {
//        urlStr = self.url;
//    }
    
    
    [self setLoading];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"网络错误" preferredStyle:(UIAlertControllerStyleAlert)];
        
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertC addAction:cancelAction];
            [self presentViewController:alertC animated:YES completion:nil];
            [self performSelector:@selector(dismiss:) withObject:alertC afterDelay:0.8f];
            
        }else{
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.nextPageUrl = dic[@"nextPageUrl"];
            
            //做一个判断，每日精选，和往期分类详情解析方式不一样
            if (self.isDetail) {
                //往期分类详情解析
                NSMutableArray *subArray = [NSMutableArray array];
                for (NSDictionary *videoList in dic[@"videoList"]) {
                    TodayModel *model = [[TodayModel alloc] init];
                    [model setValuesForKeysWithDictionary:videoList];
                    [subArray addObject:model];
                }
                [self.array addObject:subArray];
                [self.tableView reloadData];

            }else{
            //解析字典里  dailyList 数组的数据
            //如果没有懒加载 我们在第一层 for in的地方初始化我们的数组
            for (NSDictionary *dailyList in dic[@"dailyList"]) {
                //解析字典里面   videoList数组的数据
                //创建一个数组，用来保存我们每个分区里面的model。
                NSMutableArray *subArray = [NSMutableArray array];
                for (NSDictionary *videoList in dailyList[@"videoList"]) {
                    TodayModel *model = [[TodayModel alloc] init];
                    [model setValuesForKeysWithDictionary:videoList];
                    [subArray addObject:model];
                }
                //把每个分区的array 存到外层array里面;
                [self.array addObject:subArray];
                [self.tableView reloadData];
            }

            }

        }
        [self.pendulum removeFromSuperview];
    }];

    [self setupRefresh];

    
}
- (void)setupRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.header endRefreshing];
        });
    }];
    
    [self.tableView.header beginRefreshing];
    
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
}
- (void)loadNewData
{
    if (!self.isDetail) {
        [NetHandler getDataWithUrl:self.nextPageUrl completion:^(NSData *data) {
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                self.nextPageUrl = dic[@"nextPageUrl"];
                
                
                //做一个判断，每日精选，和往期分类详情解析方式不一样
                if (self.isDetail) {
                    //往期分类详情解析
                    NSMutableArray *subArray = [NSMutableArray array];
                    for (NSDictionary *videoList in dic[@"videoList"]) {
                        TodayModel *model = [[TodayModel alloc] init];
                        [model setValuesForKeysWithDictionary:videoList];
                        [subArray addObject:model];
                    }
                    [self.array addObject:subArray];
                    [self.tableView.footer endRefreshing];
                    
                }else{
                    //解析字典里  dailyList 数组的数据
                    //如果没有懒加载 我们在第一层 for in的地方初始化我们的数组
                    for (NSDictionary *dailyList in dic[@"dailyList"]) {
                        //解析字典里面   videoList数组的数据
                        //创建一个数组，用来保存我们每个分区里面的model。
                        NSMutableArray *subArray = [NSMutableArray array];
                        for (NSDictionary *videoList in dailyList[@"videoList"]) {
                            TodayModel *model = [[TodayModel alloc] init];
                            [model setValuesForKeysWithDictionary:videoList];
                            [subArray addObject:model];
                        }
                        //把每个分区的array 存到外层array里面;
                        [self.array addObject:subArray];
                        [self.tableView.footer endRefreshing];
                        
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.tableView.footer endRefreshing];
                });
            });
        }];
    }else{
        [self.tableView.footer endRefreshing];

    }
    
    
}

//添加每个cell出现时的动画(从左边出现)
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CATransform3D rotation;//3D旋转
    rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
    //逆时针旋转
    rotation.m34 = 1.0/ -600;
    
    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
    cell.contentView.layer.shadowOffset = CGSizeMake(0, 0);
    cell.alpha = 0;
    
    cell.layer.transform = rotation;
    //旋转定点
    cell.layer.anchorPoint = CGPointMake(0, 0.5);
    
    [UIView beginAnimations:@"rotation" context:NULL];
    //旋转时间
    [UIView setAnimationDuration:0.8];
    cell.layer.transform = CATransform3DIdentity;
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
}



#pragma mark 点击RightItem跳转详情
- (void)push:(UIButton *)book{
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:index];
}

#pragma mark 点击leftItem POP父视图
- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.array[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TodayViewCell *cell = [tableView dequeueReusableCellWithIdentifier:today forIndexPath:indexPath];
    cell.model = self.array[indexPath.section][indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.isDetail) {
        return 0;
    }
    if (section) {
        return 30;
    }else{
        return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    HeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:heaer];
    //因为每个分区里面的model的date是一样的，我们这边只取第一个就可以了
    TodayModel *model = self.array[section][0];
    
    //因为系统自带的leble有时候属性会自己修改回来，我们用自己创建的label
    if (section) {
        [headerView.label dateStrWithdate:model.date / 1000];
    }else{
        //防止重用以前有label显示的问题
        headerView.label.text = @"";
    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.array.count != 0) {
        DetailController *detail = [[DetailController alloc] init];
        detail.hidesBottomBarWhenPushed = YES;
        detail.model = self.array[indexPath.section][indexPath.row];
        [self.navigationController pushViewController:detail animated:YES];
    }

}


@end
