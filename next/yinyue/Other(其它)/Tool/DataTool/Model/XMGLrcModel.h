//
//  XMGLrcModel.h
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/5.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMGLrcModel : NSObject

/** 开始时间 */
@property(nonatomic, assign) NSTimeInterval beginTime;

/** 结束时间 */
@property(nonatomic, assign) NSTimeInterval endTime;

/** 歌词内容 */
@property (nonatomic ,copy) NSString *lrcText;

@end
