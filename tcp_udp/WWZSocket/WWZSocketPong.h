//
//  WWZSocketPong.h
//  WWZSocket
//
//  Created by apple on 2017/4/23.
//  Copyright © 2017年 tijio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WWZSocketPong : NSObject

@property (nonatomic, assign) NSTimeInterval timeout;

@property (nonatomic, copy) NSString *api_name;

- (instancetype)initWithApiName:(NSString *)apiName timeout:(NSTimeInterval)timeout timeoutHandle:(void(^)())timeoutHandle;

- (void)start;

- (void)stop;
@end
