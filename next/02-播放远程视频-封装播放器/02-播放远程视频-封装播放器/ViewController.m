//
//  ViewController.m
//  02-播放远程视频-封装播放器
//
//  Created by 王顺子 on 15/10/10.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "ViewController.h"
#import "XMGPlayerView.h"

@interface ViewController ()

@property (nonatomic, weak) XMGPlayerView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    XMGPlayerView *playerView = [XMGPlayerView playerView];
    [self.view addSubview:playerView];
    self.playerView = playerView;


    NSURL *url = [NSURL URLWithString:@"http://v1.mukewang.com/57de8272-38a2-4cae-b734-ac55ab528aa8/L.mp4"];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    self.playerView.playerItem = item;
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.playerView.frame = self.view.bounds;
}

//
//-(UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscapeLeft;
//}

@end
