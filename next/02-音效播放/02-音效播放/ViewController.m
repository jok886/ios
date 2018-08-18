//
//  ViewController.m
//  02-音效播放
//
//  Created by 王顺子 on 15/10/10.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 根据音效的URL地址, 创建音效对应的 soundID
    // 1. 获取URL
    CFURLRef urlRef1 = (__bridge CFURLRef)([[NSBundle mainBundle] URLForResource:@"m_16.wav" withExtension:nil]);
    // 2. 创建保存soundID 的变量
    SystemSoundID soundID1;
    // 3. 通过url, 和soundID的地址, 接收对应的音效soundID
    AudioServicesCreateSystemSoundID(urlRef1, &soundID1);


    // 根据音效的URL地址, 创建音效对应的 soundID
    CFURLRef urlRef2 = (__bridge CFURLRef)([[NSBundle mainBundle] URLForResource:@"m_17.wav" withExtension:nil]);
    SystemSoundID soundID2;
    AudioServicesCreateSystemSoundID(urlRef2, &soundID2);

    // 根据soundID, 播放一段音效
//    AudioServicesPlaySystemSound(soundID1);

    // 播放音效时, 带振动
//    AudioServicesPlayAlertSound(soundID1);

    // 播放完成后, 回调代码块
    AudioServicesPlaySystemSoundWithCompletion(soundID1, ^{
        // 释放音效内存
        AudioServicesDisposeSystemSoundID(soundID1);
        AudioServicesPlaySystemSoundWithCompletion(soundID2, ^{
            AudioServicesDisposeSystemSoundID(soundID2);
        });

    });


}

@end
