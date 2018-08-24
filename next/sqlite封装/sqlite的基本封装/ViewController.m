//
//  ViewController.m
//  sqlite的基本封装
//
//  Created by 小码哥 on 2016/12/3.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "ViewController.h"
//#import "XMGSqliteTool.h"

#import "XMGSqliteModelTool.h"
#import "XMGStu.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
   
//   NSArray *result = [XMGSqliteTool querySql:@"select * from t_stu" withUID:nil];
//    
//    NSLog(@"%@", result);
    
//    [XMGSqliteModelTool createTableWithModelClass:[XMGStu class] withUID:nil];
    
    XMGStu *stu = [XMGStu new];
//    stu.age2 = 22222;
//    stu.name = @"sslisi";
    stu.score2 = 19;
    stu.nuM = 4;
    stu.nAme = @"adasf";
    stu.myName2 = @"hahahahahhhahh";
    stu.name2 = [@[@"2", @"a"] mutableCopy];
//    stu.name2 = @"aa";
    stu.dic = [@{
                @"吃饭了吗": @"chile",
                @"吃哦的啥": @"管你啥事"
                 } mutableCopy];
//    stu.name2 = @"wangerxiao";


    BOOL isSuccess = [XMGSqliteModelTool createTableWithModelClass:[XMGStu class] withUID:nil];
    if (isSuccess) {
        NSLog(@"成功");
    }else {
        NSLog(@"失败");
    }

//    sql注入式攻击
    
//    " ' or '1' = '1"
//    
//    "select * from user where account = 'zhangsan' and password = '' or '1' = '1'";
    
//    [XMGSqliteModelTool saveModel:stu uid:nil];

    BOOL res = [XMGSqliteModelTool saveModel:stu uid:nil];
    if (res) {
        NSLog(@"yes");
    }else {
        NSLog(@"no");
    }
    
    
   NSArray *result =  [XMGSqliteModelTool queryAllModels:[XMGStu class] uid:nil];
    NSLog(@"%@", result);
//
//    NSArray *result = [XMGSqliteModelTool queryModels:[XMGStu class] key:@"num" relation:XMGSqliteModelToolRelationTypeLess value:@(6) uid:nil];
//    
//    
////    num > 4 并且, score = 18;
//    
//    [XMGSqliteModelTool queryModels:[XMGStu class] key:@[@"num", @"score"] relation:@[@(XMGSqliteModelToolRelationTypeGreater), @(XMGSqliteModelToolRelationTypeEqual)] value:@[@"4", @"18"] nao:@[@(XMGSqliteModelToolNAOAnd)] uid:nil];
//    
//    
//    NSLog(@"%@",result);
}


@end
