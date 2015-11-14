//
//  NetHandler.h
//  UI12_4网络请求封装
//
//  Created by zh on 14/12/4.
//  Copyright (c) 2014年 zh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetHandler : NSObject


// 根据网络请求的特点，不同的地方就是请求地址和分析数据的方式不同，就把这两部分分别作为方法参数

+ (void)getDataWithUrl:(NSString *)str completion:(void(^)(NSData *data))block;





@end
