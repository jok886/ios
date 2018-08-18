//
//  XMGImageTool.h
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/5.
//  Copyright © 2015年 xiaomage. All rights reserved.
/**
 *  这个工具类负责图片的处理
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XMGImageTool : NSObject
/**
 *  根据一个图片和一段文本, 把文本加到图片上, 并生成一个新的图片返回
 *
 *  @param text  文本内容
 *  @param image 图片
 */
+ (UIImage *)createImageWithText:(NSString *)text inImage:(UIImage *)image;

@end
