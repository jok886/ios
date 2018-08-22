//
//  XMGVideoCamera.m
//  01-视频采集
//
//  Created by 小码哥 on 2017/4/2.
//  Copyright © 2017年 xmg. All rights reserved.
//

#import "XMGVideoCamera.h"

@interface XMGVideoCamera ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureConnection *connection;
@end

@implementation XMGVideoCamera

- (instancetype)init
{
    if (self = [super init]) {
        
        // 1.创建捕获会话 : 设置分辨率
        [self setupSession];
        
        // 2.添加输入
        [self setupInput];
        
        // 3.添加输出
        [self setupOutput];

        
    }
    return self;
}


// 设置捕获会话: 分辨率
- (void)setupSession
{
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    _captureSession = captureSession;
    // 设置分辨率:720 标清
    captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
}

// 会话添加输入对象
- (void)setupInput
{
    // 2.建立输入到输出轨道
    // 2.1 获取摄像头
    AVCaptureDevice *videoDevice = [self deviceWithPosition:AVCaptureDevicePositionFront];
    
    // 设备输入对象
    // 帧率:minFrameDuration 10 => AVCaptureDeviceInput
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    
    
    // 给会话添加输入
    if ([_captureSession canAddInput:videoInput]) {
        [_captureSession addInput:videoInput];
    }
}

// 会话添加输出对象:视频原数据YUV,RGB ,设置代理获取帧数据,获取输入与输出的连接
//  帧率
- (void)setupOutput
{
    // 视频输出:设置视频原数据格式:YUV,RGB YUV
    // 苹果不支持YUA渲染,只支持RGB渲染 -> YUV => RGB
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    // 帧率:1秒多少帧
    videoOutput.minFrameDuration = CMTimeMake(1, 10);
    
    // videoSettings:设置视频原数据格式 YUV FULL
    videoOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    
    // 队列:串行,并行
    dispatch_queue_t queue = dispatch_queue_create("SERIAL", DISPATCH_QUEUE_SERIAL);
    
    // 设置代理:获取帧数据 在异步串行队列
    [videoOutput setSampleBufferDelegate:self queue:queue];
    
    // 给会话添加输出对象
    if ([_captureSession canAddOutput:videoOutput]) {
        // 给会话添加输入输出就会自动建立连接
        [_captureSession addOutput:videoOutput];
    }
    
    // 注意:一定要在添加之后
    // 获取输入与输出直接连接
    AVCaptureConnection *connection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // 设置采集数据 方向 , 镜像
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    connection.videoMirrored = YES;
    connection.automaticallyAdjustsVideoMirroring = NO;
    _connection = connection;
}

- (void)setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation
{
    _videoOrientation = videoOrientation;
    _connection.videoOrientation = _videoOrientation;
}

- (AVCaptureDevice *)deviceWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devices];
    
    AVCaptureDevice *device;
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    
    return nil;
    
}

- (void)startCamera
{
    // 在输入与输出对象中,建立一个连接
    [_captureSession startRunning];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
// 获取帧数据
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"%s",__func__);
    if (_sampleBufferBlock) {
        _sampleBufferBlock(sampleBuffer);
    }
}


@end
