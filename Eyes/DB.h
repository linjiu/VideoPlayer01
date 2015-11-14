//
//  DB.h
//  Eyes
//
//  Created by apple on 15/10/30.
//  Copyright © 2015年 apple. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TodayModel.h"

@interface DB : NSObject

//关闭数据库
+ (void)close;

// 返回所有下载完成的TodayModel
+ (NSArray *)allDownloadComplated;

//添加一条下载完成的数据
+ (void)insertDownloadComplated:(TodayModel *)model;

//根据url删除一个下载完成的数据
+ (void)deleteDownloadComplated:(NSString *)url;

//根据url找到一个下载完成的数据
+ (TodayModel *)findDownloadComplated:(NSString *)url;

//返回所有正在下载的
+ (NSArray *)allDownloading;

//插入一条正在下载的
+ (void)insertDownloading:(TodayModel *)model;

//删除一个正在下载的
+ (void)deleteDownloading:(NSString *)url;

//查找一个正在下载的
+ (TodayModel *)findDownloading:(NSString *)url;

//更新一个正在下载的数据
+ (void)updateDownloading:(int)proress dataPath:(NSString *)dataPath URL:(NSString *)url;















@end
