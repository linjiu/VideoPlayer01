//
//  TodayController.h
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "PendulumView.h"

@interface TodayController : UITableViewController

@property (nonatomic, strong) PendulumView *pendulum;

@property (assign, nonatomic) BOOL isDetail;

//往期分类详情所用到的url
@property (strong, nonatomic) NSString *url;

@end
