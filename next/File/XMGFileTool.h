//
//  XMGFileTool.h
//  BuDeJie
//
//  Created by xiaomage on 16/3/16.
//  Copyright © 2013年 xxx. All rights reserved.
//  处理文件缓存

#import <Foundation/Foundation.h>

/*
 业务类:以后开发中用来专门处理某件事情,网络处理,缓存处理
 */

@interface XMGFileTool : NSObject

/**
 *  获取文件夹尺寸
 *
 *  @param directoryPath 文件夹路径
 *
 *  @return 返回文件夹尺寸
 */
+ (void)getFileSize:(NSString *)directoryPath completion:(void(^)(NSInteger))completion;


/**
 *  删除文件夹所有文件
 *
 *  @param directoryPath 文件夹路径
 */
+ (void)removeDirectoryPath:(NSString *)directoryPath;


@end
