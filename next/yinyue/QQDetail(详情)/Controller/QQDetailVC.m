//
//  QQDetailVC.m
//  01-QQ音乐
//
//  Created by xiaomage on 15/11/4.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "QQDetailVC.h"
#import "XMGMusicOperationTool.h"
#import "XMGTimeTool.h"
#import "XMGLrcTVC.h"
#import "XMGLrcTool.h"
#import "XMGLrcLabel.h"
#import "CALayer+PauseAimate.h"

@interface QQDetailVC ()<UIScrollViewDelegate>
/**
 *  歌词背景滚动的视图
 */
@property (weak, nonatomic) IBOutlet UIScrollView *lrcBackSView;
/**
 *  歌词显示视图
 */
@property (nonatomic, weak) XMGLrcTVC *lrcTVC;

/**
 *  歌曲专辑图片(1次)
 */
@property (weak, nonatomic) IBOutlet UIImageView *singIconView;
/**
 *  大的背景图片, 显示专辑图片(1)
 */
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
/**
 *  歌曲的总时长(1次)
 */
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
/**
 *  歌曲名称(1次)
 */
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
/**
 *  歌手名称(1次)
 */
@property (weak, nonatomic) IBOutlet UILabel *singerNameLabel;

/**
 *  歌曲播放的进度条(多次)
 */
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
/**
 *  歌曲已经播放的时间(多次)
 */
@property (weak, nonatomic) IBOutlet UILabel *costTimeLabel;
/**
 *  歌词label(多次)
 */
@property (weak, nonatomic) IBOutlet XMGLrcLabel *lrcLabel;

/** 播放或者暂停按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

/** 更新需要多次更新的信息 */
@property (nonatomic ,strong) NSTimer  *updateTime;

/** 定时器(刷新歌词) */
@property (nonatomic ,strong) CADisplayLink  *link;

@end

@implementation QQDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpInit];
}

#pragma mark - 业务逻辑操作

/**
 *  播放或者暂停
 *
 *  @param sender 按钮
 */
- (IBAction)playOrPause:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        // 播放当前音乐, 此方法, 被抽取成单独的一个工具类进行管理, 在控制器内部, 只负责业务逻辑的调度, 不负责具体实现
        [[XMGMusicOperationTool sharedXMGMusicOperationTool] playCurrentMusic];
        
        // 开始旋转
        [self resumeRotation];
        
    }else
    {
        // 暂停播放当前音乐,此方法, 被抽取成单独的一个工具类进行管理, 在控制器内部, 只负责业务逻辑的调度, 不负责具体实现
        [[XMGMusicOperationTool sharedXMGMusicOperationTool] pauseCurrentMusic];
        
        // 暂停旋转
        [self pauseRotation];
        
    }
}

/**
 *  上一首
 *
 */
- (IBAction)preMusci:(UIButton *)sender
{
    [[XMGMusicOperationTool sharedXMGMusicOperationTool] preMusic];
    // 更新当前界面信息
    [self updateOnce];
}

/**
 *  下一首
 *
 */
- (IBAction)nextMusic:(UIButton *)sender
{
    [[XMGMusicOperationTool sharedXMGMusicOperationTool] nextMusic];
    // 更新当前界面信息
    [self updateOnce];
}
/**
 *  关闭当前控制器
 */
- (IBAction)close
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  当进度条,被点击下去的事件
 *
 *  @param  停止timer更新
 */
- (IBAction)touchDown:(UISlider *)sender
{
    [self.updateTime invalidate];
    self.updateTime = nil;
}
/**
 *  当进度条, 点击上来的事件
 */
- (IBAction)touchUp:(UISlider *)sender
{
    
    // 根据当前进度条的值, 与歌曲的总时间相乘, 可以获取到, 当前应该播放的时间, 然后设置播放进度即可(注意: 这里面的歌曲播放时长 由工具类同一提供!!)
    NSTimeInterval currentTime = [XMGMusicOperationTool sharedXMGMusicOperationTool].musicMessageModel.totalTime * sender.value;
    
    // 调整当前的播放进度
    [[XMGMusicOperationTool sharedXMGMusicOperationTool] seekToTime:currentTime];
    
    // 重新开始监听当前的播放进度
    [self updateTime];
    
}
/**
 *  进度条值改变时调用
 */
- (IBAction)valueChange:(UISlider *)sender {

    // 获取到当前拖动的位置, 应该对应的歌曲播放时长
     NSTimeInterval currentTime = [XMGMusicOperationTool sharedXMGMusicOperationTool].musicMessageModel.totalTime * sender.value;
    // 设置已播放时长的标签数据
    self.costTimeLabel.text = [XMGTimeTool getFormatTimeWithTimeInterval:currentTime];
    
}

/**
 *  这个方法, 主要是实现, 当用户点击滑动条时, 也可以直接播放到对应的进度
 *  因为UISlider控件中, 本身没有点击的这个方法, 所以只能借助手势
 *  @param sender 手势
 */
- (IBAction)sliderTap:(UITapGestureRecognizer *)sender
{
    // 1. 获取到手势在进度条上的位置
    CGPoint point = [sender locationInView:self.progressSlider];
    
    // 2. 当前的位置x, 与进度条的总长度构成的一个比例, 就可以当做当前进度条的值
    float scale = point.x / self.progressSlider.frame.size.width;
    
    // 3. 设置进度条的值
    self.progressSlider.value = scale;
    
    // 4. 计算当前进度条的值, 对应的播放时长
     NSTimeInterval currentTime = [XMGMusicOperationTool sharedXMGMusicOperationTool].musicMessageModel.totalTime * scale;
    
    // 调整当前的播放进度
    [[XMGMusicOperationTool sharedXMGMusicOperationTool] seekToTime:currentTime];
}



#pragma mark - 更新界面播放信息

/**
 *  当切换歌曲时, 只需要更新一次的情况
 */
- (void)updateOnce
{
    // 从工具类中, 统一获取需要展示的数据信息模型
    XMGMusicMessageModel *messageM = [XMGMusicOperationTool sharedXMGMusicOperationTool].musicMessageModel;
    
    
    // 设置歌曲播放信息
    self.singIconView.image = [UIImage imageNamed:messageM.musicM.icon];
    self.backImageView.image = [UIImage imageNamed:messageM.musicM.icon];;
    self.totalTimeLabel.text = [XMGTimeTool getFormatTimeWithTimeInterval:messageM.totalTime];
    self.songNameLabel.text = messageM.musicM.name;
    self.singerNameLabel.text = messageM.musicM.singer;
    
    // 切换歌词数据源
    [XMGLrcTool getLrcDataWithLrcFileName:messageM.musicM.lrcname resultBlock:^(NSArray<XMGLrcModel *> *lrcMs) {
        // 给负责展示歌词的控制器, 赋值, 数据源,
        self.lrcTVC.lrcMs = lrcMs;
    }];
    
    // 旋转图片
     [self beginRotation];
    
    // 根据当前的播放状态, 来确定是否应该暂停图片旋转动画
    if([XMGMusicOperationTool sharedXMGMusicOperationTool].musicMessageModel.isPlaying)
    {
        // 继续旋转
        [self resumeRotation];
    }
    else
    {
        // 暂停旋转
        [self pauseRotation];
    }
    
    
}
/**
 *  当切换歌曲时, 需要更新多次的情况
 */
- (void)updateTimes
{
    // 先从工具类同一提供的数据属性中, 获取最新的数据, 在此处, 只负责读取, 显示; 不需要关心, 数据到底是怎样来的, 那是工具类的事情
     XMGMusicMessageModel *messageM = [XMGMusicOperationTool sharedXMGMusicOperationTool].musicMessageModel;
    
    self.progressSlider.value = messageM.costTime / messageM.totalTime;
    self.costTimeLabel.text = [XMGTimeTool getFormatTimeWithTimeInterval:messageM.costTime];
    
    // 注意: 把播放按钮状态, 放在这个位置更新, 可以保证, 只要我们操控的是播放器状态, 就可以间接的取出对应的状态, 设置到播放/暂停按钮上面, 防止, 出现错误状态的情况;
    self.playBtn.selected = messageM.isPlaying;
}


/**
 * 刷新歌词
 */
- (void)updateLrc
{

    // 1. 获取当前播放歌曲的信息数据模型
     XMGMusicMessageModel *messageM = [XMGMusicOperationTool sharedXMGMusicOperationTool].musicMessageModel;
    
    // 2. 计算当前歌曲播放时间, 对应的歌词行号(因为这个功能比较常用, 建议抽取出一个专门的工具类)
    NSInteger row = [XMGLrcTool getRowWithTime:messageM.costTime andLrcArray:self.lrcTVC.lrcMs];
    
    // 3. 将需要滚动的行号, 直接交给歌词控制器进行处理, 负责管理歌词的控制器, 负责滚动
    self.lrcTVC.scrollRow = row;
    
    // 4. 计算当前播放器对应的歌词, 给歌词label赋值
    XMGLrcModel *lrcM = [XMGLrcTool getLrcModelWithTime:messageM.costTime  andLrcArray:self.lrcTVC.lrcMs];
    self.lrcLabel.text = lrcM.lrcText;
    
    // 5. 计算并显示每一句歌词的播放进度(具体实现方案, 是借助自定义UILabel, 然后重写drawRect:方法)
    self.lrcLabel.progress = (messageM.costTime - lrcM.beginTime) / (lrcM.endTime - lrcM.beginTime);
    
    // 刷新锁屏信息(之所以在此处刷新锁屏信息, 是因为, 锁屏界面上面, 需要展示歌词到图片上, 需要不断刷新)
    [[XMGMusicOperationTool sharedXMGMusicOperationTool] setUpLockInfo];
}


#pragma mark - 在此处, 接收远程事件, 并且处理
/**
 *  当APP接收到远程时间时(耳机操控, 或者锁屏界面的操控, 都属于远程时间), 会把时间传递到, 需要处理的控制器, 只要在控制器方法中,实现这个方法, 就可以接收到对应的事件, 这个事件, 是继承自UIResponder,得到的方法
 *
 *  @param event 事件类型(为了区分用户点击的是播放/暂停/下一首/上一首事件, 我们需要使用到里面的subType子事件类型, 具体参考如下)
 */
-(void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        {
            NSLog(@"播放");
            [[XMGMusicOperationTool sharedXMGMusicOperationTool] playCurrentMusic];
             break;
        }
        case UIEventSubtypeRemoteControlPause:
        {
            NSLog(@"暂停");
            [[XMGMusicOperationTool sharedXMGMusicOperationTool] pauseCurrentMusic];
            break;
        }
        case UIEventSubtypeRemoteControlNextTrack:
        {
            NSLog(@"下一首");
            [[XMGMusicOperationTool sharedXMGMusicOperationTool] nextMusic];
            break;
        }
        case UIEventSubtypeRemoteControlPreviousTrack:
        {
            NSLog(@"上一首");
            [[XMGMusicOperationTool sharedXMGMusicOperationTool] preMusic];
            break;
        }
           
            
        default:
            break;
    }
    // 以上操作, 只能控制音乐的播放逻辑, 而锁屏界面的刷新, 是由一个定时器不断刷新的, 所以, 会自动更新到最新数据, 但是我们的专辑图片,和歌曲名称等信息, 只能是靠我们手动更新, 才会更新到对的数据(当前, 你也可以把单次刷新的内容放到多次刷新的方法里面执行, 但是这样, 会增加负担)
    [self updateOnce];
}


#pragma mark - 私有方法, 初始化设置, 还有一些动画效果

/**
 *  开始旋转
 */
- (void)beginRotation
{
    // 通过核心动画, 来控制专辑图片的旋转, 从而标示当前歌曲的播放状态
    [self.singIconView.layer removeAnimationForKey:@"rotation"];
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.keyPath = @"transform.rotation.z";
    animation.fromValue = @(0);
    animation.toValue = @(M_PI * 2);
    animation.repeatCount = NSIntegerMax;
    animation.duration = 30;
    [self.singIconView.layer addAnimation:animation forKey:@"rotation"];
    
}

/**
 *  暂停旋转(此功能是通过一个CALayer分类实现, 没有必要掌握, 会用即可)
 */
- (void)pauseRotation
{
    [self.singIconView.layer pauseAnimate];
}

/**
 *  继续旋转(此功能是通过一个CALayer分类实现, 没有必要掌握, 会用即可)
 */
- (void)resumeRotation
{
    [self.singIconView.layer resumeAnimate];
}

/**
 *  因为歌词刷新, 是频率非常高的一个需求, 所以, 在此处我们的实现方案是采用一个CADisplayLink 来实现(频率跟我们屏幕刷新频率一致, 非常高)
 *
 */
- (CADisplayLink *)link
{
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
        [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _link;
}

/**
 *  懒加载专门负责管理歌词的控制器
 *
 *  因为歌词需要通过一个tableView实现,如果所有的东西都写到这个控制器里面, 需要设置数据源等等, 而且还有做滚动动画, 这样整个控制器会非常混乱; 所以只需要坚持一个原则"分担功能实现, 保证此控制器中的大逻辑清晰!"
 */
-(XMGLrcTVC *)lrcTVC
{
    if (!_lrcTVC) {
        XMGLrcTVC *lrcTVC = [[XMGLrcTVC alloc] init];
        [self addChildViewController:lrcTVC];
        _lrcTVC = lrcTVC;
    }
    return _lrcTVC;
}

/**
 *  负责更新播放进度的timer(因为歌曲播放进度不需要刷新过高, 保证一秒刷新一次即可, 所以使用NSTimer这种实现方案, 而不使用CADisplayLink)
 */
- (NSTimer *)updateTime
{
    if (!_updateTime) {
        _updateTime = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimes) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_updateTime forMode:NSRunLoopCommonModes];
    }
    return _updateTime;
}

/**
 *  为了防止没必要的刷新,我们可以在本控制器不显示的时候停止刷新, 显示时再刷新
 */
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 因为timer 和 CADisplayLink都是通过懒加载创建的, 所以, 直接调用get方法, 就可以创建对应的timer 或者 CADisplayLink对象, 就会间接启动更新事件
    [self updateTime];
    [self link];
    [self updateOnce];
}

/**
 *  同上, 只需要把对应的timer或者 CADisplayLink 销毁, 就可以停止刷新事件
 */
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.updateTime invalidate];
    self.updateTime = nil;
    [self.link invalidate];
    self.link = nil;
}

/**
 *  像一些控制器的初始化设置, 最好封装成一个方法, 保持控制器生命周期方法的整洁, 逻辑条理清晰;
 */
- (void)setUpInit
{
    // 隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
    
    // 创建歌词视图
    [self.lrcBackSView addSubview:self.lrcTVC.tableView];
    // 设置分页
    self.lrcBackSView.pagingEnabled = YES;
    // 隐藏滚动条
    self.lrcBackSView.showsHorizontalScrollIndicator = NO;
    // 设置代理
    self.lrcBackSView.delegate = self;
    
    // 设置进度条图片
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    

}

/**
 *  因为我们使用的是布局约束, 默认的界面大小事600 * 600, 所以, 不要直接在viewDidLoad方法中, 获取视图控件的大小, 那时候还没有布局完成, 所以获取到的数据不准确, 这个方法, 是系统自带的方法, 会在布局结束之后调用, 所以在此处获取到的控制frame, 都是准确的值
 */
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.lrcBackSView.contentSize = CGSizeMake(self.lrcBackSView.bounds.size.width * 2, 0);
    self.lrcTVC.tableView.frame = CGRectMake(self.lrcBackSView.bounds.size.width, 0, self.lrcBackSView.bounds.size.width, self.lrcBackSView.bounds.size.height);
    
    // 设置圆形
    self.singIconView.layer.cornerRadius = self.singIconView.bounds.size.width * 0.5;
    self.singIconView.layer.masksToBounds = YES;
}

/**
 *  设置当前状态栏的样式
 */
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIScrollViewDelegate

/**
 *  通过监听歌词背景UIScrollView视图的滚动, 可以做一些动画效果
 */
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float scale = 1- scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    // 设置控件透明度
    self.singIconView.alpha = scale;
    self.lrcLabel.alpha = scale;
}


@end
