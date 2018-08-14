//
//  XMGQRCodeTool.h
//  二维码扫描OC
//
//  Created by 王顺子 on 16/3/12.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Singleton.h"


@interface XMGQRCodeTool : NSObject
single_interface(XMGQRCodeTool)

// 设置是否需要描绘二维码边框
@property (nonatomic, assign) BOOL isDrawQRCodeRect;

// 开始扫描
- (void)beginScanInView:(UIView *)view result:(void(^)(NSArray<NSString *> *resultStrs))resultBlock;

// 停止扫描
- (void)stopScan;

// 设置兴趣点
- (void)setInsteretRect:(CGRect)originRect;


@end
