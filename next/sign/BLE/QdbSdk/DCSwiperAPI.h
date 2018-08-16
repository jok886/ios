//
//  DCSwiperAPI.h
//  DCSwiperAPI
//
//  Created by Bingo on 16/6/17.
//  Copyright © 2016年 Bingo. All rights reserved.
//  P27/P84通用   天下支付

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define  ERROR_FAIL_CHECKCODE   0x0000   //校验位失败
#define  ERROR_FAIL_READCARD    0xD121   //读卡失败
#define  ERROR_FAIL_TIMEOUT1    0x3037   //设备通信超时
#define  ERROR_FAIL_TIMEOUT2    0x3040   //SDK通信超时
#define  ERROR_FAIL_MCCARD      0xD122   //读磁条卡失败
#define  ERROR_FAIL_DATA        0x3032   //数据域错误
#define  ERROR_FAIL_OTHER       0x3036   //其它错误
#define  ERROR_FAIL_NEEDIC      0x3039   //请插入IC卡
#define  ERROR_FAIL_DATAEXIST   0x3038   //数据已存在
#define  ERROR_FAIL_SWIPINGCARD 0x3041   //请先读卡

typedef enum
{
    STATE_ACTIVE = 0,
    STATE_IDLE = 1,
    STATE_BUSY = 2,
    STATE_UNACTIVE = -1
}DeviceBlueState;

typedef enum
{
    card_mc = 1,        //磁条卡
    card_ic = 2,        //IC卡
    card_nfc = 3        //非接ic卡
}cardType;              //银行卡类型

//读取的银行卡片信息
@interface DCCardMessage : NSObject
@property (nonatomic,copy) NSString *cardNum; //卡号
@property (nonatomic,copy) NSString *cardSeq; //IC卡片序列号
@property (nonatomic,copy) NSString *cardValid; //卡片有效期
@property (nonatomic,copy) NSString *cardTrack2;//二磁道信息
@property (nonatomic,copy) NSString *cardTrack3;//三磁道信息
@property (nonatomic,copy) NSString *card55;//IC卡55域

@end

//终端相关信息
@interface DCTerminalInfo : NSObject
@property (nonatomic,copy) NSString *ksn; //sn号
@property (nonatomic,copy) NSString *hardwadeVersion; //固件版本号
@property (nonatomic,copy) NSString *posType; //设备类型

@end

//协议方法
@protocol DCSwiperAPIDelegate <NSObject>

@optional

/**
 *  扫描设备结果 扫描一个回调一次
 *
 *  @param cbPeripheral 蓝牙信息
 */
-(void)onFindBlueDevice:(CBPeripheral *)cbPeripheral;

/**
 连接成功之后的回调

 @param cbPeripheral 蓝牙外设
 */
-(void)onDidConnectBlueDevice:(CBPeripheral *)cbPeripheral;
/**
 *  失去连接到设备
 *
 *  @param cbPeripheral 蓝牙信息
 */
-(void)onDisconnectBlueDevice:(CBPeripheral *)cbPeripheral;

/**
 *  获取设备信息的结果
 *
 *  @param terminalInfo 终端信息
 */
-(void)onDidGetTerminalInfo:(DCTerminalInfo *)terminalInfo;

/**
 *  导入主密钥返回
 *
 *  @param isSuccess YES OR NO
 */
-(void)onDidLoadMainKey:(BOOL)isSuccess;

/**
 *  签到回调（更新工作秘钥）
 *
 *  @param isSuccess  YES 成功
 */
-(void)onDidUpdateKey:(BOOL)isSuccess;

/**
 *  识别到卡
 */
-(void)onDetectCard;

/**
 *  刷卡、插卡、非接卡信息回调
 *
 *  @param cardMessage 卡信息
 */
-(void)onDidReadCardInfo:(DCCardMessage *)cardMessage;

/**
 pin加密返回 p27

 @param encPINblock 密码密文
 */
-(void)onEncryptPinBlock:(NSString *)encPINblock;

/**
 获取POS输入密码的回调函数  p84

 @param pinBlock 密码密文
 */
-(void)onReturnPinBlock:(NSString *)pinBlock;

/**
 *  设备按取消键返回
 */
-(void)onPressCancleKey;

/**
 *   mac计算结果
 *
 *  @param strmac mac
 */
-(void)onDidGetMac:(NSString *)strmac;

/**
 *  异常错误
 *
 *  @param errorCode    错误码
 *  @param errorMessage 错误信息
 */
- (void)onError:(NSInteger)errorCode andMessage:(NSString *)errorMessage;

/**
 *  取消/复位回调
 */
-(void)onDidCancelCard;

@end

@interface DCSwiperAPI : NSObject
@property (nonatomic, weak)    id<DCSwiperAPIDelegate> delegate;//代理
@property (nonatomic, assign)  DeviceBlueState BlueState;//蓝牙状态
@property (nonatomic, assign)  BOOL isConnectBlue; //蓝牙是否连接
@property (nonatomic) cardType  currentCardType;

/**
 SDK初始化

 @return SDK单例对象
 */
+(DCSwiperAPI *)shareInstance;

/**
 搜索蓝牙设备
 */
-(void)scanBlueDevice;

/**
 停止扫描蓝牙
 */
-(void)stopScanBlueDevice;

/**
 连接蓝牙
 
 @param cbPeripheral 蓝牙外设
 */
-(void)connectBlueDevice:(CBPeripheral *)cbPeripheral;

/**
 断开蓝牙设备
 */
-(void)disConnect;

/**
 获取设备信息（ksn编号以及固件版本信息）
 */
-(void)getTerminalInfo;

/**
 写入主密钥

 @param mainKey 主密钥
 */
-(void)loadMainKey:(NSString *)mainKey;

/**
 写入工作密钥 

 @param pinKey (32位密钥 + 8位checkValue = 40位）
 @param desKey (32位密钥 + 8位checkValue = 40位）
 @param macKey (16位密钥 + 8位checkValue = 24位）
 */
-(void)updatePinKey:(NSString *)pinKey desKey:(NSString *)desKey macKey:(NSString *)macKey;

/**
 读磁条卡、IC卡、非接、使用同一接口，app代码无需做刷卡类型区分。
 *
 *  @param type 消费类型
 *              1: 消费 （金额以分为单位）
 *              2: 查余 （此时金额传0）
 *              3: 撤销
 *  @param money 金额
 */

-(void)readCardTradeType:(int)type TradeMoney:(NSString*)money;

/**
 pin加密 P27专用  手刷

 @param Pin 密码
 */
-(void)encryptPin:(NSString *)Pin;

/**
 POS获取输入密码 (必须先执行读取卡片的操作) P84专用  键盘
 */
-(void)getPinFromPOS;

/**
 计算mac
 
 @param data mac
 */
-(void)getMacValue:(NSString *)data;

/**
 取消复位
 */
-(void)cancelCard;

/**
 日志开关 默认打开

 @param isOpen YES 打开 / NO 关闭
 */
-(void)setSDKLogSwitch:(BOOL)isOpen;
@end

