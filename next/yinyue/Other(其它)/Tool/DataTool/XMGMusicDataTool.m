//
//  XMGMusicDataTool.m
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/4.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGMusicDataTool.h"
#import "MJExtension.h"

@implementation XMGMusicDataTool

+ (void)getMusicDataWithResultBlock:(void(^)(NSArray <XMGMusicModel *>*musicMs))block
{
    
    NSArray *musicMs =  [XMGMusicModel objectArrayWithFilename:@"Musics.plist"];
    
    block(musicMs);
    
}

@end
