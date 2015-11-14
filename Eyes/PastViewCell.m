//
//  PastViewCell.m
//  Eyes
//
//  Created by apple on 15/11/1.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "PastViewCell.h"
#import "UIImageView+WebCache.h"

@interface PastViewCell ()

@property (strong, nonatomic) UIImageView *image;
@property (strong, nonatomic) UILabel *name;

@end

@implementation PastViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:self.image];
        
        //可以设置 居中 显示 所以设置全屏显示就可以了
        self.name = [[UILabel alloc] initWithFrame:self.bounds];
        self.name.textAlignment = NSTextAlignmentCenter;
        self.name.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.name];
    }
    return self;
}

- (void)setModel:(PastModel *)model{
    _model = model;
    [self.image sd_setImageWithURL:[NSURL URLWithString:model.bgPicture]];
    
    self.name.text = model.name;
    
}

@end
