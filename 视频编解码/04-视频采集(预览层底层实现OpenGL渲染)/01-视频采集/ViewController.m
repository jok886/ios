//
//  ViewController.m
//  01-视频采集
//
//  Created by 小码哥 on 2017/4/1.
//  Copyright © 2017年 xmg. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

/*
    潜力: 快速学习能力
    官方文档 WWDC
    iOS11
 */

/*
    AVFoundtion Program Guide
    视频:AVFoundtion
 */

/*
    AVFoundtion
    框架 => 了解框架哪些类,每个类有什么用
 */

/*
 AVCaptureDevice : 摄像头,麦克风
 AVCaptureInput 输入端口
 AVCaptureOutput 设备输出
 AVCaptureSession 管理输入到输出数据流
 AVCaptureVideoPreviewLayer : 展示采集 预览View
 */

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation ViewController

- (UIImageView *)imageView
{
    if (_imageView == nil) {
    
        UIImageView *imageView = [[UIImageView alloc] init];
        
//        imageView.layer.anchorPoint = CGPointMake(0, 0);
        
        imageView.frame = CGRectMake(0, 0, ScreenW, ScreenH);
        
//        imageView.transform = CGAffineTransformMakeTranslation(ScreenW, 0);
//        imageView.transform = CGAffineTransformRotate(imageView.transform, M_PI_2);
        
        [self.view addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}
// 默认采集的视频:横屏
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1.创建捕获会话 : 设置分辨率
    [self setupSession];
    
    // 2.添加输入
    [self setupInput];
    
    // 3.添加输出
    [self setupOutput];
    
    // 开启会话
    // 在输入与输出对象中,建立一个连接
    [_captureSession startRunning];
    
    // 采集的数据怎么显示出来 => AVCaptureVideoPreviewLayer
    //    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    //    [self.view addSubview:imageView];
    //    _imageView = imageView;
    [self imageView];
    
    // 尺寸不对
}


// 镜像: 正反面设置
// 帧率:

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
/*
    CMSampleBufferRef:帧缓存数据,描述当前帧信息
    获取帧缓存信息 : CMSampleBufferGet
    CMSampleBufferGetDuration:获取当前帧播放时间
    CMSampleBufferGetImageBuffer:获取当前帧图片信息
 */

// 当create retain copy 需要自己管理内存 C语言API 自己去release
// CoreImage:底层绘制图片
// 获取帧数据
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"获取一帧数据");
    // 是否在子线程更新UI
//    NSLog(@"%@",[NSThread currentThread]);
    
    // 获取图片帧数据
    // 获取帧播放时间
    // CMTime durtion = CMSampleBufferGetDuration(sampleBuffer);
    
    // 获取帧图片数据
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // CIImage
    CIImage *image = [CIImage imageWithCVImageBuffer:imageBuffer];
    
    // OpenGL上下文:EAGLContext
    EAGLContext *ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // CoreImage上下文
    CIContext *context = [CIContext contextWithEAGLContext:ctx];
    
    // 创建CGImage
    // image.extent:获取图片尺寸 GPU生成一张图片
    CGImageRef imgRef = [context createCGImage:image fromRect:image.extent];
    
    // UIImage
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    
//    // 主线程更新UI
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        self.imageView.image = img;
        
        // 内存管理,主动释放内存
        CGImageRelease(imgRef);
    });
    
    
    // 把这个数据渲染出来 显示
    
}

/*
 CPU:
 
 GPU:显存 OpenGL
 
 */

@end
