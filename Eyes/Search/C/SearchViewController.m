//
//  SearchViewController.m
//  视频搜索
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#define kSearchURL @"http://app.video.baidu.com/app?cuid=9AFFEEFF-08BA-4963-ABA3-B21EE70B862C&time=468226894.984454&ct=905969664&version=6.1.0&md=iphone&ie=utf-8&s=1&word=%@"

#define k_FontSize  (arc4random() % 7) + 20


#import "SearchViewController.h"
#import "SearchView.h"
#import "SearchResultView.h"

#import "NetHandler.h"
#import "Reachability.h"

#import "UIColor+AddColor.h"
#import "VideoModel.h"

#import "webVController.h"
@interface SearchViewController ()<UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) SearchView *searchV;
@property (nonatomic, strong) UIView *keywordV;
@property (nonatomic, strong) SearchResultView *searchResultV;

@property (nonatomic, strong) NSMutableArray *keywordArr;
@property (nonatomic, strong) NSMutableArray *videoArr;

@property (nonatomic, strong) NSArray *colorArr;

@property (nonatomic, strong) NSMutableArray *frameArray;

@property (nonatomic, assign) CGRect f;

@property (nonatomic, assign) NSIndexPath *preIndexPath;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"searchMusic.jpg"]];
    
    
    
    self.searchV = [[SearchView alloc]initWithFrame:(CGRectMake(0, 20, self.view.bounds.size.width, 70))];
    [self.view addSubview:self.searchV];
    [self.searchV.searchB addTarget:self action:@selector(searchvideos:) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *backB = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [backB addTarget:self action:@selector(back:) forControlEvents:(UIControlEventTouchUpInside)];
    backB.frame = CGRectMake(20, 20, 41, 41);
    [backB setImage:[UIImage imageNamed:@"向下返回"] forState:(UIControlStateNormal)];
    [self.searchV addSubview:backB];
    self.searchV.textF.delegate = self;
    
    self.searchResultV = [[SearchResultView alloc]initWithFrame:(CGRectMake(0, self.searchV.frame.origin.y + self.searchV.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.searchV.bounds.size.height - 20))];
    [self.view addSubview:self.searchResultV];
    self.searchResultV.backgroundColor = [UIColor clearColor];
    self.searchResultV.tableV.delegate = self;
    self.keywordV = [[UIView alloc]initWithFrame:self.searchResultV.frame];
    [self.view addSubview:self.keywordV];
    self.keywordV.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(change) name:UITextFieldTextDidChangeNotification object:nil];
    
    self.keywordArr = [NSMutableArray array];
    [self.keywordArr addObject:@"左耳"];
    [self.keywordArr addObject:@"我是证人"];
    [self.keywordArr addObject:@"lol"];
    [self.keywordArr addObject:@"奔跑吧兄弟"];
    [self.keywordArr addObject:@"nba"];
    [self.keywordArr addObject:@"推荐"];
    [self.keywordArr addObject:@"天天向上"];
    

    
    
    
    
    
    //    [self handleHot];
    
}
- (void)handleHot
{
    self.keywordArr = [NSMutableArray array];
    [NetHandler getDataWithUrl:@"http://mobileapi.5sing.kugou.com/song/hottag?limit=20&version=5.7.2" completion:^(NSData *data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSArray *arr = [dic objectForKey:@"data"];
            for (NSDictionary *DIC in arr) {
                NSString *str = [DIC objectForKey:@"Name"];
                [self.keywordArr addObject:str];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        });
    }];
}

- (void)showKeyword
{
    for (int i = 0; i < self.keywordArr.count; i++) {
        UIButton *label = [UIButton buttonWithType:(UIButtonTypeSystem)];
        label.tag = i;
        [label addTarget:self action:@selector(searchHot:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.keywordV addSubview:label];
    }
    self.colorArr = @[[UIColor wisteriaColor],[UIColor blueColor],[UIColor purpleColor],[UIColor redColor],[UIColor grayColor],[UIColor carrotColor],[UIColor silverColor], [UIColor shenhuiseColor],[UIColor qing],[UIColor tiankonglan],[UIColor jinjuse],[UIColor midnightBlueColor],[UIColor cyanColor],[UIColor ngaBackColor]];
    self.frameArray = [[NSMutableArray alloc] initWithObjects:@"{{40, 80}, {120, 30}}",@"{{26, 277}, {120, 30}}",@"{{132, 124}, {120, 30}}",@"{{64, 146}, {120, 30}}",@"{{200, 175}, {120, 30}}",@"{{75, 190}, {120, 30}}",@"{{132, 238}, {120, 30}}",@"{{170, 300}, {120, 30}}",@"{{47, 290}, {120, 30}}", nil];
    
    
    for (UIButton *label in [self.keywordV subviews]) {
        [label setTitle:[self.keywordArr objectAtIndex:0] forState:(UIControlStateNormal)];
        [self.keywordArr removeObjectAtIndex:0];
        [label setTintColor:self.colorArr[arc4random()%[self.colorArr count]]];
        label.titleLabel.font = [UIFont systemFontOfSize:k_FontSize];
        label.titleLabel.numberOfLines = 0;
        label.frame = CGRectZero;
        label.center = self.view.center;
    }
    
    for (UIButton *label in [self.keywordV subviews]) {
        [UIView animateWithDuration:1.8f animations:^{
            label.frame = CGRectFromString(self.frameArray[0]);
            [self.frameArray removeObjectAtIndex:0];
        } completion:nil];
    }
}
- (void)searchHot:(UIButton *)button
{
    self.searchV.textF.text = button.titleLabel.text;
    [self setLoading];
    [self handlevideo];
    
}

- (void)searchvideos:(UIButton *)button
{
    [self setLoading];
    
    [self handlevideo];
}

- (void)handlevideo
{
    [self.view bringSubviewToFront:self.searchResultV];
    [self.searchResultV setHidden:NO];
    [self.keywordV setHidden:YES];
    self.videoArr = [NSMutableArray array];
    NSString *str = [NSString stringWithFormat:kSearchURL, self.searchV.textF.text];
    [NetHandler getDataWithUrl:str completion:^(NSData *data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSDictionary *dic1 = [dic objectForKey:@"nResult"];
            NSArray *arr = [dic1 objectForKey:@"result"];
            for (NSDictionary *DIC in arr) {
                VideoModel *model = [[VideoModel alloc]init];
                [model setValuesForKeysWithDictionary:DIC];
                [self.videoArr addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.searchResultV.arr = self.videoArr;
                [self.pendulum removeFromSuperview];
            });
            if (self.videoArr.count == 0) {
                [self isConnectionAvailable];
                return;
            }
        });
    }];
    
}
- (void)change
{
    if (self.searchV.textF.text.length == 0) {
        [self.view bringSubviewToFront:self.keywordV];
        [self.keywordV setHidden:NO];
        [self.searchResultV setHidden:YES];
        
        for (UIButton *label in [self.keywordV subviews]) {
            [UIView animateWithDuration:2 animations:^{
                self.f = [self changeFrame:self.f];
                label.frame = self.f;
                label.titleLabel.font = [UIFont systemFontOfSize:k_FontSize];
                [label setTintColor:self.colorArr[arc4random()%[self.colorArr count]]];
                
            } completion:nil];
        }
        
    }
    
}
- (CGRect)changeFrame:(CGRect)frame
{
    frame = CGRectMake(arc4random() % 260, arc4random() % 280 + 50, 100, 50);
    return frame;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:self.preIndexPath animated:YES];
    self.preIndexPath = indexPath;
    VideoModel *model = self.videoArr[indexPath.row];
    
    webVController *webVC = [[webVController alloc]init];
    webVC.str = model.videoUrl;
    [self presentViewController:webVC animated:YES completion:nil];
}

- (BOOL)textFieldShouldClear
{
    [self.view bringSubviewToFront:self.keywordV];
    [self.keywordV setHidden:NO];
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)isConnectionAvailable{
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
        {    isExistenceNetwork = YES;
            //            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"5毛 wifi 5毛 wifi" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            //            alert.delegate = self;
            //            [alert show];
            
        }
            
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //NSLog(@"3G");
            break;
    }
    
    if (!isExistenceNetwork) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有网络连接" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        alert.delegate = self;
        [alert show];
        
        return NO;
    }
    
    return isExistenceNetwork;
}

- (void)back:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
