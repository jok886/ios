//
//  ViewController.m
//  二维码扫描OC
//
//  Created by 王顺子 on 16/3/11.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "ViewController.h"
#import "XMGQRCodeTool.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *scanBackView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toBottom;


@end

@implementation ViewController


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self beginScanAnimation];
    [self beginScan];
}




// 开始扫描
- (void)beginScan
{

    [XMGQRCodeTool sharedXMGQRCodeTool].isDrawQRCodeRect = YES;
    [[XMGQRCodeTool sharedXMGQRCodeTool] setInsteretRect:self.scanBackView.frame];
    [[XMGQRCodeTool sharedXMGQRCodeTool] beginScanInView:self.view result:^(NSArray<NSString *> *resultStrs) {
        NSLog(@"%@", resultStrs);
        [[XMGQRCodeTool sharedXMGQRCodeTool] stopScan];

    }];



}



// 开始扫描动画
- (void)beginScanAnimation
{
    self.toBottom.constant = self.scanBackView.frame.size.height;
    [self.view layoutIfNeeded];


    [UIView animateWithDuration:2 animations:^{
        [UIView setAnimationRepeatCount:CGFLOAT_MAX];
        self.toBottom.constant = - self.scanBackView.frame.size.height;
        [self.view layoutIfNeeded];

    }];
    
    
}


@end

