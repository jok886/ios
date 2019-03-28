# baseK(相关基础知识)

### 蓝牙常见名称和缩写


- BLE:(Bluetooth low energy)蓝牙4.0设备因为低耗电,也叫BLE
- peripheral,central:外设和中心设备,发起链接的是central(一般是指手机),被链接的设备是peripheral(运动手环)
- service and characteristic:(服务和特征)每个设备会提供服务和特征,类似于服务端的API,但是结构不同.`每个设备会有很多服务`,每个服务中包含`很多字段`,这些字段的权限一般分为读(read),写(write),通知(notify)几种,就是我们连接设备后具体需要操作的内容
- Description:每个characteristic可以对应一个或者多个Description用于描述characteristic的信息或属性(eg.范围,计量单位)

### 蓝牙基础知识

- CoreBluetooth框架的核心其实是俩东西:peripheral和central,对应他们分别有一组相关的API和类
![图4.1.1](./bleIma/ble_01.png)

- 这两组api粉笔对应不同的业务常见:左侧叫中心模式,就是以你的app作为中心,连接其他的外设的场景;而右侧称为外设模式,使用`手机作为外设`连接其他中心设备操作的场景

- 服务和特征(service and characteristic)
    * 每个设备都会有1个or多个服务
    * 每个服务里都会有1个or多个特征
    * 特征就是具体键值对,提供数据的地方
    * 每个特征属性分为:读,写,通知等等

```objc
typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
	CBCharacteristicPropertyBroadcast												= 0x01,
	CBCharacteristicPropertyRead													= 0x02,
	CBCharacteristicPropertyWriteWithoutResponse									= 0x04,
	CBCharacteristicPropertyWrite													= 0x08,
	CBCharacteristicPropertyNotify													= 0x10,
	CBCharacteristicPropertyIndicate												= 0x20,
	CBCharacteristicPropertyAuthenticatedSignedWrites								= 0x40,
	CBCharacteristicPropertyExtendedProperties										= 0x80,
	CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)		= 0x100,
	CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)	= 0x200
};
```

- 外设,服务,特征的关系
 ![图4.1.2](./bleIma/ble_02.png)

## BLE中心模式流程
- 1.建立中心角色
- 2.扫描外设(Discover Peripheral)
- 3.连接外设(Connect Peripheral)
- 4.扫描外设中的服务和特征(Discover Services And Characteristics)
    * 4.1 获取外设的services
    * 4.2 获取外设的Characteristics,获取characteristics的值,,获取Characteristics的Descriptor和Descriptor的值
- 5.利用特征与外设做数据交互(Explore And Interact)
- 6.订阅Characteristic的通知
- 7.断开连接(Disconnect)

## BLE外设模式流程
- 1.启动一个Peripheral管理对象
- 2.本地peripheral设置服务,特征,描述,权限等等
- 3.peripheral发送广告
- 4.设置处理订阅,取消订阅,读characteristic,写characteristic的代理方法

## 蓝牙设备的状态
- 1.待机状态(standby):设备没有传输和发送数据,并且没有连接到任何外设
- 2.广播状态(Advertiser):周期性广播状态
- 3.扫描状态(Scanner):主动搜索正在广播的设备
- 4.发起链接状态(Initiator):主动向扫描设备发起连接
- 5.主设备(Master):作为主设备连接到其它设备.
- 6.从设备(Slave):作为从设备链接到其它设备

## 蓝牙设备的五种工作状态

- 准备(Standby)
- 广播(Advertising)
- 监听扫描(Scanning)
- 发起连接(Initiating)
- 已连接(Connected)

## 蓝牙和版本使用限制
- 蓝牙2.0:越狱设备
- BLE:iOS6以上
- MFI认证设备:无限制

## BLE测试
- 两台BLE设备
- 如何让iOS模拟器也能测试BLE?
    * 买一个CSR蓝牙4.0 USB适配器,插在Mac上
    * 在终端输入sudo nvram bluetoothHostControllerSwitchBehavior="never"
    * 重启Mac
    * 用Xcode4.6调试代码,将程序跑在iOS6.1模拟器上
    * 苹果把iOS7.0模拟器对BLE的支持移除了
    
    
 - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"\n设备名称：%@",peripheral.name);
    //TODO: 使用名字判断
    /*
    if ([peripheral.name isEqualToString:M_BLE_NAME]) {
        self.peripheral = peripheral;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
     */
    //TODO: 使用Mac地址判断
    NSData *data  =[advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    NSString *mac =[[self convertToNSStringWithNSData:data] uppercaseString];// uppercaseString转大写字母

    if([mac rangeOfString:M_BLE_MAC].location != NSNotFound){
        self.peripheral = peripheral;
        // 连接外设
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}
- (NSString *)convertToNSStringWithNSData:(NSData *)data {
    NSMutableString *strTemp = [NSMutableString stringWithCapacity:[data length]*2];
    const unsigned char *szBuffer = [data bytes];
    for (NSInteger i=0; i < [data length]; ++i) {
        [strTemp appendFormat:@"%02lx",(unsigned long)szBuffer[i]];
    }
    return strTemp;
}


//MARK: 7.2 从服务中发现外设特征的时候调用的代理方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    for (CBCharacteristic *cha in service.characteristics) {
        NSLog(@"\n设备的服务(%@)\n服务对应的特征值(%@)\nUUID(%@)\ncount(%lu)",service,cha,cha.UUID,service.characteristics.count);
        //MARK: 8.1 获取特征对应的描述 会回调didUpdateValueForDescriptor
        [peripheral discoverDescriptorsForCharacteristic:cha];
        //MAKR: 9.1获取特征的值 会回调didUpdateValueForCharacteristic
        [peripheral readValueForCharacteristic:cha];
        // 这里需要和硬件工程师协商好，数据写在哪个UUID里
        if([cha.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]]){
            self.characteristic = cha;
        } else {
            // 打开外设的通知，否则无法接受数据
            // 这里也是根据项目，和硬件工程师协商好，是否需要打开通知，和打开哪个UUID的通知。
            [peripheral setNotifyValue:YES forCharacteristic:cha];         
         }
    }
}

//MARK: 9.2 更新特征值回调，可以理解为获取蓝牙发回的数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSString *value = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"设备的特征值(%@),获取的数据(%@)",characteristic,value);
    //这里可以在这里获取描述
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFE2"]]) {
        NSData *data =characteristic.value;
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    }
}
   
   //MARK: 发送数据
-(void)sendDataToBLE:(NSData *)data{
    if(nil != self.characteristic){
        // data: 数据data
        // characteristic: 发送给哪个特征
        // type:     CBCharacteristicWriteWithResponse,  CBCharacteristicWriteWithoutResponse,
        // 这里要跟硬件确认好，写入的特征是否有允许写入，允许用withResponse 不允许只能强行写入，用withoutResponse
        // 或者根据 10.2 回调的error查看一下是否允许写入，下面说
        // 我这里是不允许写入的，所以用了 WithoutResponse
        [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
    }
    
    //MARK: 10.2 发送数据成功回调
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"写入数据失败:(%@)\n error:%@",characteristic,error.userInfo);
        // 这里用withResponse如果报错："Writing is not permitted."说明设备不允许写入，这个时候要用 WithoutResponse
        // 使用 WithoutResponse的时候，不走这个代理。
        return;
    }
    NSLog(@"写入数据成功:%@",characteristic);
    [peripheral readValueForCharacteristic:characteristic];
}
    
    //MARK: 分段写入
- (void)writeData:(NSData *)data
{
    // 判断能写入字节的最大长度
    int maxValue;
    if (@available(iOS 9.0, *)) {
        // type:这里和上面一样，
        maxValue =(int)[self.peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse];
    } else {
        // 默认是20字节
        maxValue =20;
    }
    NSLog(@"%i",maxValue);
    for (int i = 0; i < [data length]; i += maxValue) {
        // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
        if ((i + maxValue) < [data length]) {
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, maxValue];
            NSData *subData = [data subdataWithRange:NSRangeFromString(rangeStr)];
            [self sendDataToBLE:subData];
            // 根据接收模块的处理能力做相应延时
            usleep(10 * 1000);
        }
        else {
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([data length] - i)];
            NSData *subData = [data subdataWithRange:NSRangeFromString(rangeStr)];
            [self sendDataToBLE:subData];
            usleep(10 * 1000);
        }
    }
}



    
