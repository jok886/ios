//
//  QdbSignViewController.m
//  zcm
//
//  Created by zcm on 15/7/27.
//  Copyright (c) 2015年 zcm. All rights reserved.
//

/*
 
 持卡人签名页面
 
 */
#import "QdbSignViewController.h"
#import "MyView.h"
#import "SKTradeResultController.h"
#import "ZcmButton.h"

#define kWarnViewHeight   100
#define kWarnViewWidth    40

@interface QdbSignViewController ()
{
    
//    UILabel *lable1;
//    UILabel *lable2;
    UILabel *lableTitle;
    int tradeResult;
}
@property(nonatomic,strong) UIImage *image;
@property(nonatomic,retain) MyView *myView;
@end

@implementation QdbSignViewController



@synthesize strCardNumber_, strAmount_,strBit14_,strBit23_,strBit55_,strPin_,strTrack2_,strTrack3_,strOrderNum,strPhoneNum,macValueData_;

@synthesize signData_;

@synthesize isIccCard_;

@synthesize strRateId;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.frame = [[UIScreen mainScreen] bounds];
    
    [self setSubView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Privte


- (void)setlblTitleHidden:(BOOL)hidden
{
    lableTitle.hidden = hidden;
}

-(void)setSubView
{
    self.view.backgroundColor = [UIColor clearColor];
    
    _myView = [[MyView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth-50, self.view.frame.size.height)];
    _myView.backgroundColor = [UIColor whiteColor];
    [_myView awakeFromNib];
    [_myView setLineColor:3];
    [self.view addSubview:_myView];
    
    __weak typeof(self) weakSelf = self;
    _myView.block = ^(BOOL isHidden)
    {
        [weakSelf setlblTitleHidden:isHidden];
    };
    
    UILabel* lable = [[UILabel alloc]initWithFrame: CGRectMake(100,_myView.frame.size.height/2-20, 200, 40)];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.text = @"请持卡人在此签名...";
    lable.textColor = gColorAlphaOf(155, 155, 155, 1);
    lable.font =[UIFont boldSystemFontOfSize:16];
    lable.transform =CGAffineTransformMakeRotation(270 *M_PI / 180.0);
    [_myView addSubview:lable];
    
    lable.center = CGPointMake(_myView.frame.size.width/2, _myView.frame.size.height/2);
    lableTitle = lable;
    
    CGFloat dis   = 20;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat btnWidth  = (screenSize.height - dis*4)/3;
    for (int i = 0; i < 3; i ++) {
        ZcmButton *btn = [ZcmButton buttonWithType:UIButtonTypeCustom];
        btn.heightLightWhenText = YES;
        btn.lightType           = ZcmButtonHeightLightOnForeground;
        btn.tag = i+10;
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius  = 5;
        btn.transform = CGAffineTransformMakeRotation(270 *M_PI / 180.0);
        btn.frame = CGRectMake(screenSize.width-50, dis+(btnWidth+dis)*i,44 , btnWidth);
        
        NSString *title = nil;
        UIColor *textColor = nil;
        UIColor *bgColor   = nil;
        
        if (i == 0) {
            title = @"签好了";
            textColor = [UIColor whiteColor];
            bgColor   = [UIColor blueColor];
        }
        else if (i == 1)
        {
            title = @"重签";
            textColor = [UIColor whiteColor];
            bgColor   = [UIColor blueColor];
        }
        else{
            title = @"返回";
            textColor = [UIColor blackColor];
            bgColor   = [UIColor lightGrayColor];
        }
        
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:textColor forState:UIControlStateNormal];
        [btn setBackgroundColor:bgColor];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btn];
    }
}

- (void)saveScreen {
    
    UIGraphicsBeginImageContext(_myView.bounds.size);//(CGSizeMake(_myView.bounds.size.width - 60,_myView.bounds.size.height-20));
    [_myView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    CGSize imagesize = image.size;
    NSLog(@"%f %f",imagesize.height,imagesize.width);
    UIImage *transImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationRight];
    
    self.image= [self reSizeImage:transImage toSize:CGSizeMake(200, 100)];
    
    
    float length = [UIImageJPEGRepresentation(self.image, 0.05) length]/1000;
    
    self.image = [UIImage imageWithData:UIImageJPEGRepresentation(self.image, 0.05)];
    
    
}


- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}

-(NSString*) getAmountString
{
    float yy = [strAmount_ floatValue];
    
    int mm = lroundf(yy * 100);
    
    NSString* tmp1 = [NSString stringWithFormat:@"%d", mm];
    
    NSMutableString * str = [NSMutableString string];
    if(tmp1.length <= 12){
        int numof0 = 12 - tmp1.length;
        for(int i = 0;i<numof0;i++)
        {
            [str appendString:@"0"];
        }
    }
    
    [str appendString:tmp1];
    return str;

}

-(void) resetTerm
{

}





-(void) popToResultViewController
{
    SKTradeResultController * vc = [[SKTradeResultController alloc] initWithNibName:@"SKTradeResultController" bundle:nil];
    vc.strPrompt = @"交易中止，请重新交易";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - request
-(void) RequestTrade
{
    NSLog(@"SKSignViewController macValue base64 is %@",[GlobalMethod encodeBase64Data:macValueData_ padded:YES]);

    
    [[ZCMNetwork sharedAction] sendRequestBlock:^(NSObject *request) {
        
        // 方式1，在delegate 里面设置全局的scheme 和 host
        //方式2，在请求前设置URL，就是单独的URL。全局将不起作用。（特殊接口特殊处理）
        //        [request setZcm_url:@"https://www.lianyinggufen.com:1580/mpos/services/"];
        
        //zcm_url (如果设置了url，则不需要在设置scheme，host，path 属性)
        //        request.zcm_path = @"/v2/book/search";
        request.zcm_method = ZCMRequestMethodPOST;
        
        NSString *frontStr = [GlobalMethod encodeBase64Data:UIImagePNGRepresentation(self.image) padded:YES];
        //    float length = [[NSData dataFromBase64String:frontStr] length]/1000;
        NSDictionary * bodyDic =[[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"2610000000000000",@"BIT53",
                                 [GlobalMethod encodeBase64String:strTrack2_],@"BIT35",
                                 [GlobalMethod encodeBase64String:([strPin_ length] > 0)?(strPin_):(@"")],@"BIT52",
                                 strOrderNum,@"ORDERID",
                                 [GlobalMethod encodeBase64String:strTrack3_],@"BIT36",
                                 [GlobalMethod encodeBase64String:[self getAmountString]],@"BIT4",
                                 [GlobalMethod encodeBase64String:strCardNumber_],@"BIT2",
                                 strRateId,@"RATEID",
                                 [GlobalMethod getUserInfo].account,@"USERMP",
#if LY_ISOpen
                                 [GlobalMethod getUserInfo].possnId,@"POSSN",//K2000301063
#else
                                 [GlobalMethod getUserInfo].possnId,@"POSSN",
#endif
                                 ((isIccCard_)?([GlobalMethod encodeBase64String:strBit55_]):(@"")),@"BIT55",
                                 @"",@"BIT62",
                                 [GlobalMethod encodeBase64Data:macValueData_ padded:YES],@"BIT64",
                                 @""/*([strPin_ length]>0?@"071":@"072")*/,@"BIT22",//非接才写
                                 ((isIccCard_)?(strBit23_):(@"")),@"BIT23",
                                 _latitude_>0?[NSString stringWithFormat:@"%.6f",_latitude_]/*[NSNumber numberWithFloat:_latitude_]*/:@"",@"LATITUDE",_longitude_>0?[NSString stringWithFormat:@"%.6f",_longitude_]/*[NSNumber numberWithFloat:_longitude_]*/:@"",@"LONGITUDE",
                                 frontStr,@"SIGNPIC",
                                 strPhoneNum,@"MOBILENUM",
                                 ((isIccCard_)?(strBit14_):(strBit14_ == nil)?@"":strBit14_),@"BIT14",
                                 (_isMerchant?@"2":@"1"),@"MICROMER",
                                 _audit,@"AUDIT",
                                 _OCR,@"OCR",
                                 [[Rsa_object sharedInstance] getPhoneSN],@"DATA_IDENTITY",
                                 @"1",@"KEYTYPE",
                                 nil];
        
        NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:QdbRequestChanging],@"CommandID",
                                    [NSNumber numberWithInteger:1],@"SeqID",
                                    [NSNumber numberWithInteger:0],@"NodeType",
                                    @"ios",@"NodeID",
                                    @"1.0.0",@"Version",
                                    @"",@"TokenID",
                                    signData_,@"Sign",
                                    bodyDic,@"Body",
                                    nil];
        
        
        request.zcm_params = parameters;
        
        //
        return request;
        
    } progress:nil success:^(ResponseObj * responseObject) {
        
        if (responseObject) {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:strOrderNum];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"-------刷卡测试 %@",responseObject);
            //        int state;
            if (responseObject.status == 1 || responseObject.status == 0)
            {
                NSString *sdata = @"";
                NSString *errCode = @"";
                
                NSString *tmpBit39 = DealWithJSONStringValue([responseObject.resultInfo objectForKey:@"BIT39"]);
                NSString *tmpBit55 = [responseObject.resultInfo objectForKey:@"BIT55"];
                NSString *fundStatus = [responseObject.resultInfo objectForKey:@"FUNDSTATE"];
                NSString *salesSlipUrl = [responseObject.resultInfo objectForKey:@"URL"];
                
                if (tmpBit39 != nil && [tmpBit39 isEqualToString:@"00"])
                {
                    sdata = @"交易成功。";
                    tradeResult = 0;
                }
                else
                {
                    
                    if ([tmpBit39 isEqualToString:@"L1"]){
                        //重新签到
                        NSString * keyForLogin = [[GlobalMethod getUserInfo].possnId stringByAppendingString:@"TERMLOGIN"];
                        
                        NSDate * oldDate = [[NSUserDefaults standardUserDefaults] objectForKey:keyForLogin];
                        
                        NSDate *lastDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:oldDate];
                        [[NSUserDefaults standardUserDefaults] setObject:lastDay forKey:keyForLogin];
                        
                        // add by zhencanbing 不能仅更新本地保存时间 要立马去重新签到
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"TERMAGAINLOGIN" object:nil];
                        
                        
                    }
                    
                    errCode = [responseObject.resultInfo objectForKey:@"BIT39"];
                    
                    if([responseObject.resultInfo objectForKey:@"RETURNMSG"] != nil && [[responseObject.resultInfo objectForKey:@"RETURNMSG"] length] > 0)
                    {
                        sdata = [responseObject.resultInfo objectForKey:@"RETURNMSG"];
                    }
                    
                    tradeResult = 1;
                }
                
//                
//                if(tmpBit55 != nil && [tmpBit55 length] > 0)
//                {
//                    [self updateBit55ToTerm:[GlobalMethod decodeBase64StringData:tmpBit55]];
//                }
//                else
//                {
//                    if(isIccCard_)
//                    {
//                        [self tellTermIccResult:tradeResult];
//                    }
//                }
                
                SKTradeResultController * vc = [[SKTradeResultController alloc] initWithNibName:@"SKTradeResultController" bundle:nil];
                vc.strPrompt = sdata;
                vc.trade = (tradeResult == 0)?(1):(2);
                //            vc.isNeedEndPBOC = TRUE;
                vc.isIccCard_ = isIccCard_;
                vc.cardNum = strCardNumber_;
                vc.orderID = strOrderNum;
                vc.tradeAmount = strAmount_;
                vc.tradeDate = [responseObject.resultInfo objectForKey:@"TRADETIME"];
                if ([[responseObject.resultInfo objectForKey:@"FLAG"]isEqualToString:@"0"]) {
                    vc.isNeedBindCard = YES;
                }else{
                    vc.isNeedBindCard = NO;
                }
                
                vc.salesSlipUrl = salesSlipUrl;
                vc.errorCode = errCode;
                vc.tradeCharge = _tradeCharge;
                
                if(tradeResult == 0)
                {
                    vc.isFrozen = ([fundStatus intValue] == 1)?(YES):(NO);
                }
                
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if(responseObject.status == -1)
            {
                
                [self resetTerm];
                [GlobalMethod showGlobalPrompt:responseObject.message delay:2.0];
                [self popToResultViewController];
            }
            
        }
    } failure:^(NSError * error){
        NSLog(@"error = %@",error);
    }];

//    [[JLNetworkController shareController] startNetworkRequest:JLRequestChanging parameters:parameters callBackDelegate:self];
}




#pragma mark - UIButton aciton
- (void)buttonClick:(UIButton *)btn{
    
    switch (btn.tag) {
        case 10: { //签好了
            if([_myView isDrawAnything])
            {
                [GlobalMethod showNetworkActivity];
                [self saveScreen];
                [GlobalMethod hideNetworkActivity];
                [self RequestTrade];
            }
            else
            {
                [GlobalMethod showGlobalPrompt:@"请签名" delay:1.5];
            }
        }
            break;
        case 11: { //重签
            [_myView clear];
        }
            break;
        case 12: //返回
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
}


@end
