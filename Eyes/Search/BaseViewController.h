//
//  BaseViewController.h
//  音乐项目
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PendulumView.h"

@interface BaseViewController : UIViewController

@property (nonatomic, strong) PendulumView *pendulum;


- (void)setLoading;

@end
