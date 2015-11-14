//
//  UILabel+Detail.h
//  Eyes
//
//  Created by apple on 15/10/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Detail)

- (void)detailWithStyle:(NSString *)style time:(NSInteger)time;

- (void)dateStrWithdate:(NSTimeInterval)date;

- (void)timeStrWithTime:(NSInteger)time;

@end
