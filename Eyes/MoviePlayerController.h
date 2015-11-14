//
//  MoviePlayerController.h
//  Eyes
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TodayModel.h"

@interface MoviePlayerController : UIViewController

//视频播放 所需要的model
@property (strong, nonatomic) TodayModel *model;

@end
