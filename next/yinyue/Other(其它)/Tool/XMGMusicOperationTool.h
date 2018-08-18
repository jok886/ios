//
//  XMGMusicOperationTool.h
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/4.
//  Copyright © 2015年 xiaomage. All rights reserved.

/**
 *  这个类, 负责播放的业务逻辑, 比如上一首, 下一首, 顺序播放
 */

#import <Foundation/Foundation.h>
#import "XMGMusicModel.h"
#import "Singleton.h"


@interface XMGMusicMessageModel : NSObject

/** 歌曲信息模型 */
@property (nonatomic ,strong) XMGMusicModel  *musicM;

/** 当前歌曲已经播放的时间 */
@property(nonatomic, assign) NSTimeInterval costTime;

/** 歌曲总时长 */
@property(nonatomic, assign) NSTimeInterval totalTime;

/** 当前是否有歌曲正在播放 */
@property(nonatomic, assign) BOOL isPlaying;


@end



@interface XMGMusicOperationTool : NSObject
single_interface(XMGMusicOperationTool)

@property (nonatomic, strong, readonly) XMGMusicMessageModel *musicMessageModel;


/** 需要播放的音乐数据模型数组 */
@property (nonatomic ,strong) NSArray <XMGMusicModel *> *musicMs;

/**
 *  根据一个数据模型, 播放一首歌曲
 *
 *  @param musicM 数据模型
 */
- (void)playMusic:(XMGMusicModel *)musicM;

/**
 *  根据一个数据模型, 暂停一首歌曲
 *
 *  @param musicM 数据模型
 */
- (void)pauseMusic:(XMGMusicModel *)musicM;

/**
 *  根据一个数据模型, 停止一首歌曲
 *
 *  @param musicM 数据模型
 */
- (void)stopMusic:(XMGMusicModel *)musicM;



/**
 *  继续播放当前歌曲
 */
- (void)playCurrentMusic;
/**
 *  停止播放当前正在播放的歌曲
 */
- (void)stopCurrentMusic;
/**
 *  暂停播放当前正在播放的歌曲
 */
- (void)pauseCurrentMusic;



/**
 *  播放下一首歌曲
 */
- (void)nextMusic;

/**
 *  播放上一首歌曲
 */
- (void)preMusic;


/**
 *  设置锁屏信息
 */
- (void)setUpLockInfo;


/**
 *  调整当前歌曲的播放进度
 *
 *  @param time 时间
 */
- (void)seekToTime:(NSTimeInterval)time;

@end
