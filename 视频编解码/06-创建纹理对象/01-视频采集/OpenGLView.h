//
//  OpenGLView.h
//  01-视频采集
//
//  Created by 小码哥 on 2017/4/2.
//  Copyright © 2017年 xmg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface OpenGLView : UIView

- (void)processWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
