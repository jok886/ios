//
//  SkinTool.h
//  换肤-3
//
//  Created by 王顺子 on 15/9/21.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum {
    kSkinTypeDefault = 0,
    kSkinTypeZQ,
    kSkinTypeGQ,
    kSkinTypeCJ

} kSkinType;


typedef enum{
    kSkinColorTypeLabel = 0
} kSkinColorType;


#define kLabelColor @"labelColor"


@interface SkinTool : NSObject

// 切换主题
+ (void)setSkinWithName:(kSkinType)skinType;

// 当前主题下的图片
+ (UIImage *)imageNamed:(NSString *)imageName;

// 当前主题下的文字颜色
+ (UIColor *)skinColorWithType:(kSkinColorType)type;

@end
