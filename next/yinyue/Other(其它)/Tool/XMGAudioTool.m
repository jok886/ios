//
//  XMGAudioTool.m
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/4.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGAudioTool.h"


@interface XMGAudioTool()

/** 音乐播放器 */
@property (nonatomic ,strong) AVAudioPlayer  *player;

/** 音乐播放器字典 */
@property (nonatomic ,strong) NSMutableDictionary  *playerDic;

@end


@implementation XMGAudioTool

// 通过一个字典存储, 而不是通过一个AVAudioPlayer来控制播放逻辑, 是为了方便往后的扩展
-(NSMutableDictionary *)playerDic
{
    if (!_playerDic) {
        _playerDic = [NSMutableDictionary dictionary];
        [self setBackPlay];
    }
    return _playerDic;
}

/**
 *  支持后台播放的代码(此处, 还应该勾选后台模式!!! 千万别忘记! 而且测试只能在真机上进行测试, 模拟器傻逼,一直会播放)
 */
- (void)setBackPlay
{
    // 1. 获取音频回话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // 2. 设置音频回话类别
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 3. 激活音频回话
    [session setActive:YES error:nil];
}


- (AVAudioPlayer *)playAudioWith:(NSString *)audioName
{
    // 1. 应该从播放器字典里面查找对应的播放器
    AVAudioPlayer *player = self.playerDic[audioName];
    if (player == nil) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:audioName withExtension:nil];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        if(player)
           {
               // 存储到字典
               [self.playerDic setObject:player forKey:audioName];
           }else
           {
               return nil;
           }
 
    }

    // 准备播放
    [player prepareToPlay];
    
    // 播放
    [player play];
    
    return player;
}


- (void)pauseAudioWith:(NSString *)audioName
{
    // 1. 应该从播放器字典里面查找对应的播放器
    AVAudioPlayer *player = self.playerDic[audioName];
    [player pause];
}


- (void)stopAudioWith:(NSString *)audioName
{
    // 1. 应该从播放器字典里面查找对应的播放器
    AVAudioPlayer *player = self.playerDic[audioName];
    [player stop];
    
    // 2. 从字典里面移除
    [self.playerDic removeObjectForKey:audioName];

}


@end
