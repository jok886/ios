//
//  SecondVC.m
//  换肤-1
//
//  Created by 王顺子 on 15/9/21.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "SecondVC.h"
#import "SkinTool.h"

@interface SecondVC ()

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation SecondVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpImage];
}


- (void)setUpImage
{
    self.backImageView.image = [SkinTool imageNamed:@"back"];
    [self.button setBackgroundImage:[SkinTool imageNamed:@"button_back"] forState:UIControlStateNormal];

}


@end
