//
//  ViewController.m
//  UIWebViewPullDownRefreshDemo
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//


#import "webVController.h"

@interface webVController ()

@end

@implementation webVController

@synthesize uiWebView;
- (void)back:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //webview 和 webview 的 scrollView 的委托都设置为self

    
    self.uiWebView = [[UIWebView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:self.uiWebView];
    
    
    UIButton *backB = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [backB addTarget:self action:@selector(back:) forControlEvents:(UIControlEventTouchUpInside)];
    backB.frame = CGRectMake(20, 20, 40, 40);
    [backB setImage:[UIImage imageNamed:@"iconfont-fanhui-2"] forState:(UIControlStateNormal)];
    [self.view addSubview:backB];
    
    
    self.uiWebView.delegate = self;
    self.uiWebView.scrollView.delegate = self;
    [self loadPage];
    
    //初始化refreshView，添加到webview 的 scrollView子视图中
    if (_refreshHeaderView == nil) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0-self.uiWebView.scrollView.bounds.size.height, self.uiWebView.scrollView.frame.size.width, self.uiWebView.scrollView.bounds.size.height)];
        _refreshHeaderView.delegate = self;
        [self.uiWebView.scrollView addSubview:_refreshHeaderView];
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    [self setLoading];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//加载网页
- (void)loadPage {
    NSURL *url = [[NSURL alloc] initWithString:self.str];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.uiWebView loadRequest:request];
}

#pragma mark - webview delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    _reloading = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _reloading = NO;
    
    [self.pendulum removeFromSuperview];
    
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.uiWebView.scrollView];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"load page error:%@", [error description]);
    _reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.uiWebView.scrollView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self loadPage];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
}

@end
