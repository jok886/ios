//
//  XMGImageTool.m
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/5.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGImageTool.h"

@implementation XMGImageTool

+ (UIImage *)createImageWithText:(NSString *)text inImage:(UIImage *)image
{
    
    // 1, 开启图形上细纹
    UIGraphicsBeginImageContext(image.size);
    
    
    // 2. 绘制背景图片
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    // 3. 绘制文字
    // 3.1  创建段落样式,调整文字对齐方式
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *dic = @{
                          NSFontAttributeName : [UIFont systemFontOfSize:20],
                          NSForegroundColorAttributeName : [UIColor purpleColor],
                          NSParagraphStyleAttributeName : style
                          
                          };
    [text drawInRect:CGRectMake(0, 0, image.size.width, 26) withAttributes:dic];
    
    
    // 4. 取出绘制的图片
   UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 5. 关闭图形上下文
    UIGraphicsEndImageContext();
    
    return resultImage;
    
 
}

@end
