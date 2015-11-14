//
//  Download.h
//  Downloader
//
//  Created by apple on 15/10/29.
//  Copyright © 2015年 apple. All rights reserved.
//


#import <Foundation/Foundation.h>

//定义下载完成的block
typedef void(^Complted)(NSString *savePath, NSString *url);
//定义下载中的block
typedef void(^Downloading)(long long bytesWritten, NSInteger progress);
@protocol DownloadDelegate <NSObject>

//下载完成后执行的代理方法。主要作用：让单例移除下载完成后的对象.
- (void)didFinishDownloadWithURL:(NSString *)url;

@end

@interface Download : NSObject

//返回正在下载的url
@property (strong, nonatomic, readonly) NSString *url;

@property (assign, nonatomic) id<DownloadDelegate>delegate;

@property (assign, nonatomic) int progress;//记录当前的下载进度。

@property (readonly) NSURLSessionTaskState state;

//根据url创建一个下载
- (instancetype)initWithURL:(NSString *)url;

//开始下载
- (void)start;

//下载状态的block，需要赋值，一定要执行，不然会崩溃
- (void)didFinishDownload:(Complted)complted downloading:(Downloading)downloading;

//继续
- (void)resume:(NSData *)data;

//暂停
- (void)suspend;

@end
