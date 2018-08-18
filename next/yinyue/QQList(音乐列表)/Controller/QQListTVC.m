//
//  QQListTVC.m
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/4.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "QQListTVC.h"
#import "XMGMusicDataTool.h"
#import "XMGMusicListCell.h"
#import "XMGMusicOperationTool.h"

@interface QQListTVC ()

/** 音乐列表数据源 */
@property (nonatomic ,strong) NSArray <XMGMusicModel *>*musicMs;

@end

@implementation QQListTVC

// 重写数据源set方法, 可以在此方法中刷新数据
-(void)setMusicMs:(NSArray<XMGMusicModel *> *)musicMs
{
    _musicMs = musicMs;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化方法
    [self setUpInit];
 
    // 加载数据源
    [XMGMusicDataTool getMusicDataWithResultBlock:^(NSArray<XMGMusicModel *> *musicMs) {
        self.musicMs = musicMs;
        // 把需要播放的数据模型数组, 传递给专门负责操作播放业务逻辑的工具类, 让它负责上一首, 下一首等业务逻辑操作
        [XMGMusicOperationTool sharedXMGMusicOperationTool].musicMs = musicMs;
    }];

}

/**
 *  一般把初始化方法, 单独抽成一个方法, 省的写到viewdidload中, 显得比较混乱
 */
- (void)setUpInit
{
    self.title = @"QQ音乐列表";
    self.tableView.rowHeight = 80;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 设置导航栏显示
    self.navigationController.navigationBarHidden = NO;
}


#pragma mark - 数据源方法
// 返回多少行数据
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.musicMs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 快速创建cell
    XMGMusicListCell *cell = [XMGMusicListCell cellWithTableView:tableView];
    
    // 赋值
    XMGMusicModel *musicM = self.musicMs[indexPath.row];
    cell.musicM = musicM;
    
    
    // 可以在此处, 做一些比较牛逼的动画效果
    [cell.layer removeAnimationForKey:@"donghua"];
    CAKeyframeAnimation *annimation = [[CAKeyframeAnimation alloc] init];
    annimation.keyPath = @"transform.rotation.y";
    annimation.values = @[@(1), @(0), @(-1), @(0)];
    annimation.duration = 0.5;
    [cell.layer addAnimation:annimation forKey:@"donghua"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMGMusicModel *musicM = self.musicMs[indexPath.row];

    // 播放对应歌曲
    NSLog(@"播放歌曲--%@", musicM.name);
    // 播放之前, 需要停止, 上次正在播放的歌曲
    [[XMGMusicOperationTool sharedXMGMusicOperationTool] stopCurrentMusic];
    
    [[XMGMusicOperationTool sharedXMGMusicOperationTool] playMusic:musicM];
    
    // 跳转到详情界面
    [self performSegueWithIdentifier:@"list2Detail" sender:nil];
}


@end
