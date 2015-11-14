//
//  PastController.m
//  Eyes
//
//  Created by apple on 15/11/1.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "PastController.h"
#import "TodayController.h"
#import "EyeNavigationController.h"
#import "PastViewCell.h"
#import "PastModel.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface PastController ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

//代理方法是一个拼接的过程，所以我们需要创建一个data把完整的数据拼接起来
@property (strong, nonatomic) NSMutableData *pastData;
@property (strong, nonatomic) NSMutableArray *array;

@end

@implementation PastController

static NSString * const reuseIdentifier = @"Cell";

- (void)loadView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width = (kScreenWidth - 3) / 2;
    layout.itemSize = CGSizeMake(width, width);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 3;
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collection.backgroundColor = [UIColor whiteColor];
    self.collectionView = collection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //做一个强转，使用navigationController的属性
    EyeNavigationController *eyeNaC = (EyeNavigationController *)self.navigationController;
    eyeNaC.leftStyle.text = @"Past";
    
    //隐藏掉rightItem
    self.navigationItem.rightBarButtonItem = nil;
    
    // Register cell classes
    [self.collectionView registerClass:[PastViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    // Do any additional setup after loading the view.
    
    
    //每日精选我们使用了Block。这个页面我们使用一下代理的方法
    NSURL *url = [NSURL URLWithString:@"http://baobab.wandoujia.com/api/v1/categories"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    //初始化data，方便下面的方法做 拼接（如果不在这里初始化，可以做个懒加载）;
    self.pastData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    //拼接数据
    [self.pastData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //数据请求完毕后，对拼接完成的数据做解析
    //因为数据 的根目录是一个数组，所以我们拿一个数组来接收它
    NSArray *array = [NSJSONSerialization JSONObjectWithData:self.pastData options:0 error:nil];
    //一般在forin前面初始化我们的数组。因为我们这里也不会去做上拉加载更多，所以我们用不到懒加载
    self.array = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        PastModel *model = [[PastModel alloc] initWithDictionary:dic];
        [self.array addObject:model];
    }
    //数据刷新，一定要记得写，养成习惯，就像写 ; 一样。
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //返回item个数
    return self.array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PastViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    //API 建议:
    //indexPath.item 用于 collectionView
    //indexPath.row 用于 tableView
    //但是两者是一样的大同小异，使用那个都是一样.
    cell.model = self.array[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PastModel *model = self.array[indexPath.item];
    TodayController *today = [[TodayController alloc] initWithStyle:UITableViewStylePlain];
    today.isDetail = YES;
    //隐藏掉TabBar控制器
    today.hidesBottomBarWhenPushed = YES;
    //拼接往期分类详情所用的url
    /*
     把一个NSString字符串 转换成c语言字符串
     主要用途：写数据库的时候，sql语句是用NSString类型写的时候，要做一个转换
    [model.name UTF8String];
    */
    NSString *name = [model.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"http://baobab.wandoujia.com/api/v1/videos?num=10&categoryName=%@",name];
    today.url = url;
    [self.navigationController pushViewController:today animated:YES];
}

#pragma mark <UICollectionViewDelegate>

@end
