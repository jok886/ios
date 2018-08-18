//
//  XMGLrcTool.h
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/5.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMGLrcModel.h"

@interface XMGLrcTool : NSObject


+ (void)getLrcDataWithLrcFileName:(NSString *)fileName resultBlock:(void(^)(NSArray <XMGLrcModel *>*lrcMs))block;


+ (NSInteger)getRowWithTime:(NSTimeInterval)time andLrcArray:(NSArray <XMGLrcModel *>*)lrcMs;

+ (XMGLrcModel *)getLrcModelWithTime:(NSTimeInterval)time andLrcArray:(NSArray <XMGLrcModel *>*)lrcMs;

@end
