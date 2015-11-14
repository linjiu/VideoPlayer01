 //
//  DetailView.m
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "DetailView.h"
#import "UIImageView+WebCache.h"
#import "BGImageView.h"
#import "DIYButton.h"
#import "UIView+Frame.h"
#import "UILabel+Detail.h"
#import "TotalDownloader.h"
#import "DB.h"


#define kDetailX 20

@interface DetailView ()

@property (strong, nonatomic) BGImageView *bgImage;//背景图片
@property (strong, nonatomic) UIImageView *detailImage;//详情图片
@property (strong, nonatomic) UILabel *title;//详情的标题
@property (strong, nonatomic) UILabel *category;//详情分类
@property (strong, nonatomic) DIYButton *collectionBtn;//收藏button
@property (strong, nonatomic) DIYButton *shareBtn;//分享的button
@property (strong, nonatomic) DIYButton *downloadBtn;//下载的button

@end

@implementation DetailView

- (void)dealloc{
    //去除NSTimer 使bgImage视图可以销毁;
    [self.bgImage.timer invalidate];
    //代理滞空
    _delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      //自己的高度 = kScreenHeight / 图宽 * 图高;
      //自己的宽度 = kScreenHeight / 图高 * 图宽;
        
        self.clipsToBounds = YES;
        
        CGFloat height = frame.size.height * 0.7;
        CGFloat width = height / 777 * 1242;
        //求出x的位置
        CGFloat x = -(width - frame.size.width) / 2;
        self.bgImage = [[BGImageView alloc] initWithFrame:CGRectMake(x, 0, width, height)];
        //添加一个轻拍手势，触发代理方法，实现页面跳转
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playMovie)];
        //因为我们将bgImage的用户交互关闭了，所以我们要建立一个视图，来响应我们的轻拍手势
        //响应轻拍手势的视图
        UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, height)];
        [tapView addGestureRecognizer:tap];
        [self addSubview:tapView];
        
        
        
        //因为scrollView放大后可以拖动，我们关闭用户操作，不让它可以拖动
        self.bgImage.userInteractionEnabled = NO;
        [self addSubview:self.bgImage];
        
        //求x坐标和y坐标
        //创建play imageView
        CGFloat playX = (frame.size.width - 60) / 2;
        CGFloat playY = (height - 60) / 2 + 20;
        UIImageView *playImageView = [[UIImageView alloc] initWithFrame:CGRectMake(playX, playY, 60, 60)];
        playImageView.image = [UIImage imageNamed:@"play"];
        [self addSubview:playImageView];
        
        //创建详情背景视图
        self.detailImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, height, frame.size.width, frame.size.height - height)];
        [self addSubview:self.detailImage];
        //创建title View
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(kDetailX, 0, frame.size.width, 40)];
        self.title.textColor = [UIColor whiteColor];
        self.title.font = [UIFont boldSystemFontOfSize:16];
        [self.detailImage addSubview:self.title];
        
        
        //创建详情分类
        self.category = [[UILabel alloc] initWithFrame:CGRectMake(0, self.title.frame.size.height, frame.size.width, 30)];
        self.category.textColor = [UIColor whiteColor];
        self.category.font = [UIFont systemFontOfSize:14];
        [self.title addSubview:self.category];
        
        //创建简介视图
        self.info = [[ZTypewriteEffectLabel alloc] initWithFrame:CGRectMake(0, self.category.frame.size.height, frame.size.width - kDetailX * 2, 0)];
        self.info.font = [UIFont systemFontOfSize:13];
        self.info.textColor = [UIColor whiteColor];
        //self.info.typewriteEffectColor = [UIColor whiteColor];
        //self.info.typewriteTimeInterval = 0.01;
        self.info.numberOfLines = 0;
        [self.category addSubview:self.info];
       // [self.info startTypewrite];


        //创建收藏的button
/*
        CGFloat buttonY = self.detailImage.height - 40;
        CGFloat detailImageW = self.detailImage.width;
        CGFloat buttonWidth = (detailImageW - kDetailX * 2) / 4;
        CGFloat buttonHeight = 20;

        self.collectionBtn = [DIYButton buttonWithType:UIButtonTypeCustom];
        self.collectionBtn.frame = CGRectMake(kDetailX, buttonY, buttonWidth, buttonHeight);
        self.collectionBtn.icon.image = [UIImage imageNamed:@"collect"];
        self.collectionBtn.iconSelected.image = [UIImage imageNamed:@"bookmarked"];
        self.collectionBtn.textLabel.text = @"  收藏";
        [self.collectionBtn addTarget:self action:@selector(collection:) forControlEvents:UIControlEventTouchUpInside];
        [self.detailImage addSubview:self.collectionBtn];

        //创建分享的button
        self.shareBtn = [DIYButton buttonWithType:UIButtonTypeCustom];
        self.shareBtn.frame = CGRectMake(kDetailX + buttonWidth, buttonY, buttonWidth, buttonHeight);
        self.shareBtn.icon.image = [UIImage imageNamed:@"share"];
        self.shareBtn.textLabel.text = @"  分享";
        [self.shareBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        [self.detailImage addSubview:self.shareBtn];

        //创建下载的button
        self.downloadBtn = [DIYButton buttonWithType:UIButtonTypeCustom];
        self.downloadBtn.frame = CGRectMake(kDetailX + buttonWidth * 2, buttonY, buttonWidth, buttonHeight);
        self.downloadBtn.icon.image = [UIImage imageNamed:@"download"];
        self.downloadBtn.iconSelected.image = [UIImage imageNamed:@"downloadCompleted"];
        self.downloadBtn.textLabel.text = @"  下载";
        [self.downloadBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
        [self.detailImage addSubview:self.downloadBtn];
*/
        self.detailImage.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark 收藏的方法
- (void)collection:(DIYButton *)button{
    button.selected = !button.selected;
}

#pragma mark 分享的方法
- (void)share:(DIYButton *)button{
}

#pragma mark 下载的方法
- (void)download:(DIYButton *)button{
    //第一次下载添加到下载中数据表
    [DB insertDownloading:self.model];
    
    // 避免用户误操作。
    button.userInteractionEnabled = NO;
    //获取下载器的单例
    TotalDownloader *total = [TotalDownloader shareTotalDownloader];
    //创建一下下载
    Download *download = [total addDownloadingWithURL:self.model.playUrl];
    //手动开始
    [download start];
    //下载的状态
    [self downloadingWithDownload:download button:button];
}

#pragma mark 轻拍手势执行的方法
- (void)playMovie{
    //给代理赋值,执行相应的代理方法
    if ([_delegate respondsToSelector:@selector(playMovie:)]) {
        [_delegate playMovie:self.model];
    }
}

#pragma mark 给视图赋值
- (void)setModel:(TodayModel *)model{
    //先查找数据库中是否有已经下载完成的数据
    TodayModel *todayModel = [DB findDownloadComplated:model.playUrl];
    if (todayModel) {//如果today存在
        model = nil;//原来的滞空
        model = todayModel;//把数据库中的model赋值给我们的model
        //改变button的状态
        self.downloadBtn.selected = YES;//更换button的图片
        self.downloadBtn.textLabel.text = @"  已缓存";//更换button的文字
        self.downloadBtn.userInteractionEnabled = NO;//关闭用户交互.
    }
    
    // 如果有下载。我们显示下载状态
    TotalDownloader *total = [TotalDownloader shareTotalDownloader];
    Download *download = [total findDownloadingWithURL:model.playUrl];
    if (download) {
        //如果已经存在下载。button不让用户操作
        self.downloadBtn.userInteractionEnabled = NO;
        //如果已经存在下载。但是网络很卡，(下载中的)一次的赋值都没有走
        //我们做一个第一次赋值
        self.downloadBtn.textLabel.text = [NSString stringWithFormat:@"  %d%%",(int)download.progress];
        [self downloadingWithDownload:download button:self.downloadBtn];
    }
    
    _model = model;
    //给详情图片赋值
    self.bgImage.url = _model.coverForDetail;
    
    //给背景图片赋值
    [self.detailImage sd_setImageWithURL:[NSURL URLWithString:_model.coverBlurred]];
    
    //给标题赋值
    self.title.text = _model.title;
    
    //创建标题下边的白色线条
//    CGFloat lineWidth = [self stringHeightForFont:self.title.font string:model.title].width - 60;
    CGFloat lineWidth = [self stringHeightForFont:self.title.font string:_model.title].width * 0.7;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.title.height - 1, lineWidth, 1)];
    line.backgroundColor = [UIColor whiteColor];
    [self.title addSubview:line];
    
    //给类型赋值 我们之前写过的分类，现在用到了
    [self.category detailWithStyle:_model.category time:_model.duration];
    
    //给简介赋值
    self.info.text = _model.myDescription;
    //根据字符串求高度
    CGFloat infoHeight = [self stringHeightForFont:self.info.font string:_model.myDescription].height;
    self.info.height = infoHeight;
    

}

#pragma mark 根据字符串求高度的方法
- (CGSize)stringHeightForFont:(UIFont *)font string:(NSString *)string{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(self.width - kDetailX * 2, 1000)
                                options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:font}
                                context:nil];
    return rect.size;
}

#pragma mark 当前下载的状态
- (void)downloadingWithDownload:(Download *)download button:(DIYButton *)button{
    [download didFinishDownload:^(NSString *savePath, NSString *url) {
        button.selected = YES;
        button.textLabel.text = @"  已缓存";
        self.model.save = savePath;
        //存入数据库
        [DB insertDownloadComplated:self.model];
    } downloading:^(long long bytesWritten, NSInteger progress) {
        button.textLabel.text = [NSString stringWithFormat:@"  %ld%%",progress];
    }];
}

@end








