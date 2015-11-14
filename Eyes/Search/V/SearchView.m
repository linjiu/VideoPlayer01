//
//  SearchView.m
//  音乐播放模块
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "SearchView.h"

@implementation SearchView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //返回按钮
        self.backB = [UIButton buttonWithType:(UIButtonTypeSystem)];
        
        [self addSubview:self.backB];
        //搜索输入框
        self.textF = [[UITextField alloc]init];
        self.textF.borderStyle = UITextBorderStyleRoundedRect;
        self.textF.clearButtonMode = UITextFieldViewModeAlways;
        self.textF.placeholder = @"搜索视频";
        [self addSubview:self.textF];
        //搜索按钮
        self.searchB = [UIButton buttonWithType:(UIButtonTypeSystem)];
        [self.searchB setTitle:@"搜索" forState:(UIControlStateNormal)];
        self.searchB.tintColor = [UIColor cyanColor];
        self.searchB.titleLabel.font = [UIFont systemFontOfSize:18];
        [self addSubview:self.searchB];
        
        
    }
    return self;
}
#pragma mark -- 页面布局
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backB.frame = CGRectMake(0, 20, 50, 40);
    self.textF.frame = CGRectMake(self.backB.frame.origin.x + self.backB.bounds.size.width + 40, 20, self.bounds.size.width - self.backB.bounds.size.width - self.searchB.bounds.size.width - 80, 40);
    self.searchB.frame = CGRectMake(self.textF.frame.origin.x + self.textF.bounds.size.width + 10, 20, 50, 40);

}

@end
