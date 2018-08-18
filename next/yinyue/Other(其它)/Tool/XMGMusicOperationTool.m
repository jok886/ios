//
//  XMGMusicOperationTool.m
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/4.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGMusicOperationTool.h"
#import "XMGAudioTool.h"
#import <MediaPlayer/MediaPlayer.h>
#import "XMGImageTool.h"
#import "XMGLrcTool.h"

@implementation XMGMusicMessageModel

@end


@interface XMGMusicOperationTool()

/** 音乐播放的工具类 */
@property (nonatomic ,strong) XMGAudioTool  *audioTool;
/** 当前正在播放的索引 */
@property(nonatomic, assign) NSInteger currentPlayIndex;

@property (nonatomic, weak) AVAudioPlayer *player;

@end

@implementation XMGMusicOperationTool
@synthesize musicMessageModel = _musicMessageModel;

single_implementation(XMGMusicOperationTool)

-(XMGMusicMessageModel *)musicMessageModel
{
    if (!_musicMessageModel) {
        _musicMessageModel = [[XMGMusicMessageModel alloc] init];
    }
    
    // 在这个地方, 保证数据最新状态, 等于, 外界, 绝对可以获取到最新数据
    _musicMessageModel.musicM = self.musicMs[self.currentPlayIndex];
    
    // 设置最新的播放时间
    _musicMessageModel.costTime = self.player.currentTime;
    
    // 设置播放的总时间
    _musicMessageModel.totalTime = self.player.duration;
    
    // 设置当前是否正在播放
    _musicMessageModel.isPlaying = self.player.isPlaying;
    
    return _musicMessageModel;
}


#pragma mark - 懒加载
- (XMGAudioTool *)audioTool
{
    if (!_audioTool) {
        _audioTool = [[XMGAudioTool alloc] init];
    }
    return _audioTool;
}

-(void)setCurrentPlayIndex:(NSInteger)currentPlayIndex
{
    if (currentPlayIndex < 0)
    {
        currentPlayIndex = self.musicMs.count - 1;
    }
    if (currentPlayIndex >= self.musicMs.count) {
        currentPlayIndex = 0;
    }
    _currentPlayIndex = currentPlayIndex;
}


/**
 *  根据一个数据模型, 播放一首歌曲
 *
 *  @param musicM 数据模型
 */
- (void)playMusic:(XMGMusicModel *)musicM
{
    // 获取当前正字啊播放的播放器
    self.player = [self.audioTool playAudioWith:musicM.filename];
    
    // 计算当前播放的歌曲, 对应的索引
    self.currentPlayIndex = [[self.musicMs valueForKeyPath:@"filename"] indexOfObject:musicM.filename];
    
 
}

/**
 *  根据一个数据模型, 暂停一首歌曲
 *
 *  @param musicM 数据模型
 */
- (void)pauseMusic:(XMGMusicModel *)musicM
{
    [self.audioTool pauseAudioWith:musicM.filename];
}


/**
 *  根据一个数据模型, 停止一首歌曲
 *
 *  @param musicM 数据模型
 */
- (void)stopMusic:(XMGMusicModel *)musicM
{
    [self.audioTool stopAudioWith:musicM.filename];
}


/**
 *  继续播放当前歌曲
 */
- (void)playCurrentMusic
{
    // 获取当前正在播放的歌曲数据模型
    XMGMusicModel *musicM = self.musicMs[self.currentPlayIndex];
    [self playMusic:musicM];
}
/**
 *  停止播放当前正在播放的歌曲
 */
- (void)stopCurrentMusic
{
    // 获取当前正在播放的歌曲数据模型
    XMGMusicModel *musicM = self.musicMs[self.currentPlayIndex];
    
    // 停止歌曲
    [self stopMusic:musicM];
}

/**
 *  暂停播放当前正在播放的歌曲
 */
- (void)pauseCurrentMusic
{
    // 获取当前正在播放的歌曲数据模型
    XMGMusicModel *musicM = self.musicMs[self.currentPlayIndex];
    
    // 停止歌曲
    [self pauseMusic:musicM];
}

/**
 *  播放下一首歌曲
 */
- (void)nextMusic
{
    // 停止当前正在播放歌曲
    [self stopCurrentMusic];
    // 获取当前正在播放的歌曲数据模型
    self.currentPlayIndex++;
    XMGMusicModel *musicM = self.musicMs[self.currentPlayIndex];

    [self playMusic:musicM];
}

/**
 *  播放上一首歌曲
 */
- (void)preMusic
{
    // 停止当前正在播放歌曲
    [self stopCurrentMusic];
    // 获取当前正在播放的歌曲数据模型
    self.currentPlayIndex--;
    XMGMusicModel *musicM = self.musicMs[self.currentPlayIndex];
    
    [self playMusic:musicM];
}



- (void)setUpLockInfo
{

    // 0. 获取当前播放信息的具体信息
    XMGMusicMessageModel *musicMessageM = self.musicMessageModel;
    
    
    [XMGLrcTool getLrcDataWithLrcFileName:musicMessageM.musicM.lrcname resultBlock:^(NSArray<XMGLrcModel *> *lrcMs) {
            // 0.1 获取到当前播放的歌词
       XMGLrcModel *model = [XMGLrcTool getLrcModelWithTime:musicMessageM.costTime andLrcArray:lrcMs];
        
        
        
        // 1. 获取当前播放信息中心
        MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
        
        // 2. 设置数据
        
        // 创建专辑图片
        
        UIImage *image = [UIImage imageNamed:musicMessageM.musicM.icon];
        
        UIImage *resultImage = [XMGImageTool createImageWithText:model.lrcText inImage:image];
        
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:resultImage];
        
        
        NSDictionary *infoDic =
        @{
          MPMediaItemPropertyAlbumTitle : musicMessageM.musicM.name, // 歌曲名称
          MPMediaItemPropertyArtist : musicMessageM.musicM.singer, // 歌手
          MPMediaItemPropertyArtwork :  artwork, // 专辑图片
          MPMediaItemPropertyPlaybackDuration : @(musicMessageM.totalTime), // 歌曲总时长
          MPNowPlayingInfoPropertyElapsedPlaybackTime : @(musicMessageM.costTime)
          };
        
        center.nowPlayingInfo = infoDic;
        
   
    }];
    

   
    
    

    
    // 设置这个APP可以接收远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)seekToTime:(NSTimeInterval)time
{
    self.player.currentTime = time;
}



@end
