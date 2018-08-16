//
//  ZcmButton.m
//  TestButtonHeight
//
//  Created by LZ on 15/12/25.
//  Copyright © 2015年 lz. All rights reserved.
//

#import "ZcmButton.h"

@interface ZcmButton()
{
    UIView *heightLightView;
    UIColor *originBackgroundColor;
}

@end

@implementation ZcmButton

- (void)dealloc
{
    [self removeObserverMethod];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (heightLightView) {
        heightLightView.frame = self.bounds;
    }
}

#pragma mark -Public
- (void)setHeightLightWhenText:(BOOL)heightLightWhenText
{
    if (heightLightWhenText) {
        [self addObseverMethod];
    }
    else{
        [self removeObserverMethod];
    }
    
    _heightLightWhenText = heightLightWhenText;
}

- (UIColor *)heightLightColor
{
   if (_heightLightColor == nil) {
      _heightLightColor = [UIColor lightGrayColor];
   }
   
   return _heightLightColor;
}

- (CGFloat)viewAlpha
{
   if (_viewAlpha == 0) {
      _viewAlpha = 0.7;
   }
   return _viewAlpha;
}


#pragma mark -Privte
- (void)addObseverMethod
{
    [self addObserver:self
           forKeyPath:@"highlighted"
              options:NSKeyValueObservingOptionNew
              context:nil];

}

- (void)removeObserverMethod
{
    @try{
        [self removeObserver:self
                      forKeyPath:@"highlighted"];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
   
}

- (void)showView
{
    if (self.lightType == ZcmButtonHeightLightOnForeground) {
        
        if (heightLightView == nil) {
            heightLightView = [[UIView alloc] init];
            [self addSubview:heightLightView];
        }
       
        heightLightView.alpha           = self.viewAlpha;
        heightLightView.backgroundColor = self.heightLightColor;
        heightLightView.frame  = self.bounds;
        heightLightView.hidden = NO;
    }
    else{
        if (![self.backgroundColor isEqual:self.heightLightColor]) {
            originBackgroundColor = self.backgroundColor;
        }
        [self setBackgroundColor:self.heightLightColor];
    }
}

- (void)hiddenView
{
    if (self.lightType == ZcmButtonHeightLightOnForeground) {
        if (heightLightView) {
            heightLightView.hidden = YES;
        }
    }
    else{
        [self setBackgroundColor:originBackgroundColor];
    }
    
    
}

#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (self.highlighted) {
        [self showView];
    }
    else{
        [self hiddenView];
    }
}

@end
