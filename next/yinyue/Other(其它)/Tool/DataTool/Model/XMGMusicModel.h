//
//  XMGMusicModel.h
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/4.
//  Copyright © 2015年 xiaomage. All rights reserved.
//  音乐信息的数据模型

#import <Foundation/Foundation.h>

@interface XMGMusicModel : NSObject

/** 歌曲名称 */
@property (nonatomic ,copy) NSString *name;

/** 歌曲文件名称 */
@property (nonatomic ,copy) NSString *filename;

/** 歌词文件名称 */
@property (nonatomic ,copy) NSString *lrcname;

/** 歌手名称 */
@property (nonatomic ,copy) NSString *singer;

/**< 歌手头像 */
@property (nonatomic ,copy) NSString *singerIcon;

/**< 歌曲专辑图片 */
@property (nonatomic ,copy) NSString *icon;


@end











