//
//  BleService.h
//  Qiandaibao
//
//  Created by 阿图system on 17/4/6.
//  Copyright © 2017年 boshang. All rights reserved.
//

typedef NS_ENUM(NSInteger, CurrentConnectedDeviceType){
    CurrentConnectedDeviceNone = 0,//没绑定任何设备
    CurrentConnectedDeviceQDB = 1,//钱袋宝
    CurrentConnectedDeviceJHL,
    CurrentConnectedDeviceYYY,
};

#define DCQ_BLEDEVICE @"DCQ"
#define JHL_BLEDEVICE @"JHL"

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "DCSwiperAPI.h"
#import "JhlblueController.h"



@protocol ZcmBleProtocol <NSObject>


@optional

-(void)onZcmFindBlueDevice:(CBPeripheral *)cbPeripheral;

/**
 连接成功之后的回调
 
 @param cbPeripheral 蓝牙外设
 */
-(void)onZcmDidConnectBlueDevice;
/**
 *  失去连接到设备
 *
 *  @param cbPeripheral 蓝牙信息
 */
-(void)onZcmDisconnectBlueDevice:(CBPeripheral *)cbPeripheral;

/**
 *  获取设备信息的结果
 *
 *  @param terminalInfo 终端信息
 */
-(void)onZcmDidGetTerminalInfo:(DCTerminalInfo *)terminalInfo;

/**
 *  导入主密钥返回
 *
 *  @param isSuccess YES OR NO
 */
-(void)onZcmDidLoadMainKey:(BOOL)isSuccess;

/**
 *  签到回调（更新工作秘钥）
 *
 *  @param isSuccess  YES 成功
 */
-(void)onZcmDidUpdateKey:(BOOL)isSuccess;

/**
 *  识别到卡
 */
-(void)onZcmDetectCard;

/**
 *  刷卡、插卡、非接卡信息回调
 *
 *  @param cardMessage 卡信息
 */
-(void)onZcmDidReadCardInfo:(DCCardMessage *)cardMessage;

/**
 pin加密返回 p27
 
 @param encPINblock 密码密文
 */
-(void)onZcmEncryptPinBlock:(NSString *)encPINblock;

/**
 获取POS输入密码的回调函数  p84
 
 @param pinBlock 密码密文
 */
-(void)onZcmReturnPinBlock:(NSString *)pinBlock;

/**
 *  设备按取消键返回
 */
-(void)onZcmPressCancleKey;

/**
 *   mac计算结果
 *
 *  @param strmac mac
 */
-(void)onZcmDidGetMac:(NSString *)strmac;

/**
 *  异常错误
 *
 *  @param errorCode    错误码
 *  @param errorMessage 错误信息
 */
- (void)onZcmError:(NSInteger)errorCode andMessage:(NSString *)errorMessage;

/**
 *  取消/复位回调
 */
-(void)onZcmDidCancelCard;

@end




@interface BleService : NSObject
@property(nullable, nonatomic, weak) id<ZcmBleProtocol> delegate;
@property(nonatomic,strong)NSString * bandDeviceName;
+(BleService *)shareInstance;




-(void)ZcmConnectPos;

-(void)ZcmDisConnect;



/*
 
 -当前链接的设备型号
 返回类型：各个厂商的pos
 
 */
-(CurrentConnectedDeviceType)ZcmGetCurrentConnectedPos;

-(void)bandDeviceName:(NSString *)deviceName;


/*
 主秘钥更新
 */
-(void)lyUpdateMainkey:(NSData *)mainKey;

/*
 工作秘钥更新
 */
-(void)lyUpdateWorkingkey:(NSData *)workKey;

@end




