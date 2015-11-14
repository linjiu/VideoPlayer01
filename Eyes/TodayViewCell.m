//
//  TodayViewCell.m
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "TodayViewCell.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Detail.h"
#import "Define.h"

@interface TodayViewCell ()

@property (strong, nonatomic) UIImageView *image;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *detail;

@end

@implementation TodayViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSInteger height = kScreenWidth / 1242 * 777;
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, height)];
        [self addSubview:self.image];
        
        CGFloat y = (height - 60) / 2;
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, y, kScreenWidth, 30)];
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.text = @"test";
        self.title.font = [UIFont systemFontOfSize:18];
        self.title.textColor = [UIColor whiteColor];
        [self addSubview:self.title];
        
        self.detail = [[UILabel alloc] initWithFrame:CGRectMake(0, y + 30, kScreenWidth, 30)];
        self.detail.textAlignment = NSTextAlignmentCenter;
        self.detail.text = @"detail";
        self.detail.font = [UIFont systemFontOfSize:14];
        self.detail.textColor = [UIColor whiteColor];
        [self addSubview:self.detail];
        
    }
    return self;
}

//根据model给cell赋值
- (void)setModel:(TodayModel *)model{
    _model = model;
    
    //给图片赋值
    [_image sd_setImageWithURL:[NSURL URLWithString:model.coverForDetail]];
    //给title赋值
    _title.text = model.title;
    //给Detail赋值
    [_detail detailWithStyle:model.category time:model.duration];
}

@end
