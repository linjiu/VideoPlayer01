//
//  MoviePlayer.h
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved,
    PanDirectionVerticalMoved
};

@protocol MoviePlayerDelegate <NSObject>

//点击返回按钮执行的方法
- (void)back;

@end

@interface MoviePlayer : UIView

@property (strong, nonatomic) NSString *title;//视频名称

//写代理的时候，类型一定要是assign，要不然此视图无法被销毁
@property (assign, nonatomic) id<MoviePlayerDelegate>delegate;
//初始化方法
- (instancetype)initWithFrame:(CGRect)frame URL:(NSURL *)url;

@end
