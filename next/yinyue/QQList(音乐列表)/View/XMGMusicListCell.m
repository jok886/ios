//
//  XMGMusicListCell.m
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/4.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGMusicListCell.h"

@interface XMGMusicListCell()

/**
 *  歌手图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *singerIMV;
/**
 *  歌曲名称
 */
@property (weak, nonatomic) IBOutlet UILabel *songNameL;
/**
 *  歌手名称
 */
@property (weak, nonatomic) IBOutlet UILabel *singerNameL;

@end


@implementation XMGMusicListCell
/**
 *  根据tableview, 快速创建cell的方法
 *
 *  @param tableView
 *
 *  @return 自定义cell
 */
+ (XMGMusicListCell *)cellWithTableView:(UITableView *)tableView
{
    
    static NSString *cellID = @"musicID";
    // 从缓存池里面取出cell
    XMGMusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        // 千万千万不要忘记, 在xib文件里面把重复利用标示给设置上
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
    }
    return cell;
    
}

/**
 *  重写模型的set方法, 可以在此方法中, 给cell里面的UI赋值
 *
 *  @param musicM 音乐数据模型
 */
-(void)setMusicM:(XMGMusicModel *)musicM
{
    _musicM = musicM;
    self.singerIMV.image = [UIImage imageNamed:musicM.singerIcon];
    self.songNameL.text = musicM.name;
    self.singerNameL.text = musicM.singer;
}

/**
 *  从xib<文件加载cell, 之后
 */
- (void)awakeFromNib {
    
    self.singerIMV.layer.cornerRadius = self.singerIMV.bounds.size.width * 0.5;
    self.singerIMV.layer.masksToBounds = YES;
    
}



@end
