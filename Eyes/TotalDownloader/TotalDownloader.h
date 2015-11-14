//
//  TotalDownloader.h
//  Downloader
//
//  Created by apple on 15/10/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Download.h"

@interface TotalDownloader : NSObject

//单例方法
+ (instancetype)shareTotalDownloader;

//根据URL添加一个下载
- (Download *)addDownloadingWithURL:(NSString *)url;

//根据URL找到一个下载
- (Download *)findDownloadingWithURL:(NSString *)url;

//返回所有的下载
- (NSArray *)allDownloading;

@end
