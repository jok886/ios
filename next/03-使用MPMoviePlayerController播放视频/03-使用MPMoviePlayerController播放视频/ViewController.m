//
//  ViewController.m
//  03-使用MPMoviePlayerController播放视频
//
//  Created by 王顺子 on 15/10/10.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>


@interface ViewController ()

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;


@end

@implementation ViewController


-(MPMoviePlayerController *)moviePlayer
{
    if (!_moviePlayer) {
        NSURL *remoteURL = [NSURL URLWithString:@"http://v1.mukewang.com/57de8272-38a2-4cae-b734-ac55ab528aa8/L.mp4"];
        
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:remoteURL];
    }
    return _moviePlayer;
}





- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置播放视图的frame
    self.moviePlayer.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 9 / 16);
    // 设置播放视图控制样式
    self.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    // 添加播放视图到要显示的视图
    [self.view addSubview:self.moviePlayer.view];


}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 开始播放(此控制器不是视图控制器, 不能弹出)
//    [self presentViewController:self.moviePlayer animated:YES completion:^{
        [self.moviePlayer play];
//    }];
}


@end
