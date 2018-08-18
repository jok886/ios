//
//  XMGAudioTool.h
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/4.
//  Copyright © 2015年 xiaomage. All rights reserved.
/**
 *  此工具类, 只负责最最纯洁的单首歌曲的播放和暂停和停止操作, 具体不负责播放的业务逻辑(上一首, 下一首)
 *
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface XMGAudioTool : NSObject

/**
 *  播放歌曲(之所以把播放器给返回出去, 是为了方便外面通过这个播放器, 获取数据!)
 */
- (AVAudioPlayer *)playAudioWith:(NSString *)audioName;

/**
*  暂停歌曲
*/
- (void)pauseAudioWith:(NSString *)audioName;

/**
*  停止歌曲
*/
- (void)stopAudioWith:(NSString *)audioName;

@end
