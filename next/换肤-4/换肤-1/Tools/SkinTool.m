//
//  SkinTool.m
//  换肤-3
//
//  Created by 王顺子 on 15/9/21.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#define kSkinTypePathKey @"skinTypePath"

#import "SkinTool.h"

@implementation SkinTool

+ (void)setSkinWithName:(kSkinType)skinType
{

    // 根据配置文件,获取枚举对应的主题文件夹名称
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"SkinTool.Bundle/SkinConfig.plist" ofType:nil];
    NSDictionary *configDic = [NSDictionary dictionaryWithContentsOfFile:configPath];

    NSString *skinName = configDic[@(skinType).stringValue];

    // 将主题文件夹名称存储到偏好
    NSString *skinTypePath = [@"SkinTool.Bundle/skin/" stringByAppendingString:skinName];
    [[NSUserDefaults standardUserDefaults] setObject:skinTypePath forKey:kSkinTypePathKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (UIImage *)imageNamed:(NSString *)imageName
{

    // 获取当前主题路径
    NSString *skinTypePath = [[NSUserDefaults standardUserDefaults] objectForKey:kSkinTypePathKey];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", skinTypePath, imageName];
    
    return [UIImage imageNamed:imagePath];

}


+ (UIColor *)skinColorWithType:(kSkinColorType)type
{
    // 获取当前主题路径
    NSString *skinTypePath = [[NSUserDefaults standardUserDefaults] objectForKey:kSkinTypePathKey];

    // 拼接颜色配置文件路径
    NSString *textColorConfigPath = [[NSBundle mainBundle] pathForResource:[skinTypePath stringByAppendingString:@"/TextColorConfig.plist"] ofType:nil];

    // 根据颜色字段名称, 获取对应的颜色字符串(以,分割的RGB字符串)
    NSDictionary *colorDic = [NSDictionary dictionaryWithContentsOfFile:textColorConfigPath];
    NSString *colorStr = colorDic[@(type).stringValue];

    // 根据颜色字符创,分别获取对应的RGB
    NSArray *colorArray = [colorStr componentsSeparatedByString:@","];

    float red = [colorArray[0] floatValue] / 255.0;
    float green = [colorArray[1] floatValue] / 255.0;
    float blue = [colorArray[2] floatValue] / 255.0;
    // 返回颜色
    return  [UIColor colorWithRed:red green:green blue:blue alpha:1];



}


@end
