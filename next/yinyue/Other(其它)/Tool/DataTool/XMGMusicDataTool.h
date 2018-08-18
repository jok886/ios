//
//  XMGMusicDataTool.h
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/4.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMGMusicModel.h"

@interface XMGMusicDataTool : NSObject


+ (void)getMusicDataWithResultBlock:(void(^)(NSArray <XMGMusicModel *>*musicMs))block;

@end
