//
//  DIYButton.m
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "DIYButton.h"

@implementation DIYButton

//有两种重写方法  主要看你想怎么去创建我这个button
//使用button自带的便利构造器创建
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self.icon removeFromSuperview];
    [self.textLabel removeFromSuperview];
    [self.iconSelected removeFromSuperview];
    //创建一个正方形 的 imageView
    _icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.height)];
    [self addSubview:self.icon];
    
    _iconSelected = [[UIImageView alloc] initWithFrame:self.icon.bounds];
    self.iconSelected.hidden = YES;
    [self addSubview:self.iconSelected];
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.height, 0, frame.size.width - frame.size.height, frame.size.height)];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:self.textLabel];
}

#pragma mark 重写selected方法 做图片更换
- (void)setSelected:(BOOL)selected{
    //父类怎么做 还怎么做 我们只是在它原有的基础上添加自己的方法
    [super setSelected:selected];
    //根据selected属性对图片做修改
    if (selected) {
        self.iconSelected.hidden = NO;
        self.icon.hidden = YES;
    }else{
        self.iconSelected.hidden = YES;
        self.icon.hidden = NO;
    }
}

//使用alloc创建
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

@end
