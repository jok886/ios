//
//  BandDeviceViewController.m
//  Qiandaibao
//
//  Created by 阿图system on 17/4/6.
//  Copyright © 2017年 boshang. All rights reserved.
//

#import "BandDeviceViewController.h"


@interface BandDeviceViewController ()<ZcmBleProtocol>{
    BOOL lighting;//闪光灯是否开启状态
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    UILabel *lab;

    
    NSString * bandDeviceName;

}
@property (nonatomic, strong) ZBarReaderView *readerView;
@property (nonatomic, strong) UIButton * openFlashLight;
@property (nonatomic, retain) UIImageView * line;


@end

@implementation BandDeviceViewController

@synthesize openFlashLight;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"绑定设备";
    bandDeviceName = @"";
    openFlashLight = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-54, 20, 44, 44)];
    [openFlashLight setBackgroundImage:[UIImage imageNamed:@"My_message"] forState:UIControlStateNormal];
    [openFlashLight setTitle:@"设置" forState:0];
    [openFlashLight setImage:[UIImage imageNamed:@"my_msg_setting"] forState:UIControlStateNormal];
    openFlashLight.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15);
    [openFlashLight addTarget:self action:@selector(openFlashButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openFlashLight];
    lighting = NO;
    
    
    
    CGRect rc;
    rc = [UIScreen mainScreen].applicationFrame ;
    
    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(15, 75, rc.size.width-30, 90)];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.numberOfLines=4;
    labIntroudction.textColor=[UIColor blackColor];
    labIntroudction.text=@"开始扫描";
    //        [self.view addSubview:labIntroudction];
    
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, labIntroudction.frame.origin.y+labIntroudction.frame.size.height+10, rc.size.width-20    , rc.size.width-20)];
    imageView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:imageView];
    
    [self.view bringSubviewToFront:imageView];
    imageView.tag = 101;
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(60, CGRectGetMinY(imageView.frame), rc.size.width-120, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
    UIButton * scanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [scanButton setTitle:@"取消" forState:UIControlStateNormal];
    scanButton.frame = CGRectMake(100, imageView.frame.origin.y + imageView.frame.size.height+20.0f, 120, 40);
    [scanButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
    scanButton.hidden = NO;
    [self zbarView];
    [self.view bringSubviewToFront:_line];
    [self.view bringSubviewToFront:imageView];
    UILabel * lab2= [[UILabel alloc] initWithFrame:CGRectMake(15, scanButton.frame.origin.y + scanButton.frame.size.height+20, 290, 50)];
    lab2.backgroundColor = [UIColor clearColor];
    lab2.numberOfLines=2;
    lab2.textColor=[UIColor blackColor];
    lab2.text=@"";
    lab2.tag = 102;
    [self.view addSubview:lab2];
    
    //    CLAuthorizationStatus authStatus = [capturu authorizationStatusForMediaType:AVMediaTypeVideo];
    //    if(authStatus == kCLAuthorizationStatusDenied)
    //    {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
    //                                                        message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。"
    //                                                       delegate:self
    //                                              cancelButtonTitle:@"取消"
    //                                              otherButtonTitles:@"确定",nil];
    //        alert.tag = 701;
    //        [alert show];
    //
    //    }
    
    UILabel * jineL = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 50, 30)];
    jineL.text = @"金额";
    jineL.textColor = [UIColor greenColor];
    [self.view addSubview:jineL];
    
}

#pragma mark -- 按钮事件 --
-(void)openFlashButtonDown:(id)sender{
    int tormode = _readerView.torchMode;
    if (tormode == 0) {
        _readerView.torchMode = 1;
    }else{
        _readerView.torchMode = 0;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (buttonIndex==1) {
        //add by zeng,此方法iOS8以后才可以用
        if (&UIApplicationOpenSettingsURLString != NULL) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_readerView start];
}
- (void)viewWillDisappear:(BOOL)animated{
    [_readerView stop];
    
    BleService * bleser = [BleService shareInstance];
    [bleser ZcmDisConnect];
}

-(void)animation1
{
    CGRect rc,rr;
    rc = [UIScreen mainScreen].applicationFrame ;
    UIView *vw;
    vw = [self.view viewWithTag:101];
    rr = vw.frame;
    if (upOrdown == NO) {
        num ++;
        int cnt;
        cnt = rr.size.height - 40;
        _line.frame = CGRectMake(60, rr.origin.y+ 20+2*num, rc.size.width-120, 2);
        if (2*num == cnt) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(60, rr.origin.y+ 20+2*num, rc.size.width-120, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}
-(void)backAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
- (void) zbarView{
    ZBarReaderView *readerView = [[ZBarReaderView alloc]init];
    UIView *vw;
    CGRect r1;
    vw = [self.view viewWithTag:101];
    r1 = vw.frame;
    readerView.frame = self.view.frame;
    readerView.readerDelegate = self;
    //关闭闪光灯
    readerView.torchMode = 0;
    //扫描区域
    
    //处理模拟器
    if (TARGET_IPHONE_SIMULATOR) {
        ZBarCameraSimulator *cameraSimulator
        = [[ZBarCameraSimulator alloc]initWithViewController:self];
        cameraSimulator.readerView = readerView;
    }
    [self.view addSubview:readerView];
    //扫描区域计算
    readerView.scanCrop = CGRectMake(0.15, 0.1, 0.7, 0.8);
    _readerView = readerView;
}
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    CGFloat x,y,width,height;
    
    x = rect.origin.x / readerViewBounds.size.width;
    y = rect.origin.y / readerViewBounds.size.height;
    width = rect.size.width / readerViewBounds.size.width;
    height = rect.size.height / readerViewBounds.size.height;
    
    return CGRectMake(x, y, width, height);
}

- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image{
    
    lab = [self.view viewWithTag:102];
    for (ZBarSymbol *symbol in symbols) {
        NSLog(@"%@", symbol.data);
        NSString *str;
        
        str = symbol.data;
        lab.text = symbol.data;
        
        break;
        
        
        
    }
    [timer invalidate];
    _line.hidden = YES;
    [readerView stop];
    
    [self gotoBand:lab.text];
}

/*
 绑定需要分俩步
 1，链接蓝牙
 2，后台发起请求完成绑定动作，这样算是真的的绑定完成
 
 */

-(void)gotoBand:(NSString *)deviceName{
    //第一步链接蓝牙设备
    bandDeviceName = deviceName;

//    bandDeviceName = @"DCQ500000000000001";
    
    BleService * bleser = [BleService shareInstance];
    [bleser ZcmConnectPos];
    bleser.bandDeviceName = bandDeviceName;
    bleser.delegate = self;
    //链接成功回调处请求网络绑定设备
    
}

-(void)onZcmDidConnectBlueDevice{
    //蓝牙链接成功了。
    [self requestBand:bandDeviceName];
}

-(void) requestBand:(NSString*)string
{
    NSLog(@"%s",__func__);
    
    [[ZCMNetwork sharedAction] sendRequestBlock:^(NSObject *request) {
        
        // 方式1，在delegate 里面设置全局的scheme 和 host
        //方式2，在请求前设置URL，就是单独的URL。全局将不起作用。（特殊接口特殊处理）
        //        [request setZcm_url:@"https://www.lianyinggufen.com:1580/mpos/services/"];
        
        //zcm_url (如果设置了url，则不需要在设置scheme，host，path 属性)
        //        request.zcm_path = @"/v2/book/search";
        request.zcm_method = ZCMRequestMethodPOST;
        
        NSDictionary * bodyDic =[[NSDictionary alloc] initWithObjectsAndKeys:
                                 [GlobalMethod getUserInfo].account,@"USERMP",
                                 string,@"POSSN",
                                 nil];
        
        NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:QdbRequestBindTerm],@"CommandID",
                                    [NSNumber numberWithInteger:1],@"SeqID",
                                    [NSNumber numberWithInteger:0],@"NodeType",
                                    @"ios",@"NodeID",
                                    @"1.0.0",@"Version",
                                    @"",@"TokenID",
                                    bodyDic,@"Body",
                                    nil];
        request.zcm_params = parameters;
        
        //
        return request;
        
    } progress:nil success:^(ResponseObj * responseObject) {
        
        if (responseObject) {
            {
                if (responseObject.status == 1 || responseObject.status == 0) {
                    NSString *tmpResult = [responseObject.resultInfo objectForKey:@"TERMO"];
                    
                    if (tmpResult != nil && [tmpResult length] > 0) {
                        NSLog(@"bind data:%@", responseObject.resultInfo);
                        [GlobalMethod showGlobalPrompt:@"终端绑定成功" delay:1.5];
                        if (lab.text == nil || lab.text.length == 0) {
                            [GlobalMethod showGlobalPrompt:@"设备名称读取错误" delay:1.5];
                            return;
                        }
                        //保存机身号
                        UserInfo *user = [GlobalMethod getUserInfo];
                        user.possnId = lab.text;
                        [GlobalMethod setUserInfo:user];
                        
                        //绑定成功，清除下载参数标志，自动连接蓝牙
                        NSString *tmpKey = [lab.text stringByAppendingString:@"ENABLE"];
                        [[NSUserDefaults standardUserDefaults] setObject:@"DISABLE" forKey:tmpKey];
                        [[NSUserDefaults  standardUserDefaults] synchronize];
                        
                        [[GlobalMethod topViewController].navigationController popViewControllerAnimated:YES];
                        
                    }
                    
                }else if(responseObject.status == -1){
                    [GlobalMethod showGlobalPrompt:responseObject.message delay:1.5];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
            }
        }
    } failure:^(NSError * error){
        NSLog(@"error = %@",error);
    }];

    
}






- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    if ([info count]>2) {
        int quality = 0;
        ZBarSymbol *bestResult = nil;
        for(ZBarSymbol *sym in results) {
            int q = sym.quality;
            if(quality < q) {
                quality = q;
                bestResult = sym;
            }
        }
        [self performSelector: @selector(presentResult:) withObject: bestResult afterDelay: .001];
    }else {
        ZBarSymbol *symbol = nil;
        for(symbol in results)
            break;
        [self performSelector: @selector(presentResult:) withObject: symbol afterDelay: .001];
    }
    [picker dismissModalViewControllerAnimated:YES];
}

- (void) presentResult: (ZBarSymbol*)sym {
    if (sym) {
        NSString *tempStr = sym.data;
        if ([sym.data canBeConvertedToEncoding:NSShiftJISStringEncoding]) {
            tempStr = [NSString stringWithCString:[tempStr cStringUsingEncoding:NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
        }
        //       textLabel.text =  tempStr;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)onZcmFindBlueDevice:(CBPeripheral *)cbPeripheral{
    NSLog(@"%s \n peripheral name = %@",__FUNCTION__,cbPeripheral.name);
}




@end
