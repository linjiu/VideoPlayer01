//
//  MoviePlayer.m
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "MoviePlayer.h"
#import "DIYButton.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+Frame.h"
#import "UILabel+Detail.h"
#import "Slider.h"

//首字母k 使用的是驼峰法  如果不是的话是全部大写
#define kPlayWidth 50
#define kProgressHeight 50
#define kTimeLabelWidth 60

@interface MoviePlayer ()<SliderDelegate>

@property (strong, nonatomic) MPMoviePlayerController *moviePlay;//视频播放视图
@property (strong, nonatomic) UIView *bgView;//背景View;
@property (strong, nonatomic) DIYButton *backBtn;//返回按钮
@property (strong, nonatomic) UIButton *play;//播放/暂停
@property (strong, nonatomic) Slider *progress;//进度条
@property (strong, nonatomic) UISlider *volume;//声音
@property (strong, nonatomic) UILabel *begin;//开始的Label
@property (strong, nonatomic) UILabel *end;//结束的Label
@property (strong, nonatomic) UIView *downView;//下方控制视图
@property (strong, nonatomic) NSTimer *timer;//定时器，时刻获取播放状态
@property (strong, nonatomic) UILabel *timeLabel;//滑块上边的时间显示
@property (strong, nonatomic) UILabel *fastLabel;//快进的label。
@property (strong, nonatomic) UISlider *volumeController;//接收系统音量控制的slider。

@end

@implementation MoviePlayer
{
    BOOL isTop;//上次一用户操作的状态，是否在点击
    PanDirection panDirection;//判断哪个方向的枚举值
    float topValue;//水平移动上一次的数值
}
- (void)dealloc{
    _delegate = nil;
}

//url类型是NSURL 主要是以后会做本地沙盒文件播放，这样就可以通用了。
- (instancetype)initWithFrame:(CGRect)frame URL:(NSURL *)url{
    self = [super initWithFrame:frame];
    if (self) {
        //创建视频播放视图
        [self createMoviePlayer:url];
        
        //创建背景视图
        [self createBgView];
        
        //创建快进的label
        self.fastLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height / 4 * 3, frame.size.width, 40)];
        //居中显示
        self.fastLabel.textAlignment = NSTextAlignmentCenter;
        self.fastLabel.textColor = [UIColor whiteColor];
        [self.bgView addSubview:self.fastLabel];
        
        //创建声音控件
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, -100, 1, 1)];//移动到可视范围之外。因为我们隐藏了。系统并没有替换成功。还是显示原来的加声音的控件
        for (UIView *view in volumeView.subviews) {
            if ([view isKindOfClass:[UISlider class]]) {//找到系统音量的slider,拿我们自己创建的去接收它
                self.volumeController = (UISlider *)view;
            }
        }
        [self.bgView addSubview:volumeView];
        
        //接收视频加载好的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(durationAvailable:) name:MPMovieDurationAvailableNotification object:self.moviePlay];
    }
    return self;
}

#pragma mark 视频加载好后的通知
- (void)durationAvailable:(NSNotification *)notification{
    //隐藏button
    self.backBtn.hidden = YES;
    
    //对视频总时长赋值
    [self.end timeStrWithTime:self.moviePlay.duration];
    
    self.progress.slider.maximumValue = self.moviePlay.duration;
    
    //添加轻拍手势
    //使视图出现或者消失
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    [self.bgView addGestureRecognizer:tap];
    
    
    //添加平移手势，控制音量和进度
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self.bgView addGestureRecognizer:pan];
    
    //添加定时器，查看播放的状态
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moviePlayer:) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMovieDurationAvailableNotification object:nil];
}

#pragma mark 视频播放状态的方法
- (void)moviePlayer:(NSTimer *)timer{
    if (!self.progress.slider.highlighted){//当我滑动视图的时候，不更新slider的value值, 让滑块滑动更流畅
        //怎么让下面这行代码之执行一次。timer会一直执行
        if (isTop != self.progress.slider.highlighted) {
            //做一个判断，本次用户手指离开，上一次的状态，是没有离开的状态
            [self valueChangeEnd];
        }else{
            self.progress.slider.value = self.moviePlay.currentPlaybackTime;
        }
    }
    //赋值缓存的状态
    self.progress.cache = self.moviePlay.playableDuration;
    
    //给当前播放视频的页面赋值
    [self.begin timeStrWithTime:self.moviePlay.currentPlaybackTime];
//    NSLog(@"%f",self.moviePlay.currentPlaybackTime);
    //给isTop属性赋值。拿到上一次的用户操作状态
    isTop = self.progress.slider.highlighted;
}

#pragma mark 平移手势执行的方法
- (void)panGesture:(UIPanGestureRecognizer *)gesture{
    //根据上次手指的位置获取的偏移量
    CGPoint point = [gesture velocityInView:self.bgView];
    
    //判断手势的状态
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{//开始
            //在began中判断是哪个方向的手势
            //求出x和y的绝对值。用于判断是哪个方向的平移
            float x = fabs(point.x);
            float y = fabs(point.y);
            if (x > y) {
                //水平方向
                panDirection = PanDirectionHorizontalMoved;
                //给上次的value赋上一个初始值
                topValue = self.moviePlay.currentPlaybackTime;
            }else if (x < y){
                //垂直方向
                panDirection = PanDirectionVerticalMoved;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{//移动
            switch (panDirection) {
                case PanDirectionHorizontalMoved:{//水平方向
                    [self horizontalMoved:point.x];
                    break;
                }
                default:{//垂直方向
                    [self verticalMoved:point.y];
                    break;
                }
            }
            break;
        }
        default:{//结束
            if (panDirection == PanDirectionHorizontalMoved) {//水平的结束
                //结束的时候，做一个视频跳转
                self.moviePlay.currentPlaybackTime = topValue;
                //结束的时候，label文字滞空.
                self.fastLabel.text = @"";
                topValue = 0;
            }else{
                // 隐藏声音控制视图
                self.volume.hidden = YES;
            }
            break;
        }
    }
}

#pragma mark 水平方向移动的方法
- (void)horizontalMoved:(float)value{
    //加上上次的value。算出他们的总和
    topValue += value / 100;
    //做个判断，不超出我们视频的时长范围
    if (topValue < 0) {
        topValue = 0;
    }else if (topValue > self.moviePlay.duration){
        topValue = self.moviePlay.duration;
    }
    //当前快进的label显示
    NSString *now = [self timeStrWithTime:topValue];
    //总时长的label显示
    NSString *last = [self timeStrWithTime:self.moviePlay.duration];
    //快进或者快退的状态显示
    NSString *style = nil;
    if (value < 0) {//快退状态
        style = @"<<";
    }else{//快进状态
        style = @">>";
    }
    self.fastLabel.text = [NSString stringWithFormat:@"%@%@/%@",style,now,last];
}

#pragma mark 垂直方向移动的方法
- (void)verticalMoved:(float)value{
    //防止tap手势5秒后撤销视图，声音控件被隐藏
    self.volume.hidden = NO;
    self.volumeController.value -= value / 10000;
    //把修改后的声音赋值给我们的声音控件
    self.volume.value = self.volumeController.value;
}

#pragma mark 根据时间求字符串
- (NSString *)timeStrWithTime:(int)time{
    //得到分钟
    NSString *min = [NSString stringWithFormat:@"%02d",time / 60];
    //得到秒
    NSString *s = [NSString stringWithFormat:@"%02d",time % 60];
    return [NSString stringWithFormat:@"%@:%@",min,s];
}

#pragma mark 轻拍手势执行的方法
- (void)tapView{
    self.play.hidden = !self.play.hidden;
    //其他视图的显示状态根据playBtn来定
    [self otherViewHidden];
    
    if (!self.play.hidden) {//如果视图显示的状态
        //5s后执行隐藏的方法
        //先取消之前已经准备执行的方法，在添加新的方法
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenView) object:nil];
        [self performSelector:@selector(hiddenView) withObject:nil afterDelay:5];
    }
}

#pragma mark 5s后执行隐藏的方法
- (void)hiddenView{
    //隐藏视图
    self.play.hidden = YES;
    [self otherViewHidden];
}

#pragma mark 其他视图的显示状态根据playBtn来定
- (void)otherViewHidden{
    self.downView.hidden = self.play.hidden;
    self.backBtn.hidden = self.play.hidden;
    self.volume.hidden = self.play.hidden;
}

#pragma mark 创建视频播放视图
- (void)createMoviePlayer:(NSURL *)url{
//    NSURL *boundURL = [[NSBundle mainBundle] URLForAuxiliaryExecutable:@"14362617410222.mp4"];
//    self.moviePlay = [[MPMoviePlayerController alloc] initWithContentURL:boundURL];
    
    //创建视频播放视图
    self.moviePlay = [[MPMoviePlayerController alloc] initWithContentURL:url];
    self.moviePlay.view.frame = self.bounds;
    [self addSubview:self.moviePlay.view];
    //样式设置NO，没有任何样式，我们在上边添加自己想要的视图
    self.moviePlay.controlStyle = NO;
    //让它开始播放
    [self.moviePlay play];
}

#pragma mark 创建背景视图
- (void)createBgView{
    //创建一个视图的字视图，想让它和父视图一样大小的时候 一定要使用self.bounds，不要写成self.frame了。
    self.bgView = [[UIView alloc] initWithFrame:self.bounds];
    
    //创建返回按钮
    [self createBackBtn];
    
    //创建播放按钮
    [self createPlayBtn];
    
    //创建下方的视图
    [self createDownView];
    
    //创建声音视图
    [self createVolume];
    
    //把自己添加到总视图上边
    [self addSubview:self.bgView];
}

#pragma mark 创建返回🔘
- (void)createBackBtn{
    self.backBtn = [DIYButton buttonWithType:UIButtonTypeCustom];
    self.backBtn.frame = CGRectMake(10, 10, self.height, 20);
    self.backBtn.icon.image = [UIImage imageNamed:@"back"];
    self.backBtn.textLabel.text = @"  无名称";
    [self.backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.backBtn];
}

#pragma mark 创建播放按钮
- (void)createPlayBtn{
    CGFloat playX = (self.width - kPlayWidth) / 2;
    CGFloat playY = (self.height - kPlayWidth) / 2;
    //创建button的时候，如果我们要使用自己的图片。button的类型一定要是custom类型的
    //如果使用了system类型，系统会自动给你的图片做一个渲染。变成蓝色的，而不是你想要的结果
    self.play = [UIButton buttonWithType:UIButtonTypeCustom];
    self.play.frame = CGRectMake(playX, playY, kPlayWidth, kPlayWidth);
    self.play.hidden = YES;
    //正常状态下的图片
    [self.play setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    //播放状态下的图片
    [self.play setImage:[UIImage imageNamed:@"play"] forState:UIControlStateSelected];
    //执行的方法
    [self.play addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.play];
}

#pragma mark 创建 下方的操作视图
- (void)createDownView{
    CGFloat y = self.height - kProgressHeight;
    self.downView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.width, kProgressHeight)];
    self.downView.hidden = YES;
    //创建beginLabel
    self.begin = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kTimeLabelWidth, kProgressHeight)];
    self.begin.textColor = [UIColor whiteColor];
    self.begin.text = @"00:00";
    self.begin.textAlignment = NSTextAlignmentCenter;
    [self.downView addSubview:self.begin];
    
    //创建进度条
    self.progress = [[Slider alloc] initWithFrame:CGRectMake(kTimeLabelWidth, 0, self.downView.width - kTimeLabelWidth * 2, kProgressHeight)];
    self.progress.delegate = self;
    [self.progress.slider addTarget:self action:@selector(valueChange:event:) forControlEvents:UIControlEventValueChanged];
    /*
     用到的属性有
     value         当前的数值
     minimumValue  最小的数值
     maximumValue  最大的数值
     */
    
    //初始化TimeLabel
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.timeLabel.backgroundColor = [UIColor whiteColor];
    //设置圆角类型
    self.timeLabel.layer.cornerRadius = 10;
    //超出部分不显示
    self.timeLabel.clipsToBounds = YES;
    //文字居中显示
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.progress.thumb = self.timeLabel;
    
    
    [self.downView addSubview:self.progress];
    
    //创建总时间的按钮
    self.end = [[UILabel alloc] initWithFrame:CGRectMake(kTimeLabelWidth + self.progress.width, 0, kTimeLabelWidth, kProgressHeight)];
    self.end.textColor = [UIColor whiteColor];
    self.end.textAlignment = NSTextAlignmentCenter;
    self.end.text = @"--:--";
    [self.downView addSubview:self.end];
    
    [self.bgView addSubview:self.downView];
}

#pragma mark 进度条滑动执行的方法
- (void)valueChange:(UISlider *)slider event:(UIEvent *)event{
    //从event拿到一个touch手势
    UITouch *touch = [[event allTouches] anyObject];
    //判断用户操作的状态
    switch (touch.phase) {
        case UITouchPhaseBegan:{
            //开始的时候，把小球变宽
            self.timeLabel.frame = CGRectMake(0, 0, 50, 20);
            [self.timeLabel timeStrWithTime:slider.value];
            break;
        }
        case UITouchPhaseMoved:{
            //移动中，改变他的显示
            [self.timeLabel timeStrWithTime:slider.value];
            break;
        }
        default:break;
    }
    //防止视图操作的时候消失
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenView) object:nil];
    [self performSelector:@selector(hiddenView) withObject:nil afterDelay:5];
}

#pragma mark 移动结束之后执行的方法.防止手机没有获取到end的状态
- (void)valueChangeEnd{
    //松开手之后跳转指定的位置
    self.moviePlay.currentPlaybackTime = self.progress.slider.value;
    //改变小球原来的大小
    self.timeLabel.frame = CGRectMake(0, 0, 20, 20);
    //清空文字显示
    self.timeLabel.text = @"";
}

#pragma mark 创建声音控件
- (void)createVolume{
    self.volume = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, self.height / 3, 20)];
    self.volume.hidden = YES;
    self.volume.center = CGPointMake(50, self.height / 2);
    [self.volume setThumbImage:[UIImage imageNamed:@"nil"] forState:UIControlStateNormal];
    //最小状态下的图片显示
    [self.volume setMinimumTrackImage:[UIImage imageNamed:@"max"] forState:UIControlStateNormal];
    
    //设置大音量的图片
    UIImageView *max = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    max.center = CGPointMake(self.volume.width + max.width / 2, self.volume.height / 2);
    max.image = [UIImage imageNamed:@"maxVolume"];
    [self.volume addSubview:max];
    
    //设置小音量的图片
    UIImageView *mini = [[UIImageView alloc] initWithFrame:max.bounds];
    mini.center = CGPointMake(-mini.width / 2, self.volume.height / 2);
    mini.image = [UIImage imageNamed:@"miniVolume"];
    [self.volume addSubview:mini];
    
    //先添加在旋转
    self.volume.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    //最大状态下的图片显示
    [self.volume setMaximumTrackImage:[UIImage imageNamed:@"mini"] forState:UIControlStateNormal];
    self.volume.userInteractionEnabled = NO;
    [self.bgView addSubview:self.volume];
}

#pragma mark 播放按钮执行的方法
- (void)playMovie:(UIButton *)btn{
    //做一个取反，改变button的状态
    btn.selected = !btn.selected;
    if (btn.selected) {
        //调用暂停方法
        [self.moviePlay pause];
    }else{
        //else开始的方法
        [self.moviePlay play];
    }
}

#pragma mark 返回的方法
- (void)back:(DIYButton *)btn{
    //使NSTimer停止
    [self.timer invalidate];
    //暂停视频
    [self.moviePlay stop];
    if ([_delegate respondsToSelector:@selector(back)]) {
        [_delegate back];
    }
}

#pragma mark 代理方法
- (void)touchView:(float)value{
    //防止视图操作的时候消失
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenView) object:nil];
    [self performSelector:@selector(hiddenView) withObject:nil afterDelay:5];
    self.moviePlay.currentPlaybackTime = value;
}
#pragma mark 给视频名称赋值
- (void)setTitle:(NSString *)title{
    _title = title;
    self.backBtn.textLabel.text = [NSString stringWithFormat:@"  %@",title];
    self.backBtn.textLabel.font = [UIFont boldSystemFontOfSize:18];
}

@end
