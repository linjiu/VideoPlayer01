//
//  TotalDownloader.m
//  Downloader
//
//  Created by apple on 15/10/29.
//  Copyright © 2015年 apple. All rights reserved.
//


#import "TotalDownloader.h"

@interface TotalDownloader ()<DownloadDelegate>

//创建一个字典。用来保存当前存在的下载。使单例持有它，从而不会被销毁
@property (strong, nonatomic) NSMutableDictionary *dic;

@end

@implementation TotalDownloader

//懒加载。
- (NSMutableDictionary *)dic{
    if (!_dic) {
        self.dic = [NSMutableDictionary dictionary];
    }
    return _dic;
}

//创建一个单例
+ (instancetype)shareTotalDownloader{
    static TotalDownloader *total = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        total = [[TotalDownloader alloc] init];
    });
    return total;
}

//根据URL添加一个下载
- (Download *)addDownloadingWithURL:(NSString *)url{
    //判断是否已经有这个下载了。如果有了，从字典中取出我们的下载
    //如果没有，创建一个新的，并添加到字典里面.
    Download *download = self.dic[url];
    if (!download) {
        download = [[Download alloc] initWithURL:url];
        [self.dic setValue:download forKey:url];
    }
    download.delegate = self;
    [download didFinishDownload:^(NSString *savePath, NSString *url) {} downloading:^(long long bytesWritten, NSInteger progress) {}];
    return download;
}

//根据URL找到一个下载
- (Download *)findDownloadingWithURL:(NSString *)url{
    return self.dic[url];
}

//返回所有的下载
- (NSArray *)allDownloading{
    return [self.dic allValues];
}

- (void)didFinishDownloadWithURL:(NSString *)url{
    //下载完成后 从我们的字典中移除该对象。让单例不在持有它
    [self.dic removeObjectForKey:url];
}

@end
