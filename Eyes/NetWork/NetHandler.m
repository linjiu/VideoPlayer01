//
//  NetHandler.m
//  UI12_4网络请求封装
//
//  Created by zh on 14/12/4.
//  Copyright (c) 2014年 zh. All rights reserved.
//

#import "NetHandler.h"

@implementation NetHandler

+ (void)getDataWithUrl:(NSString *)str completion:(void (^)(NSData *data))block
{
    NSString *urlStr = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    request.HTTPMethod = @"GET";
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        // 处理数据
        // 确定地址
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [NSString stringWithFormat:@"%@/%ld.xxoo", docPath, (unsigned long)[str hash]];
        
        
        if (data != nil) {
            [NSKeyedArchiver archiveRootObject:data toFile:path];
            // 当返回的数据不是空，就调用block
            block(data);
        } else {
            // 没有数据/请求失败 就从本地读取最近的一次成功数据
            NSData *pickData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            if (pickData != nil) {
                // 确保有数据才返回
                block(pickData);
            }
        }

    }];
    
    
}



@end
