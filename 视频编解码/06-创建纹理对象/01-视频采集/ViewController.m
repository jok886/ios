//
//  ViewController.m
//  01-视频采集
//
//  Created by 小码哥 on 2017/4/1.
//  Copyright © 2017年 xmg. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "XMGVideoCamera.h"
#import "OpenGLView.h"
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property (nonatomic, weak) OpenGLView *openGLView;
@property (nonatomic, strong) XMGVideoCamera *camera;
@end

@implementation ViewController
- (OpenGLView *)openGLView
{
    if (_openGLView == nil) {
        OpenGLView *openGLView = [[OpenGLView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:openGLView];
        _openGLView = openGLView;
    }
    return _openGLView;
}

// 默认采集的视频:横屏
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // VideoCamera
    [self openGLView];

    // 创建视频照相机
    XMGVideoCamera *camera = [[XMGVideoCamera alloc] init];
    camera.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    _camera = camera;
    
    __weak typeof(self) weakSelf = self;
    
    // 获取帧缓存数据
    camera.sampleBufferBlock = ^(CMSampleBufferRef sampleBuffer){
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.openGLView processWithSampleBuffer:sampleBuffer];
        
    };
    
    // 开启照相机
    [camera startCamera];
    
}

@end
