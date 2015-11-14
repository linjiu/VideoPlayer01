//
//  HeaderView.m
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//


#import "HeaderView.h"
#import "Define.h"

@implementation HeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"SnellRoundhand-Black" size:16];
        [self.contentView addSubview:self.label];
    }
    return self;
}

@end
