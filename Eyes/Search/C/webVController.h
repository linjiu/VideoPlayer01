//
//  ViewController.h
//  UIWebViewPullDownRefreshDemo
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//


#import "BaseViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface webVController : BaseViewController <UIWebViewDelegate, UIScrollViewDelegate, EGORefreshTableHeaderDelegate> {
    //下拉视图
    EGORefreshTableHeaderView * _refreshHeaderView;
    //刷新标识，是否正在刷新过程中
    BOOL _reloading;
}

@property (nonatomic, copy) NSString *str;
@property (nonatomic, strong) UIWebView *uiWebView;
@end
