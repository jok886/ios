//
//  WWZSocketPong.m
//  WWZSocket
//
//  Created by apple on 2017/4/23.
//  Copyright © 2017年 tijio. All rights reserved.
//

#import "WWZSocketPong.h"
#import "WWZSocketRequest.h"
@interface WWZSocketPong ()

@property (nonatomic, copy) void(^timeoutHandle)();

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation WWZSocketPong

- (instancetype)initWithApiName:(NSString *)apiName timeout:(NSTimeInterval)timeout timeoutHandle:(void(^)())timeoutHandle
{
    self = [super init];
    if (self) {
        
        self.timeout = timeout;
        self.api_name = apiName;
        self.timeoutHandle = timeoutHandle;
    }
    return self;
}

- (void)start{

    if (!_timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeout target:self selector:@selector(execTimer) userInfo:nil repeats:YES];
    }
}

- (void)stop{

    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)execTimer{

    [WWZSocketRequest shareInstance].requestTimeout = 1;
    
    [[WWZSocketRequest shareInstance] request:self.api_name parameters:@{} success:^(id result) {
       
        [WWZSocketRequest shareInstance].requestTimeout = 10;
        
    } failure:^(NSError *error) {
        
        [WWZSocketRequest shareInstance].requestTimeout = 10;
        
        self.timeoutHandle();
    }];
}
@end
