//
//  XMGLrcTVC.m
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/5.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGLrcTVC.h"

@interface XMGLrcTVC ()

@end

@implementation XMGLrcTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpInit];
}

/**
 *  初始化方法(自定义)
 */
- (void)setUpInit
{
    self.view.backgroundColor =  [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
}

/**
 *  重写行号的set方法, 这样可以在此处做一些滚动处理
 */
-(void)setScrollRow:(NSInteger)scrollRow
{
    // 这里之所以过滤, 是防止外界过于频繁的调用滚动到同一行, 没有必要, 而且滚动会出现问题
    if (scrollRow == _scrollRow) {
        return;
    }
    _scrollRow = scrollRow;
    
    // 把刷新操作, 放到滚动前面
    [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
    
    // 滚动到对应的行
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:scrollRow inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
  
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // 这句代码的设置, 主要是为了让第一行歌词, 和最后一行歌词, 可以显示到tableView中间
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.bounds.size.height * 0.5, 0, self.tableView.bounds.size.height * 0.5, 0);
}


/**
 *  重写数据源的set方法, 在此方法中刷新表格
 *
 *  因为一旦外界调用了这个方法, 就代表外界想要修改数据源, 一旦数据源被修改了, 那就要求这个控制器的视图也跟着更新(被称作"级联方法")
 */
-(void)setLrcMs:(NSArray<XMGLrcModel *> *)lrcMs
{
    _lrcMs = lrcMs;
    [self.tableView reloadData];
}


#pragma mark - 表格的数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.lrcMs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"LRC";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        // 设置歌词显示的样式
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 可以针对于被滚动的行, 做一些特殊效果
    if (indexPath.row == self.scrollRow)
    {
        cell.textLabel.textColor = [UIColor orangeColor];
    }else
    {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    // 取出歌词数据模型
    XMGLrcModel *lrcM = self.lrcMs[indexPath.row];
    
    // 给歌词赋值
    cell.textLabel.text = lrcM.lrcText;
    
    
    return cell;
}



@end
