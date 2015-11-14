//
//  BGImageView.m
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "BGImageView.h"
#import "UIImageView+WebCache.h"
#import "UIView+Frame.h"

@interface BGImageView ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;//放大缩小图片

@end

@implementation BGImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        //超出边界隐藏
        self.imageView.clipsToBounds = YES;
        
        [self addSubview:self.imageView];
        self.delegate = self;
        //设置一个放大倍数 最大值和最小值
        self.maximumZoomScale = 2.0;
        self.minimumZoomScale = 0.5;
        
        //因为timer要等待8s时间，所以我们先手动调用一次
        [self zoomScale:nil];
        
        //初始化NSTimer
        self.timer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(zoomScale:) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark 返回指定的缩放视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)zoomScale:(NSTimer *)timer{
    //放大动画
    [UIView animateWithDuration:4 animations:^{
        self.zoomScale = 1.16;
    }];
    //因为我们的动画 做了4秒
    [self performSelector:@selector(small) withObject:timer afterDelay:4];
}

#pragma mark 缩小的动画
- (void)small{
    //缩小动画
    [UIView animateWithDuration:4 animations:^{
        self.zoomScale = 1.0;
    }];
}

#pragma mark 给图片赋值
- (void)setUrl:(NSString *)url{
    _url = url;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url]];
}

@end
