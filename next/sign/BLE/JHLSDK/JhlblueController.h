//
//  JhlblueController.h
//  JhlblueController
//
//  Created by gui hua on 16/4/5.
//  Copyright © 2016年 szjhl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#pragma clang diagnostic ignored "-Wmissing-selector-name"








typedef enum {
    
    GETCARD_CMD=0x12,
    GETTRACK_CMD=0x20,
    GETTRACKDATA_CMD =0x22,  //0xE1  用户取消  0xE2 超时退出 E3 IC卡数据处理失败 0xE4 无IC卡参数 0xE5 交易终止 0xE6 操作失败,请重试
    GAINPARAMETER_CMD = 0x50,
    SWIPREAD_CMD   =    0xA0,
    MAGN_CANCEL_CMD  =   0x99 , //取消刷卡
    ICBARUSH_CMD  =     0x18,   //手刷 蓝牙手刷
    PASS_INPUT_CMD   =  0x19 ,  //输入密码加密
    MAINKEY_CMD = 0x34,
    WORKKEY_CMD = 0x38,
    GETMAC_CMD  = 0x37,
    BATTERY_CMD    =    0x45 ,  //获取电池电量
    SWIPE_SUCESS = 0x00 ,   //正常交易
    SWIPE_DOWNGRADE = 0xb0,  //降级
    SWIPE_ICCARD_INSETR = 0xb1, //主界面插入IC卡
    SWIPE_ICCARD_SWINSETR  =0xb2, //交易功能中插入IC卡
    SWIPE_WAIT_BRUSH = 0xb3, //等待用户刷卡/插卡
    SWIPE_CANCEL  = 0xe1,  //取消交易
    SWIPE_TIMEOUT_STOP =0xe2,  //超时退出
    SWIPE_IC_FAILD = 0xe3, //IC卡处理失败
    SWIPE_NOICPARM = 0xe4, //无IC卡参数
    SWIPE_STOP  =0xe5, //交易终止
    SWIPE_IC_REMOVE  =0xe6, //IC卡移除
    SWIPE_FAILD = 0xe7, //刷卡失败
    SWIPE_LOW_POWER  =0x4c, //电量低
    BLUE_POWER_OFF = 0x46, //关机
    BLUE_DATA_WAITE  =0x47 ,// 等待接收数据中,不允许重复发送
    BLUE_DEVICE_ERROR  =0x48 ,// 设备非法,不匹配当前SDK
    BLUE_DATA_DATAERROR  =0x49, // 数据错误
    BLUE_SCAN_NODEVICE =-1, //无设备
    BLUE_CONNECT_FAIL =0x00, //设备连接失败
    BLUE_CONNECT_ING =0x02, //蓝牙正在连接
    BLUE_CONNECT_SUCESS =0x01, //设备连接成功
    BLUE_POWER_STATE_ON =0x06, // 启动蓝牙
    BLUE_POWER_STATE_OFF =0x07 //关闭蓝牙
} SDKStatus;






typedef enum {
    FILE_TYPE_ERROR=-1,//文件格式类型不对
    FILE_PATH_ERROR=-2,  //文件路径异常
    FILE_LEN_ERROR=-3,  //文件长度错误
    HAND_DEVIE_ERROR=-4,//与终端握手失败
    DEVICE_ERASE_ERROR=-5, //设备擦除失败
    DEVICE_UPDATA_ERROR=-6, //升级异常
    DEVICE_SEND_ERROR=0x01, //数据发送失败
    DEVICE_REVICE_ERROR=0x02, //接收数据异常
    COMMOND_ERROR=0x03, //命令码出错
    DATA_CHECK_ERROR=0x04, //数据校验错误
    FILE_CHECK_ERROR=0x05, //文件校验错误
    DATA_WD_ERROR=0x07, //数据写入错误
    DATA_WF_ERROR=0x08, //升级标致失败
    DATA_SF_NEW=0x09, //无需更新,版本最新
    DEVICE_CON_ERROR=10, //连接出错
    DATA_PACK_ERROR=11, //包号出错
    DATA_LEN_ERROR=12, //数据长度出错
    DATA_TIMEOUT_ERROR=13, //接收超时
} FileStatus;




@protocol  JhlblueControllerDelegate;

@interface JhlblueController : NSObject

@property (weak,nonatomic) id<JhlblueControllerDelegate> delegate;

+ (id)sharedInstance;
- (void)LogIsEnable:(BOOL)isEnable;
-(NSString *)GetSDKVersion;


//================蓝牙部分================
//蓝牙是否可用
- (BOOL)buleToothIsEnable;
//蓝牙是否已连接
- (BOOL)isBTConnected;
//蓝牙搜索,搜索时间按秒,搜索返回类型 0 是列表一起返回  1:收到一个返回一个
- (void)scanBTDevice:(long)nScanTimer nScanType:(int) nscantype;
//停止搜索
- (void)stopScanBT;
- (void)connectBT:(CBPeripheral *)peripheral connectTimeout:(int)connectTimeout;
- (void)connectuuidBT:(NSString  *)peruuid connectTimeout:(int)connectTimeout;
//断开蓝牙连接
- (void)disconnectBT;

//金融交易相关函数接口

-(int)GetSnVersion;
-(int)GetDeviceInfo;
- (void)getCardNumber; //获取明文卡号

/********************************************************************
 
	函 数 名：WriteMainKey
	功能描述：写入主密钥
	入口参数：
    NSString* 	MainDatakey		--主密钥数据16个字节 32位字符
	返回说明：成功/失败
 **********************************************************/

-(int)WriteMainKey:(NSString*)MainDatakey;
/********************************************************************
 
	函 数 名：WriteWorkKey
	功能描述：写入工作密钥
	入口参数：
     NSString* 	DataWorkkey  16字节PIN密钥+4个字节校验码 +16字节MAC +4个字节MAC校验码 +磁道加密密钥+磁道加密密钥校验码  ==60 个字节 120字符
 
	返回说明：成功/失败
 **********************************************************/
-(int)WriteWorkKey:(NSString*)DataWorkkey;

/*
 函 数 名：ReadBattery
 功能描述：获取电池电量
 入口参数：
 返回说明：成功/失败
 **********************************************************/
-(int)ReadBattery;

/********************************************************************
	函 数 名：InputPassword
	功能描述： 密码加密,返回消费需要上送数据22域+35+36+IC磁道数据+PINBLOCK+磁道加密随机数
 秒
 NSString 	bPassKey		-密码数据例如:12345
	返回说明：
 **********************************************************/
-(int)InputPassword:(NSString*)bPassKeys;

/********************************************************************
	函 数 名：SwipeCard
	功能描述： 刷卡,返回消费需要上送数据22域+35+36+IC磁道数据+PINBLOCK+磁道加密随机数
 秒
 long 	ntimeout		-超时时间
 long    lAmount          --金额（分）
 int nMype 刷卡类型
 0x01  有金额有密码
 0x02  有金额无密码
 0x03  无金额有密码
 0x04  无金额无密码
	返回说明：
 **********************************************************/
-(int)SwipeCard:(long)ntimeout:(long)lAmount;



/*
 函 数 名：MagnCancel
 功能描述：取消当前刷卡
 入口参数：
 返回说明：成功/失败
 **********************************************************/
-(int)MagnCancel;

/********************************************************************
 
	函 数 名：GetMac
	功能描述：获取MAC
	入口参数：
 int		len		--数据长度 字节算大小
 int 	Datakey		--计算MAC数据
	返回说明：成功/失败
 **********************************************************/

-(int)GetMac:(int)len :(NSString*)MacDatakey;



/********************************************************************
 
	函 数 名：UpdateSoftVersion
	功能描述：更新固件
	入口参数：
    szFileName	--固件全路径
	返回说明：成功/失败
 **********************************************************/
-(int)UpdataSoftVersion:(NSString*)szFileName;


@end


@protocol JhlblueControllerDelegate<NSObject>
@optional
/**  输入密码回调*/
-(void)onGetEncPINComplete:(NSString*)msgData;
#pragma mark ===============功能交易部分的回调===============
//返回设备信息
- (void)onDeviceInfo:(NSMutableDictionary*)DeviceInfoList;
- (void)onTimeout; //超时

//功能操作结果
- (void)onLoadMasterKeySucc :(Boolean) isSucess; //主密钥设置成功
- (void)onLoadWorkKeySucc :(Boolean) isSucess;//工作密钥
- (void)onLoadMacKeySucc :(NSString * ) macdata :(Boolean) isSucess;//获取MAC数据
- (void)onLoadBattySucc :(NSString * ) battydata :(Boolean) isSucess;//获取电池电量数据

//功能操作结果
- (void)swipCardSucess:(NSString * ) cardNumber :(Boolean) bDowngrade;  //A80 刷卡成功
- (void)onResult:(int) Code:(int) nResult :(NSString *)MsgData;
- (void)swipCardState:(int ) nResult;  //刷卡提示
- (void)onReadCardData:(NSMutableDictionary*) NsFildCardData;
/*设备信息返回
参数:cardNumber-----银行卡号
*/
- (void)onJHLCardNumber:(NSString *)cardNumber  :(NSString *)cardexpirdate;

#pragma mark ===============蓝牙部分的回调===============
//发现新的蓝牙
- (void)onFindNewPeripheral:(CBPeripheral *)newPeripheral;
//蓝牙已连接
- (void)onConnected:(CBPeripheral *)connectedPeripheral;
//蓝牙搜索超时
- (void)onScanTimeout;
//搜索到的蓝牙设备
- (void)onDeviceFound:(NSArray *)DeviceList;

/** 正在绑定/连接蓝牙回调 **/
- (void)onBluetoothIng;

/**蓝牙连接失败**/
- (void)onBluetoothConectedFail;

/**连接断开回调 **/
- (void)onBluetoothDisconnected;


/**蓝牙关闭 **/
- (void)onBluetoothPowerOff;

/**蓝牙开启**/
- (void)onBluetoothPowerOn;
/** 等待刷卡、插卡、挥卡回调 **/
- (void)onWaitingForCardSwipe;

/** 检测到刷卡插入IC卡回调 **/
- (void)onDetectIC;




#pragma mark ===============蓝牙升级部分的回调===============
/**开始升级 **/
- (void)AppUpdataBegin;


/**升级中  packageN 当前升级包数  packageCount 总包数**/
- (void)AppUpdataInfo:(int)packageN  :(int)packageCount;

/**升级错误 nCode 错误代码   ErrorData 错误提示信息**/
- (void)AppUpdataError:(int)nCode  :(NSString *)ErrorData;

/**升级成功 **/
- (void)AppUpdataSucess;



@end



