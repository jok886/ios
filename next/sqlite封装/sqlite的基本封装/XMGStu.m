//
//  XMGStu.m
//  sqlite的基本封装
//
//  Created by 小码哥 on 2016/12/3.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "XMGStu.h"

@implementation XMGStu

- (NSString *)primaryKey {
    return @"nuM";
}

- (NSDictionary *)renameDic {
    
    return @{
            @"name": @"nAme",
            @"myName2": @"myName"
             };

}


//- (NSArray *)ignoreIvarNames {
//    
//    return @[@"xxx"];
//}

@end
