//
//  JYInputView.h
//  Qiandaibao
//
//  Created by 阿图system on 17/3/31.
//  Copyright © 2017年 boshang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYInputView : UIView
@property (weak, nonatomic) IBOutlet UILabel *dbxyLabel;
@property (weak, nonatomic) IBOutlet UILabel *singlelimitLabel;//限额金额
@property (weak, nonatomic) IBOutlet UILabel *drxeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLimitLabel;//限额金额

@property (weak, nonatomic) IBOutlet UITextField *inputMoneyTextField;
@property (weak, nonatomic) IBOutlet UIButton *shisuanshouxufeiButton;//试算手续费
@property (weak, nonatomic) IBOutlet UILabel *feeMoneyLabel;
@property(nonatomic ,strong)UIButton * personal_feiLvBtn;

- (IBAction)buttonDown:(id)sender;

@end
