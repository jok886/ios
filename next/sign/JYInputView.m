//
//  JYInputView.m
//  Qiandaibao
//
//  Created by 阿图system on 17/3/31.
//  Copyright © 2017年 boshang. All rights reserved.
//

#import "JYInputView.h"
#import "JYInputModel.h"


@interface JYInputView()


@end

@implementation JYInputView

- (void)awakeFromNib {
    NSLog(@"%s",__func__);
    [super awakeFromNib];
    // Initialization code
    NSLog(@"awakeFromNib.frame = {x=%f,y=%f,w=%f,h=%f}",self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
    
}


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *nibs=[[NSBundle mainBundle]loadNibNamed:@"JYInputView" owner:nil options:nil];
        self=[nibs objectAtIndex:0];
        self.frame = frame;
        
        CGRect rect = _inputMoneyTextField.frame;
        rect.size.height += 40;
        [_inputMoneyTextField setFrame:rect];
        _inputMoneyTextField.textAlignment = NSTextAlignmentCenter;
        
        rect = _singlelimitLabel.frame;
        rect.size.width = kScreenWidth/2 - CGRectGetMinX(rect);
        [_singlelimitLabel setFrame:rect];
        
        rect = _drxeLabel.frame;
        rect.origin.x = kScreenWidth/2;
        [_drxeLabel setFrame:rect];
        
        rect = _dayLimitLabel.frame;
        rect.origin.x = CGRectGetMaxX(_drxeLabel.frame);
        rect.size.width = kScreenWidth - rect.origin.x;
        [_dayLimitLabel setFrame:rect];
        
        rect = _shisuanshouxufeiButton.frame;
        rect.origin.y += 20;
        UILabel *feiLvLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(rect) + 8, 50, 20)];
        feiLvLabel.text = @"费率:";
        feiLvLabel.textAlignment = NSTextAlignmentLeft;
        feiLvLabel.font = [UIFont systemFontOfSize:20.f];
        feiLvLabel.textColor = [UIColor blackColor];
        feiLvLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:feiLvLabel];
        
        UIImageView *actor = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-10-25, CGRectGetMaxY(rect), 38, 38)];
        actor.image = [UIImage imageNamed:@"nearby_all_arrow"];
        actor.backgroundColor = [UIColor clearColor];
        [self addSubview:actor];
        

        _personal_feiLvBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_personal_feiLvBtn setFrame:CGRectMake(10+50+10, CGRectGetMaxY(rect), kScreenWidth - 10-50-10-10-15, 38)];
        _personal_feiLvBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [_personal_feiLvBtn setBackgroundColor:[UIColor lightTextColor]];
        [_personal_feiLvBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_personal_feiLvBtn addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchUpInside];
        _personal_feiLvBtn.tag = 30;//选择费率
        _personal_feiLvBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self addSubview:_personal_feiLvBtn];
    }
    return self;
    
}

//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{
//    // 禁用粘贴功能
//    if (action == @selector(paste:))
//        return NO;
//    
//    // 禁用选择功能
//    if (action == @selector(select:))
//        return NO;
//    
//    // 禁用全选功能
//    if (action == @selector(selectAll:))
//        return NO;
//    
//    return [super canPerformAction:action withSender:sender];
//}

- (IBAction)buttonDown:(id)sender {
    UIButton * buttom = (UIButton *)sender;
    
    NSDictionary * dic = [[NSDictionary alloc]initWithObjectsAndKeys:
                          buttom,VIEW_EVENT_BUTTUN
                          ,nil];
    [self.viewDelegate zcm_view:self withEvents:dic];
}


-(void)zcm_configureViewWithModel:(id)model{

    NSLog(@"%s",__FUNCTION__);
    JYInputModel * tmpModel = (JYInputModel *)model;
    _singlelimitLabel.text = tmpModel.singlelimitStr;
    _dayLimitLabel.text = tmpModel.dayLimitStr;
    _feeMoneyLabel.text = tmpModel.feeStr;
}
@end
