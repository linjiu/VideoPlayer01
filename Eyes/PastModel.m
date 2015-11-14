//
//  PastModel.m
//  Eyes
//
//  Created by apple on 15/11/1.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "PastModel.h"

@implementation PastModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

//装逼方法，一行代码 KVC
- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if ([super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

@end
