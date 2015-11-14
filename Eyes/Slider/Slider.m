//
//  Slider.m
//  Slider
//
//  Created by apple on 15/10/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "Slider.h"

@interface Slider ()

@property (strong, nonatomic) UIView *cacheView;//缓冲条的view

@end

@implementation Slider
{
    CGFloat _thumbCenterX;//时刻记录thumbCenter的位置
}

- (void)dealloc{
    //移除观察者
    [self.thumb removeObserver:self forKeyPath:@"frame"];
    [self.thumb removeObserver:self forKeyPath:@"center"];
    [self.slider removeObserver:self forKeyPath:@"value"];
    // 代理滞空
    _delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.slider = [[UISlider alloc] initWithFrame:self.bounds];
        //把slider原来的圆点隐藏掉
        [self.slider setThumbImage:[UIImage imageNamed:@"nil"] forState:UIControlStateNormal];
        //给slider添加一个valueChange方法，时刻改变着我们thumb的位置
        [self.slider addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.slider];
        
        //创建缓冲条的view
        self.cacheView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 2) / 2, 0, 2)];
        self.cacheView.backgroundColor = [UIColor whiteColor];
        //关闭交互，防止响应者链断开
        self.cacheView.userInteractionEnabled = NO;
        [self addSubview:self.cacheView];
        
        //先添加观察者，在创建视图，使观察者的移除和创建对上，一一对应。
        
        //添加一个KVO，如果用户改变了frame，我们做出相应的操作，使thumb回到对应的位置
        [self.thumb addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        //监视center的位置，时刻做个记录
        [self.thumb addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
        
        
        
        
        
        //创建滑块view
        self.thumb = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.thumb.center = CGPointMake(0, frame.size.height / 2);
        self.thumb.userInteractionEnabled = NO;
        self.thumb.backgroundColor = [UIColor redColor];
        [self addSubview:self.thumb];
        
        //添加一个手势，根据点击视图位置滑动跳转相应的位置
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        [self addGestureRecognizer:tap];
        
        //监视用户改变value的值发生改变
        [self.slider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return self;
}

#pragma mark KVO执行的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"center"]) {
        _thumbCenterX = self.thumb.center.x;
    }
    if ([keyPath isEqualToString:@"frame"]) {
        self.thumb.center = CGPointMake(_thumbCenterX, self.frame.size.height /2);
    }
    if ([keyPath isEqualToString:@"value"]) {
        [self valueChange:self.slider];
    }
}
#pragma mark slider滑动过程中
- (void)valueChange:(UISlider *)slider{
    //修改thumb的位置
    //求出当前slider所在位置的百分比
    CGFloat progress = slider.value / (slider.maximumValue - slider.minimumValue);
    CGFloat thumbX = progress * self.frame.size.width;
    self.thumb.center = CGPointMake(thumbX, self.frame.size.height / 2);
}

#pragma mark tap手势执行的方法
- (void)tapView:(UITapGestureRecognizer *)tap{
    //拿到点击的那一个点
    CGPoint point = [tap locationInView:self];
    //做一个判断，如果点出去，让它在最边缘
    CGFloat x = point.x;
    if (x < 0) {
        x = 0;
    }
    if (x > self.frame.size.width) {
        x = self.frame.size.width;
    }
    //修改thumb的位置和slider的value
    self.thumb.center = CGPointMake(x, self.frame.size.height / 2);
    CGFloat progress = x / self.frame.size.width;
    self.slider.value = (self.slider.maximumValue - self.slider.minimumValue) * progress;
    // 传递参数
    if ([_delegate respondsToSelector:@selector(touchView:)]) {
        [_delegate touchView:self.slider.value];
    }
}

#pragma mark 重写color的Set方法，改变cache的颜色
- (void)setCacheColor:(UIColor *)cacheColor{
    _cacheColor = cacheColor;
    self.cacheView.backgroundColor = cacheColor;
}

#pragma mark 缓冲条的数据
- (void)setCache:(CGFloat)cache{
    //做一个判断，判断用户给的值是否超出了范围
    if (cache < self.slider.minimumValue) {
        cache = self.slider.minimumValue;
    }else if (cache > self.slider.maximumValue){
        cache = self.slider.maximumValue;
    }
    _cache = cache;
    //求出cache所在视图的位置
    CGFloat progress = cache / (self.slider.maximumValue - self.slider.minimumValue);
    CGFloat cacheWidth = progress * self.frame.size.width;
    //赋值
    self.cacheView.frame = CGRectMake(0, self.frame.size.height / 2 - 1, cacheWidth, 2);
}

#pragma mark 重写set方法,重新赋值滑块
- (void)setThumb:(UIView *)thumb{
    //把原视图移除掉
    
    //移除视图前，先把观察者移除掉
    [self.thumb removeObserver:self forKeyPath:@"frame"];
    [self.thumb removeObserver:self forKeyPath:@"center"];
    
    [_thumb removeFromSuperview];
    _thumb = thumb;
    [self addSubview:_thumb];
    
    //视图添加完成之后，重新添加观察者
    
    //添加一个KVO，如果用户改变了frame，我们做出相应的操作，使thumb回到对应的位置
    [self.thumb addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    //监视center的位置，时刻做个记录
    [self.thumb addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.slider.frame = self.bounds;
}

@end
