//
//  BleService.m
//  Qiandaibao
//
//  Created by 阿图system on 17/4/6.
//  Copyright © 2017年 boshang. All rights reserved.
//

#import "AppDelegate.h"


static BleService * bleservice;


@interface BleService()<ZcmBleProtocol,DCSwiperAPIDelegate,JhlblueControllerDelegate>{
    CurrentConnectedDeviceType connectedDeviceType;
    
}


@end

@implementation BleService



+(BleService *)shareInstance{

    
    if (bleservice == nil) {
        bleservice = [[self allocWithZone:NULL] init];
    }
    
    return bleservice;
}

-(id)init{
    
    self = [super init];
    connectedDeviceType = CurrentConnectedDeviceNone;
    _bandDeviceName = @"";
    return self;
    
}


-(void)ZcmScan{
    DCSwiperAPI * dcSwiper = [DCSwiperAPI shareInstance];
    dcSwiper.delegate = self;
    [dcSwiper scanBlueDevice];

    [[JhlblueController sharedInstance] setDelegate:self];
    NSLog(@"dcSwiper.delegate = self === %s",__FUNCTION__);
}



-(void)ZcmConnectPos{

    [self ZcmScan];
    
}

-(void)ZcmDisConnect{
    DCSwiperAPI * dcSwiper = [DCSwiperAPI shareInstance];
    dcSwiper.delegate = self;
    NSLog(@"dcSwiper.delegate = self === %s",__FUNCTION__);
    [dcSwiper disConnect];
    
}




/* 
 
 -当前链接的设备型号
 返回类型：各个厂商的pos 
 
 */
-(CurrentConnectedDeviceType)ZcmGetCurrentConnectedPos{
    NSLog(@"%s, connectedDeviceType = %ld",__FUNCTION__,(long)connectedDeviceType);
    return connectedDeviceType;
    
}


-(void)bandDeviceName:(NSString*)deviceName{
    //每个厂商各自处理扫描出来的东东
    if ([deviceName containsString:@"DCQ"] || /* DISABLES CODE */ (1)) {
        NSString * tmpDeviceName = [[NSString alloc]initWithFormat:@"DCQ%@",[GlobalMethod hexToTenString:deviceName]];
        [[NSUserDefaults standardUserDefaults] setObject:tmpDeviceName forKey:kUserDefaults_BandedDeviceName];
    }else if ([deviceName containsString:@"LY"]){
        NSString * tmpDeviceName = [[NSString alloc]initWithFormat:@"LY%@",[GlobalMethod hexToTenString:deviceName]];
        [[NSUserDefaults standardUserDefaults] setObject:tmpDeviceName forKey:kUserDefaults_BandedDeviceName];
    }

    
}

#pragma mark -- 统一处理更新密钥等

/*
 主秘钥更新
 */
-(void)lyUpdateMainkey:(NSData *)mainKey{
    //    if(mainKey == nil || [mainKey length] != 20)
    //    {
    //        [GlobalMethod showGlobalPrompt:@"主秘钥请求失败" delay:1.5];
    //        return;
    //    }
    NSData * tmpMainkdata = [[NSData alloc] initWithBytes:[mainKey bytes] length:20];
    NSString * mainKstr = [self hexStringFromData:tmpMainkdata];
    
    
    if (connectedDeviceType == CurrentConnectedDeviceQDB) {
        [[DCSwiperAPI shareInstance] loadMainKey:mainKstr];
    }
    
    if (connectedDeviceType == CurrentConnectedDeviceJHL) {
        return;
        [[JhlblueController sharedInstance] WriteMainKey:mainKstr];
    }
    
    
    
}

/*
 工作秘钥更新
 */
-(void)lyUpdateWorkingkey:(NSData *)workKey{
    if(workKey == nil || [workKey length] != 60)
    {
        [GlobalMethod showGlobalPrompt:@"工作秘钥请求失败" delay:1.5];
        return;
    }
    
    NSData * tmpPIkdata = [[NSData alloc] initWithBytes:[workKey bytes] length:20];
    //    NSString * PIKstr = [GlobalMethod bctToAscii:[[NSString alloc] initWithData:tmpPIkdata encoding:NSUTF8StringEncoding]];
    NSString * PIKstr = [[self hexStringFromData:tmpPIkdata] uppercaseString];
    
    NSData * tmpMAKdata = [[NSData alloc] initWithBytes:[workKey bytes]+20 length:20];
    //    NSString * MAKstr = [GlobalMethod bctToAscii:[[NSString alloc] initWithData:tmpMAKdata encoding:NSUTF8StringEncoding]];
    NSString * MAKstr = [[self hexStringFromData:tmpMAKdata] uppercaseString];
    
    NSData * tmpTDKdata = [[NSData alloc] initWithBytes:[workKey bytes]+40 length:20];
    //    NSString * TDKstr = [GlobalMethod bctToAscii:[[NSString alloc] initWithData:tmpTDKdata encoding:NSUTF8StringEncoding]];//暂时不用
    NSString * TDKstr = [[self hexStringFromData:tmpTDKdata] uppercaseString];//暂时不用
    
    //    NSString * PIKstr = [[NSString alloc]initWithData:[NSData dataWithBytes:[workKey bytes] length:20] encoding:NSUTF8StringEncoding];
    //    NSString * MAKstr = [[NSString alloc]initWithData:[NSData dataWithBytes:[workKey bytes] + 20 length:20] encoding:NSUTF8StringEncoding];
    //    NSString * TDKstr = [[NSString alloc]initWithData:[NSData dataWithBytes:[workKey bytes] + 40 length:20] encoding:NSUTF8StringEncoding];//暂时不用
    

    [[DCSwiperAPI shareInstance] setDelegate:self];
    
    if (connectedDeviceType == CurrentConnectedDeviceQDB) {
        [[DCSwiperAPI shareInstance] updatePinKey:PIKstr desKey:TDKstr macKey:MAKstr];
    }else if (connectedDeviceType == CurrentConnectedDeviceQDB){
//        NSString* 	DataWorkkey  16字节PIN密钥+4个字节校验码 +16字节MAC +4个字节MAC校验码 +磁道加密密钥+磁道加密密钥校验码  ==60 个字节 120字符
        
        NSString * tmpPI_MAC_TDK = [[self hexStringFromData:workKey] uppercaseString];
        [[JhlblueController sharedInstance] WriteWorkKey:tmpPI_MAC_TDK];
    }
    
    /**
     写入工作密钥
     
     @param pinKey (32位密钥 + 8位checkValue = 40位）
     @param desKey (32位密钥 + 8位checkValue = 40位）
     @param macKey (16位密钥 + 8位checkValue = 24位）
     */
}

- (NSString *)stringFromHexString:(NSString *)hexString { //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
    
    
}

- (NSString *)hexStringFromData:(NSData*)data{
    return [[[[NSString stringWithFormat:@"%@",data]
              stringByReplacingOccurrencesOfString: @"<" withString: @""]
             stringByReplacingOccurrencesOfString: @">" withString: @""]
            stringByReplacingOccurrencesOfString: @" " withString: @""];
}





#pragma mark -- 蓝牙回调 --

#pragma mark DCSwiperAPIDelegate


/**
 *  扫描设备结果 扫描一个回调一次
 *
 *  @param cbPeripheral 蓝牙信息
 */
-(void)onFindBlueDevice:(CBPeripheral *)cbPeripheral{
    NSLog(@"cpperipheral name = %@",cbPeripheral.name);
    NSString * perName = cbPeripheral.name;
//    [_delegate onZcmFindBlueDevice:cbPeripheral];
    
    if (perName != nil && [perName isEqualToString:[GlobalMethod getUserInfo].possnId]) {
        [[DCSwiperAPI shareInstance] connectBlueDevice:cbPeripheral];
    }
//
//    if (perName != nil && [perName isEqualToString:@"LY40CCB7BB2012"]) {
//        [[DCSwiperAPI shareInstance] connectBlueDevice:cbPeripheral];
//    }
    
    
    if (perName != nil && [perName isEqualToString:_bandDeviceName]) {
        [[DCSwiperAPI shareInstance] connectBlueDevice:cbPeripheral];
    }
    
}

/**
 连接成功之后的回调
 
 @param cbPeripheral 蓝牙外设
 */
-(void)onDidConnectBlueDevice:(CBPeripheral *)cbPeripheral{
    NSLog(@"%s",__FUNCTION__);
    NSString * perName = cbPeripheral.name;
    
    [[DCSwiperAPI shareInstance] stopScanBlueDevice];


    
    if (perName != nil && [perName isEqualToString:_bandDeviceName]) {
        connectedDeviceType = CurrentConnectedDeviceNone;
        [self.delegate onZcmDidConnectBlueDevice];
        _bandDeviceName = @"";
        [[DCSwiperAPI shareInstance] disConnect];
        
    }else{
        if (perName != nil && [perName containsString:DCQ_BLEDEVICE]) {
            connectedDeviceType = CurrentConnectedDeviceQDB;
        }
        
        if (perName != nil && [perName containsString:JHL_BLEDEVICE]) {
            connectedDeviceType = CurrentConnectedDeviceJHL;
        }
    }

}

/**
 *  失去连接到设备
 *
 *  @param cbPeripheral 蓝牙信息
 */
-(void)onDisconnectBlueDevice:(CBPeripheral *)cbPeripheral{
    NSLog(@"%s",__FUNCTION__);
    connectedDeviceType = CurrentConnectedDeviceNone;
    
    [[DCSwiperAPI shareInstance] scanBlueDevice];
}

/**
 *  获取设备信息的结果
 *
 *  @param terminalInfo 终端信息
 */
-(void)onDidGetTerminalInfo:(DCTerminalInfo *)terminalInfo{
    NSLog(@"%s",__FUNCTION__);
}


/**
 *  导入主密钥返回
 *
 *  @param isSuccess YES OR NO
 */
-(void)onDidLoadMainKey:(BOOL)isSuccess{
    if (isSuccess) {
        NSLog(@"更新主密钥成功");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ble_NOtification" object:[NSString stringWithFormat:@"MAIN_YES"]];
        [GlobalMethod showGlobalPrompt:[NSString stringWithFormat:@"更新主密钥成功"] delay:1.5];
        //更新完主秘钥进行签到
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TERMAGAINLOGIN" object:nil];
    }else {
        
        NSLog(@"更新主密钥失败");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ble_NOtification" object:[NSString stringWithFormat:@"MAIN_NO"]];
        [GlobalMethod showGlobalPrompt:[NSString stringWithFormat:@"更新主密钥失败"] delay:1.5];
    }
}


/**
 *  签到回调（更新工作秘钥）
 *
 *  @param isSuccess  YES 成功
 */
-(void)onDidUpdateKey:(BOOL)isSuccess{
    
    if (isSuccess) {
        NSLog(@"更新工作秘钥成功");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ble_NOtification" object:[NSString stringWithFormat:@"WORK_YES"]];


    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ble_NOtification" object:[NSString stringWithFormat:@"WORK_NO"]];
        [GlobalMethod showGlobalPrompt:@"工作密钥更新失败" delay:1.5];
    }
    

}



#pragma mark -- JhlblueControllerDelegate --



/*
    主密钥设置成功
 */

- (void)onLoadMasterKeySucc :(Boolean) isSucess{
    if (isSucess) {
        NSLog(@"更新主密钥成功");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ble_NOtification" object:[NSString stringWithFormat:@"MAIN_YES"]];
        [GlobalMethod showGlobalPrompt:[NSString stringWithFormat:@"更新主密钥成功"] delay:1.5];
        //更新完主秘钥进行签到
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TERMAGAINLOGIN" object:nil];
    }else {
        
        NSLog(@"更新主密钥失败");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ble_NOtification" object:[NSString stringWithFormat:@"MAIN_NO"]];
        [GlobalMethod showGlobalPrompt:[NSString stringWithFormat:@"更新主密钥失败"] delay:1.5];
    }
}

/*
    工作密钥
 */
- (void)onLoadWorkKeySucc :(Boolean) isSucess{
    
    if (isSucess) {
        NSLog(@"更新工作秘钥成功");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ble_NOtification" object:[NSString stringWithFormat:@"WORK_YES"]];
        
        
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ble_NOtification" object:[NSString stringWithFormat:@"WORK_NO"]];
        [GlobalMethod showGlobalPrompt:@"工作密钥更新失败" delay:1.5];
    }
}




















@end




