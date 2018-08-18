//
//  XMGMusicListCell.h
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/4.
//  Copyright © 2015年 xiaomage. All rights reserved.
/**
 *  负责展示音乐列表的cell
 *  接收音乐数据模型, 用来重置cell,内部数据
 */

#import <UIKit/UIKit.h>
#import "XMGMusicModel.h"
@interface XMGMusicListCell : UITableViewCell

+ (XMGMusicListCell *)cellWithTableView:(UITableView *)tableView;

/** 音乐数据模型 */
@property (nonatomic ,strong) XMGMusicModel  *musicM;

@end
