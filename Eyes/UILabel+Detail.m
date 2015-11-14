//
//  UILabel+Detail.m
//  Eyes
//
//  Created by apple on 15/10/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "UILabel+Detail.h"

@implementation UILabel (Detail)

- (void)detailWithStyle:(NSString *)style time:(NSInteger)time{
    //得到分钟
    NSString *min = [NSString stringWithFormat:@"%ld",time / 60];
    //得到秒
    NSString *s = [NSString stringWithFormat:@"%ld",time % 60];
    //拼接为详情
    NSString *detail = [NSString stringWithFormat:@"%@ / %@'%@\"",style,min,s];
    self.text = detail;
}

- (void)timeStrWithTime:(NSInteger)time{
    //得到分钟
    NSString *min = [NSString stringWithFormat:@"%02ld",time / 60];
    //得到秒
    NSString *s = [NSString stringWithFormat:@"%02ld",time % 60];
    self.text = [NSString stringWithFormat:@"%@:%@",min,s];
}

- (void)dateStrWithdate:(NSTimeInterval)date{
    //根据时间戳求出时间
    NSDate *dateNow =[NSDate dateWithTimeIntervalSince1970:date];
    //设置date样式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //formatter样式 MM是阿拉伯数字 MMM英文简写 MMMM是英文全拼
    formatter.dateFormat = @"MMM-dd";
    //输出格式为英文
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-us"];
    //所在时区，使用系统所在的时区
    formatter.timeZone = [NSTimeZone systemTimeZone];
    NSString *dateStr = [formatter stringFromDate:dateNow];
    self.text = dateStr;
}

@end
