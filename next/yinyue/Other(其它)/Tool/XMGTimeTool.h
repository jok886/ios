//
//  XMGTimeTool.h
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/4.
//  Copyright © 2015年 xiaomage. All rights reserved.

/**
 *  负责时间格式的转换的工具类
 */

#import <Foundation/Foundation.h>

@interface XMGTimeTool : NSObject

/**
 *  根据时间秒数, 转换成为"分钟:秒数"的格式
 */
+ (NSString *)getFormatTimeWithTimeInterval:(NSTimeInterval)time;

/**
 *  根据"分钟:秒数"的格式, 转换成为时间秒数
 */
+ (NSTimeInterval)getTimeIntervalWithFormatTime:(NSString *)formatTime;

@end
