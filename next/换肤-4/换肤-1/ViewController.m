//
//  ViewController.m
//  换肤-1
//
//  Created by 王顺子 on 15/9/21.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "ViewController.h"
#import "SkinTool.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@property (weak, nonatomic) IBOutlet UIButton *button;


@property (weak, nonatomic) IBOutlet UILabel *textLabel;



@end

@implementation ViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpImage];

}


// 切换中秋节主题
- (IBAction)switchZhongQiu {
    [SkinTool setSkinWithName:kSkinTypeZQ];
    [self setUpImage];

}

// 切换国庆节主题
- (IBAction)switchGuoQing {
     [SkinTool setSkinWithName:kSkinTypeGQ];
    [self setUpImage];
}

// 切换春节主题
- (IBAction)switchChunJie {
    [SkinTool setSkinWithName:kSkinTypeCJ];
    [self setUpImage];
}


- (void)setUpImage
{
    self.backImageView.image = [SkinTool imageNamed:@"back"];
    [self.button setBackgroundImage:[SkinTool imageNamed:@"button_back"] forState:UIControlStateNormal];
    self.textLabel.textColor = [SkinTool skinColorWithType:kSkinColorTypeLabel];

}




@end
