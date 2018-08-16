//
//  QdbSignViewController.h
//  zcm
//
//  Created by zcm on 15/7/27.
//  Copyright (c) 2015年 zcm. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 
    持卡人签名页面
 
 */
@interface QdbSignViewController : UIViewController
{
    NSString* strCardNumber_; // 卡号
    NSString* strTrack2_; // 磁道二
    NSString* strTrack3_; // 磁道三
    BOOL isIccCard_;
    NSString* strPin_;
    NSData* signData_;
    NSString* strBit55_;
    NSString* strAmount_;
    NSString* strBit23_;//卡序列号
    NSString* strBit14_;//有效期
    NSString* strOrderNum;
    NSString* strPhoneNum;
    NSString* strRateId;
    NSData  * macValueData_;//mac
    
    
    
    float   longitude_;//经度
    float   latitude_;//纬度
}

@property(nonatomic, copy) NSString* strCardNumber_;
@property(nonatomic, copy) NSString* strTrack2_;
@property(nonatomic, copy) NSString* strTrack3_;
@property(nonatomic, copy) NSString* strPin_;
@property(nonatomic, copy) NSData* signData_;
@property(nonatomic, copy) NSString* strBit55_;
@property(nonatomic, copy) NSString* strAmount_;
@property(nonatomic, copy) NSString* strBit23_;
@property(nonatomic, copy) NSString* strBit14_;
@property(nonatomic) BOOL isIccCard_;
@property(nonatomic, copy) NSString* strOrderNum;
@property(nonatomic, copy) NSString* strPhoneNum;
@property(nonatomic, copy) NSString* strRateId;
@property (nonatomic,copy) NSData  * macValueData_;
@property(nonatomic,assign)float   longitude_;//经度
@property (nonatomic,assign)float   latitude_;//纬度
@property (nonatomic,assign) BOOL   isMerchant;//是否是小薇商户

@property (nonatomic,strong) NSString *tradeCharge;//交易手续费

@property (nonatomic,strong) NSString *audit;//实名认证是否通过 0-失败，1-成功，2-不需要认证
@property (nonatomic,strong) NSString *OCR;//识别图片中银行卡号 0-不能识别，1=能识别

@end
