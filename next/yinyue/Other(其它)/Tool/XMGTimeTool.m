//
//  XMGTimeTool.m
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/4.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGTimeTool.h"

@implementation XMGTimeTool

+ (NSString *)getFormatTimeWithTimeInterval:(NSTimeInterval)time
{
    NSInteger min = (int)time / 60;
    NSInteger sec = (int)time % 60;
    
    
    return [NSString stringWithFormat:@"%02zd:%02zd", min, sec];
}

+ (NSTimeInterval)getTimeIntervalWithFormatTime:(NSString *)formatTime
{
    // 00:00.89
    NSArray *minASec = [formatTime componentsSeparatedByString:@":"];
    
    // min
    NSInteger min = [[minASec firstObject] integerValue];
    
    // sec
    float sec = [[minASec lastObject] floatValue];
    
    
    return min * 60.0 + sec;
    
}

@end
