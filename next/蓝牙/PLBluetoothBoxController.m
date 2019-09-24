//
//  PLBluetoothBoxController.m
//  ssca
//
//  Created by Admin on 2018/7/9.
//  Copyright © 2018年 深圳票联金融服务有限公司. All rights reserved.
//

#import "PLBluetoothBoxController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import<CoreBluetooth/CBService.h>

#define kPeripheralPrefix @"UBFS-MS"

typedef enum : NSUInteger {
    /** 获取尾箱上锁信息和电量显示开关、蜂鸣器状态*/
    PLCOMMANDTYPE_1 = 0,
    
    /** 发送控制指令*/
    PLCOMMANDTYPE_2,
    
    /** 获取尾箱固件版本信息*/
    PLCOMMANDTYPE_3,
    
    /** 获取尾箱电量信息*/
    PLCOMMANDTYPE_4
} PLCOMMANDTYPE;

@interface PLBluetoothBoxController ()
<UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate,CBPeripheralDelegate>
{
    UITableView *_myTableView;

    UILabel *_stateLabel; // 搜索状态
    UIButton *_linkBtn; // 连线按钮
    NSInteger _selIndex; // 选中下标
    CBPeripheral *_selPeripheral; // 选中的外设
    PLCOMMANDTYPE _commandType; // 指令类型(因解析方式有区别)
}

//系统蓝牙设备管理对象，可以把他理解为主设备，通过他，可以去扫描和链接外设
@property (nonatomic, strong) CBCentralManager *centralManager;

//用于保存被发现外设
@property (nonatomic, strong) NSMutableArray *peripherals;

@property (nonatomic, strong) CBCharacteristic *characteristcs;

@end

@implementation PLBluetoothBoxController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initDatas];
    
    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"viewWillDisappear");
    
    // 若是列表会有异常, 故先断开所有外设
    for (CBPeripheral *p in _peripherals)
    {
        if(p.state == CBPeripheralStateConnected)
        {
            [self.centralManager cancelPeripheralConnection:p];
        }
    }
    
    _linkBtn.selected = NO;
}

- (void)dealloc
{
    DLog(@"dealloc:%s",__func__);
}

#pragma mark - Init datas
- (void)initDatas
{
    _peripherals = [[NSMutableArray alloc]init];
    _selIndex = -1;
}

- (CBCentralManager *)centralManager
{
    if(_centralManager == nil)
    {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _centralManager;
}

- (NSArray *)funcs
{
    return @[@"文档盒",@"卡盒",@"盾盒",@"电量显示",@"蜂鸣器"];
}

#pragma mark - Lay out
- (void)layoutUI
{
    _stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, kScreenWidth - kLeftViewWidth - 40, 40)];
    [self.view addSubview:_stateLabel];
    _stateLabel.textColor = [UIColor blackColor];
    _stateLabel.text = @"";

    _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(20, 80, kScreenWidth/4, 40 * 3) style:UITableViewStylePlain];
    [self.view addSubview:_myTableView];
    [_myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    
    _myTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    _myTableView.estimatedRowHeight = 40.0f;
    _myTableView.rowHeight = UITableViewAutomaticDimension;
    HBViewBorderRadius(_myTableView, 2, 1, kbackgroundColor);

    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    searchBtn.frame = CGRectMake(kScreenWidth/4 + 40, 80, 80, 40);
    [self.view addSubview:searchBtn];
    [searchBtn setTitle:@"查找外设" forState:UIControlStateNormal];
    [searchBtn.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(scanPeripheralsAction:) forControlEvents:UIControlEventTouchUpInside];
    HBViewBorderRadius(searchBtn, 2, 1, kbackgroundColor);

    _linkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _linkBtn.frame = CGRectMake(kScreenWidth/4 + 40, 140, 80, 40);
    [self.view addSubview:_linkBtn];
    [_linkBtn setTitle:@"连接外设" forState:UIControlStateNormal];
    [_linkBtn setTitle:@"断开外设" forState:UIControlStateSelected];
    [_linkBtn.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [_linkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_linkBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [_linkBtn setSelected:NO];
    [_linkBtn addTarget:self action:@selector(linkPeripheralsAction:) forControlEvents:UIControlEventTouchUpInside];
    HBViewBorderRadius(_linkBtn, 2, 1, kbackgroundColor);
    
    // 查询锁的状态
    UIButton *searchStateBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    searchStateBtn.frame = CGRectMake(kScreenWidth/4 + 40, 200, 80, 40);
    [self.view addSubview:searchStateBtn];
    [searchStateBtn setTitle:@"查询" forState:UIControlStateNormal];
    [searchStateBtn.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];

    [searchStateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [searchStateBtn addTarget:self action:@selector(searchLockStateAction:) forControlEvents:UIControlEventTouchUpInside];
    HBViewBorderRadius(searchStateBtn, 2, 1, kbackgroundColor);

    // 文档盒,卡盒,盾盒开关
    for (int i = 0; i < [[self funcs] count]; i ++)
    {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_myTableView.frame) + 20 + (30 + 20) * i, 80, 30)];
        [self.view addSubview:titleLabel];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.text = [NSString stringWithFormat:@"%@:",[self funcs][i]];
        titleLabel.font = [UIFont systemFontOfSize:17.0f];
        
        UISwitch *switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(100 + 40, CGRectGetMaxY(_myTableView.frame) + 20 + (30 + 20) * i, 80, 30)];
        [self.view addSubview:switchBtn];
        [switchBtn setTag:i + 100];
        [switchBtn setOn:NO];
        [switchBtn addTarget:self action:@selector(switchCmdAction:) forControlEvents:UIControlEventValueChanged];
    }
}


#pragma mark - Call backs
- (void)scanPeripheralsAction:(id)sender
{
    NSLog(@"scanPeripheralsAction---");
    
    if (self.centralManager.state == CBCentralManagerStatePoweredOn)
    {
        _selIndex = -1;
        _selPeripheral = nil;
        for (CBPeripheral *peripheral in _peripherals)
        {
            if(peripheral.state == CBPeripheralStateConnected)
            {
                _selPeripheral = peripheral;
                break;
            }
        }
        
        [_peripherals removeAllObjects];
        
        // 重设已连接项
        if(_selPeripheral)
        {
            [_peripherals addObject:_selPeripheral];
            _selIndex = 0;
        }
        
        [_myTableView reloadData];

        _stateLabel.text = @"正在搜索周围外设列表...";
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)linkPeripheralsAction:(UIButton *)sender
{
    NSLog(@"linkPeripheralsAction---");
    
    if(_selIndex == -1) return; // 未选中设备
    
    if (sender.selected)
    {
        // disconnect
        if(_selPeripheral && _selPeripheral.state == CBPeripheralStateConnected)
        {
            [self.centralManager cancelPeripheralConnection:_selPeripheral];
        }
    }
    else
    {
        //若是列表会有异常, 故先断开所有外设
        for (CBPeripheral *p in _peripherals)
        {
            if(p.state == CBPeripheralStateConnected)
            {
                [self.centralManager cancelPeripheralConnection:p];
            }
        }
        
        // connect
        if(_selPeripheral && _selPeripheral.state != CBPeripheralStateConnected)
        {
            [self.centralManager connectPeripheral:_selPeripheral options:nil];
        }
    }
    sender.selected = !sender.selected;
}


/**
 查询锁以及其他信息状态
 */
- (void)searchLockStateAction:(UIButton *)sender
{
    NSLog(@"searchLockStateAction---");

    _commandType = PLCOMMANDTYPE_1;
    
    Byte dataArr[4];
    dataArr[0] = 0x26;
    dataArr[1] = 0x73;
    dataArr[2] = 0x63;
    dataArr[3] = 0x24;
    NSData *myData = [NSData dataWithBytes:dataArr length:4];
    
    [self writeCharacteristic:_selPeripheral characteristic:self.characteristcs value:myData];
}

/**
 开锁指令
 */
- (void)switchCmdAction:(UISwitch *)sender
{
    NSLog(@"switchCmdAction---");
    // 1:"文档盒" 2:"卡盒" 3:"盾盒" 4:"电量显示" 5:"蜂鸣器"
    NSUInteger flag = sender.tag - 100 + 1;
    
    Byte dataArr[4];
    dataArr[0] = 0x26;
    dataArr[1] = 0x65;
    dataArr[2] = (flag == 1)? 0x01:((flag == 2)? 0x02:(flag == 3)? 0x03:(flag == 4)? 0x04 : 0x05);
    dataArr[3] = 0x24;
    NSData *myData = [NSData dataWithBytes:dataArr length:4];
    
    [self writeCharacteristic:_selPeripheral characteristic:self.characteristcs value:myData];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@">>>CBCentralManagerStatePoweredOn");
        }
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    //这里自己去设置下连接规则，我设置的是P开头的设备
    if ([peripheral.name hasPrefix:kPeripheralPrefix])
    {
        //找到的设备必须持有它，否则CBCentralManager中也不会保存peripheral，那么CBPeripheralDelegate中的方法也不会被调用！！
        if(![_peripherals containsObject:peripheral]) [_peripherals addObject:peripheral];
        [_myTableView reloadData];
    }
}

//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@">>>连接到名称为（%@）的设备-成功",peripheral.name);
    
    _stateLabel.text = [NSString stringWithFormat:@">>>连接到名称为（%@）的设备-成功",peripheral.name];

    //停止扫描
    [self.centralManager stopScan];

    NSInteger row = [_peripherals indexOfObject:peripheral];
    [_peripherals replaceObjectAtIndex:row withObject:peripheral];
    [_myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:row inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //设置的peripheral委托CBPeripheralDelegate
    [peripheral setDelegate:self];
    //扫描外设Services，成功后会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    [peripheral discoverServices:nil];
}

//连接到Peripherals-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
    
    _stateLabel.text = [NSString stringWithFormat:@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]];
    if([_peripherals containsObject:peripheral])
    {
        NSInteger row = [_peripherals indexOfObject:peripheral];
        [_peripherals replaceObjectAtIndex:row withObject:peripheral];
        [_myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:row inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
    
    _stateLabel.text = [NSString stringWithFormat:@">>>外设连接断开连接(%@)", [peripheral name]];

    if([_peripherals containsObject:peripheral])
    {
        NSInteger row = [_peripherals indexOfObject:peripheral];
        [_peripherals replaceObjectAtIndex:row withObject:peripheral];
        [_myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:row inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
// ---- --

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@">>>扫描到服务：%@",peripheral.services);
    if (error)
    {
        NSLog(@">>>Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    
    for (CBService *service in peripheral.services)
    {
        NSLog(@"%@",service.UUID);
        //扫描每个service的Characteristics，扫描到后会进入方法： -(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"FFE0"]])
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

//4.2获取外设的Characteristics,获取Characteristics的值，获取Characteristics的Descriptor和Descriptor的值
//扫描到Characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error)
    {
        NSLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"service:%@ 的 Characteristic: %@",service.UUID,characteristic.UUID);
        [self notifyCharacteristic:peripheral characteristic:characteristic];
    }
    
    //获取Characteristic的值，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        [peripheral readValueForCharacteristic:characteristic];
        
        _characteristcs = characteristic;
    }
    
    //搜索Characteristic的Descriptors，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    for (CBCharacteristic *characteristic in service.characteristics){
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
}

//获取的charateristic的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //打印出characteristic的UUID和值
    //!注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
    NSLog(@"characteristic uuid:%@  value:%@",characteristic.UUID,characteristic.value);
    
    /** UBFS-MS-001
     2018-06-20 18:24:05.500982+0800 ssca_bluetoothBox[18799:7937398] characteristic uuid:FFE1  value:<312e300d 0a>
     */
    
    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"FFE1"]])
    {
        //const unsigned char *hexBytesLight = [characteristic.value bytes];
        //NSString *hexValue = [NSString stringWithFormat:@"%02x", hexBytesLight[0]];
        
        // version
        //(lldb) po hexBytesLight
        //"1.0\r\n"
        
        // bartter
        // 5f -- 95%
        
        // 上锁
        //2018-06-20 18:32:23.350751+0800 ssca_bluetoothBox[18865:7941215] characteristic uuid:FFE1  value:<00000000 00>
        
        NSData *data = characteristic.value;
        
        NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"string:%@",string);
        
        NSString *string2 = [NSString stringWithFormat:@"%@",data];
        NSLog(@"string2:%@",string2);
        
        NSString *hexString1 = [string2 componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<,>"]][1];
        
        // 修改调整空项 做解析: 0001000000
        // 刷新锁按钮显示
        //!!!!:注意,厂家设备发的指令与文档不一致,要求App端改(主要是前三项的锁标识错误)
        if(_commandType == PLCOMMANDTYPE_1 && [hexString1 containsString:@" "])
        {
            hexString1 = [hexString1 stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            NSMutableArray *msgs = [[NSMutableArray alloc]init];
            for (int i = 0; i < [[self funcs] count]; i ++)
            {
                NSUInteger onValue = [[hexString1 substringWithRange:NSMakeRange(2 * i, 2)] integerValue];
                if(!onValue && i < 3) [msgs addObject:[self funcs][i]];
                    
                NSUInteger tag = 100 + i;
                UISwitch *switchButton = (UISwitch *)[self.view viewWithTag:tag];
                [switchButton setOn:(i < 3)?!onValue:onValue animated:YES];
            }
            
            if([msgs count] > 0)
            {
                NSString *msg = [NSString stringWithFormat:@"请注意关闭:%@!",[msgs componentsJoinedByString:@","]];
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * ensure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:ensure];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        NSLog(@"hexString1:%@",hexString1);

//        unsigned long hexString2 = strtoul([hexString1 UTF8String],0,16);
//        NSLog(@"hexString2:%02lx",hexString2);
    }
}

//搜索到Characteristic的Descriptors
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    //打印出Characteristic和他的Descriptors
    NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        NSLog(@"Descriptor uuid:%@",d.UUID);
    }
}

//获取到Descriptors的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

//写数据
- (void)writeCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic
                      value:(NSData *)value
{
    //打印出 characteristic 的权限，可以看到有很多种，这是一个NS_OPTIONS，就是可以同时用于好几个值，常见的有read，write，notify，indicate，知知道这几个基本就够用了，前连个是读写权限，后两个都是通知，两种不同的通知方式。
    
    NSLog(@"characteristic.properties:%lu", (unsigned long)characteristic.properties);
    // <CBCharacteristic: 0x109decb90, UUID = FFE1, properties = 0x1E, value = (null), notifying = NO>
    // 无从对应啊?
    
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        /*
         最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈
         */
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }else{
        NSLog(@"该字段不可写！");
    }
}

//设置通知
- (void)notifyCharacteristic:(CBPeripheral *)peripheral
              characteristic:(CBCharacteristic *)characteristic
{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

//取消通知
- (void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                    characteristic:(CBCharacteristic *)characteristic
{
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

#pragma mark - Table view data source /delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_peripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;//[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    NSDictionary *stateDic = @{@0 : @"Disconnected",
                               @1 : @"Connecting...",
                               @2 : @"Connected",
                               @3 : @"Disconnecting"};
    
    CBPeripheral *peripheral = _peripherals[indexPath.row];
    cell.textLabel.text = peripheral.name;
    cell.textLabel.textColor = [UIColor blackColor];

    cell.detailTextLabel.text = [stateDic objectForKey:@(peripheral.state)];
    cell.accessoryType = (indexPath.row == _selIndex)?UITableViewCellAccessoryCheckmark :UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row%ld-%@",(long)indexPath.row,_peripherals[indexPath.row]);
    
    _selPeripheral = _peripherals[indexPath.row];
    _linkBtn.selected = (_selPeripheral.state == CBPeripheralStateConnected)? YES:NO;

    for (UITableViewCell *cell in _myTableView.visibleCells)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _selIndex = indexPath.row;
}

@end
