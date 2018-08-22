//
//  XMGVideoCamera.h
//  01-视频采集
//
//  Created by 小码哥 on 2017/4/2.
//  Copyright © 2017年 xmg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface XMGVideoCamera : NSObject

@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;

// 当采集到一帧,就会自动去执行Block
@property (nonatomic, strong) void(^sampleBufferBlock)(CMSampleBufferRef sampleBuffer);

/*
    分辨率,帧率,视频原数据,采集视频方向,镜像
    帧率,视频原数据 : outPut
    分辨率: 会话
    采集视频方向,镜像: 连接
 */
@property (nonatomic, strong) NSString *sessionPreset;

@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;



// 开启照相机
- (void)startCamera;

@end
