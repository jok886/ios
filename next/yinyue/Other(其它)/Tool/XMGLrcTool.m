//
//  XMGLrcTool.m
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/5.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGLrcTool.h"
#import "XMGTimeTool.h"
@implementation XMGLrcTool


+ (void)getLrcDataWithLrcFileName:(NSString *)fileName resultBlock:(void(^)(NSArray <XMGLrcModel *>*lrcMs))block
{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    // 取出所有歌词文件的内容
    NSString *lrcContent = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
//    NSLog(@"%@", lrcContent);
    
    // 创建一个用于存储歌词数据模型的数组
    NSMutableArray *array = [NSMutableArray array];
    
    NSArray *lrcLines = [lrcContent componentsSeparatedByString:@"\n"];
    for(int i = 0; i < lrcLines.count; i++)
    {
        NSString *lrcLine = lrcLines[i];
        // 过滤没有必要解析的内容
        if([lrcLine containsString:@"[ti:]"] || [lrcLine containsString:@"[ar:]"] || [lrcLine containsString:@"[al:]"])
            continue;
        
        // 把[ 过滤, 方便解析
        lrcLine = [lrcLine stringByReplacingOccurrencesOfString:@"[" withString:@""];
        
        NSArray *lrcTimeAndText = [lrcLine componentsSeparatedByString:@"]"];
        
        // 取歌词时间
        NSString *beginTime = [lrcTimeAndText firstObject];
        // 取歌词内容
        NSString *lrcText = [lrcTimeAndText lastObject];
        
        // 创建一个歌词数据模型
        XMGLrcModel *lrcModel = [[XMGLrcModel alloc] init];
        lrcModel.beginTime = [XMGTimeTool getTimeIntervalWithFormatTime:beginTime];
        lrcModel.lrcText = lrcText;
        
        // 保存到数组
        [array addObject:lrcModel];

    }

    for (int i = 0 ; i < array.count; i ++) {
        if (i == array.count - 1) {
            break;
        }
        XMGLrcModel *lrcM = array[i];
        XMGLrcModel *nextLrcM = array[i+1];
        lrcM.endTime = nextLrcM.beginTime;
    }
    
    
    block(array);
    
}

+ (NSInteger)getRowWithTime:(NSTimeInterval)time andLrcArray:(NSArray <XMGLrcModel *>*)lrcMs
{
    __block NSInteger row = 0;
    [lrcMs enumerateObjectsUsingBlock:^(XMGLrcModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (time >= obj.beginTime && time < obj.endTime) {
            row = idx;
            *stop = YES;
        }
        
    }];
    
    return row;
    
}

+ (XMGLrcModel *)getLrcModelWithTime:(NSTimeInterval)time andLrcArray:(NSArray <XMGLrcModel *>*)lrcMs
{
    __block XMGLrcModel *lrcM;
    [lrcMs enumerateObjectsUsingBlock:^(XMGLrcModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (time >= obj.beginTime && time < obj.endTime) {
            lrcM = obj;
            *stop = YES;
        }
        
    }];
    
    return lrcM;
}




@end
