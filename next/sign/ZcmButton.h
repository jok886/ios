//
//  ZcmButton.h
//  TestButtonHeight
//
//  Created by LZ on 15/12/25.
//  Copyright © 2015年 lz. All rights reserved.
//

/****
 设置button 点击颜色
 ***/

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZcmButtonHeightLightType) {
    ZcmButtonHeightLightOnBackgroup = 0,
    ZcmButtonHeightLightOnForeground
};


IB_DESIGNABLE
@interface ZcmButton : UIButton

@property(nonatomic, assign) IBInspectable BOOL heightLightWhenText;
@property(nonatomic, assign) IBInspectable ZcmButtonHeightLightType lightType;
@property(nonatomic, assign) IBInspectable CGFloat viewAlpha;
@property(nonatomic, strong) IBInspectable UIColor *heightLightColor;
@end
