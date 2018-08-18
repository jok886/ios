//
//  XMGLrcLabel.m
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/5.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGLrcLabel.h"

@implementation XMGLrcLabel

-(void)setProgress:(float)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // 设置填充颜色
    [[UIColor greenColor] set];
    
    // 需要填充的颜色范围
    CGRect fillRect = CGRectMake(0, 0, rect.size.width * self.progress, rect.size.height);
//    UIRectFill(fillRect);
    // 带模式的填充
    UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
    
}


@end
