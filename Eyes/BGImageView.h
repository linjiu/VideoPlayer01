//
//  BGImageView.h
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface BGImageView : UIScrollView

//定义一个定时器，自己放大缩小，销毁本程序的时候 需要调用 [self.timer invalidate];此视图才会被销毁掉
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSString *url;//图片地址

@end
