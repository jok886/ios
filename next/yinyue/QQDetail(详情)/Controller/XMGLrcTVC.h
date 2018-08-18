//
//  XMGLrcTVC.h
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/5.
//  Copyright © 2015年 xiaomage. All rights reserved.

/**
 *  这个控制器, 单纯负责歌词的展示, 和根据行号, 滚动到对应的行, 非常纯洁!!
 */

#import <UIKit/UIKit.h>
#import "XMGLrcModel.h"

@interface XMGLrcTVC : UITableViewController

/**
 *  负责展示歌词的数据模型组成的数组
 */
@property (nonatomic, strong) NSArray <XMGLrcModel *>*lrcMs;

/**
 *  需要滚动的行号(具体计算, 由外界负责, 此处只负责重写SET方法, 滚动到对应的位置即可)
 */
@property (nonatomic, assign) NSInteger scrollRow;

@end
