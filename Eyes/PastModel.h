//
//  PastModel.h
//  Eyes
//
//  Created by apple on 15/11/1.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PastModel : NSObject

@property (strong, nonatomic) NSString *bgPicture;//背景图片

@property (strong, nonatomic) NSString *name;//分类名称

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
