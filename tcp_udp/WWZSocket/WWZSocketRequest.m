//
//  WWZSocketRequest.m
//  wwz
//
//  Created by wwz on 16/6/17.
//  Copyright © 2016年 cn.szwwz. All rights reserved.
//

#import "WWZSocketRequest.h"
#import "WWZTCPSocketClient.h"

@interface WWZSocketRequestModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) void(^success)(id);
@property (nonatomic, copy) void(^failure)(NSError *);

- (instancetype)initWithName:(NSString *)name success:(void(^)(id))success failure:(void(^)(NSError *))failure;

@end

@implementation WWZSocketRequestModel

- (instancetype)initWithName:(NSString *)name success:(void(^)(id))success failure:(void(^)(NSError *))failure
{
    self = [super init];
    if (self) {
        
        self.name = name;
        self.success = success;
        self.failure = failure;
    }
    return self;
}

@end


NSString *const NOTI_PREFIX = @"wwz";

@interface WWZSocketRequest ()

@property (nonatomic, strong) NSMutableArray *mRequestModels;

@end

@implementation WWZSocketRequest

static WWZSocketRequest *_instance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)shareInstance{

    if (!_instance) {
        _instance = [[WWZSocketRequest alloc] init];
    }
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _mRequestModels = [NSMutableArray array];
        
        self.requestTimeout = 10;

    }
    return self;
}

/**
 *  SOCKET请求
 *  @param api          接口名
 *  @param parameters   参数：json格式的字典
 *  @param success      success回调
 *  @param failure      failure回调
 */
- (void)request:(NSString *)api
    parameters:(id)parameters
       success:(void(^)(id result))success
       failure:(void(^)(NSError *error))failure{

    if (!self.tcpSocket) {
        NSLog(@"请先调用(-setTcpSocket:app_param:co_param:)设置socket相关参数");
        return;
    }
    [self request:self.tcpSocket api:api parameters:parameters success:success failure:failure];
}

/**
 *  SOCKET请求
 *
 *  @param socket       WWZTCPSocketClient
 *  @param api          接口名
 *  @param parameters   参数：json格式的字典
 *  @param success      success回调
 *  @param failure      failure回调
 */
- (void)request:(WWZTCPSocketClient *)socket
            api:(NSString *)api
     parameters:(id)parameters
        success:(void(^)(id result))success
        failure:(void(^)(NSError *error))failure{
    
    NSString *message = [self p_formatCmdWithApiName:api parameters:parameters];
    if (!message) {
        NSLog(@"请求格式不正确");
        return;
    }
    [self request:socket api:api message:message success:success failure:failure];
}

/**
 *  SOCKET请求
 *
 *  @param api          接口名
 *  @param message      发送的完整消息指令
 *  @param success      success回调
 *  @param failure      failure回调
 */
- (void)request:(NSString *)api
        message:(NSString *)message
        success:(void(^)(id result))success
        failure:(void(^)(NSError *error))failure{
    
    if (!self.tcpSocket) {
        NSLog(@"请先调用(-setTcpSocket:app_param:co_param:)设置socket相关参数");
        return;
    }
    [self request:self.tcpSocket api:api message:message success:success failure:failure];
}
/**
 *  SOCKET请求
 *
 *  @param socket       WWZTCPSocketClient
 *  @param api          接口名
 *  @param message      发送的完整消息指令
 *  @param success      success回调
 *  @param failure      failure回调
 */
- (void)request:(WWZTCPSocketClient *)socket
            api:(NSString *)api
        message:(NSString *)message
        success:(void(^)(id result))success
        failure:(void(^)(NSError *error))failure{

    NSData *data = [[message stringByReplacingOccurrencesOfString:@"'" withString:@""] dataUsingEncoding:NSUTF8StringEncoding];
    [self request:socket api:api data:data success:success failure:failure];
}

/**
 *  SOCKET请求
 *
 *  @param socket       WWZTCPSocketClient
 *  @param api          接口名
 *  @param data         发送的完整消息指令
 *  @param success      success回调
 *  @param failure      failure回调
 */
- (void)request:(WWZTCPSocketClient *)socket
           api:(NSString *)api
          data:(NSData *)data
       success:(void(^)(id result))success
       failure:(void(^)(NSError *error))failure{
    
    NSString *noti_name = [NSString stringWithFormat:@"%@_%@", NOTI_PREFIX, api];
    
    if (!success && !failure) {
        
        [socket sendDataToSocketWithData:data];
        return;
    }
    
    // 添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_get_result_noti:) name:noti_name object:nil];
    
    // 发送请求
    [socket sendDataToSocketWithData:data];
    
    
    WWZSocketRequestModel *model = [[WWZSocketRequestModel alloc] initWithName:noti_name success:success failure:failure];
    
    [self.mRequestModels addObject:model];
    
    // 超时处理
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.requestTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        for (WWZSocketRequestModel *model in self.mRequestModels) {
            
            if ([model.name isEqualToString:noti_name] && model.failure) {
                
                NSNotification *noti = [NSNotification notificationWithName:noti_name object:nil userInfo:nil];
                
                [self p_get_result_noti:noti];
            }
        }
    });
}
#pragma mark - 通知
/**
 *  收到通知，通知名"wwz_[api_name]"
 *
 *  @param noti @{retcode : retmsg}
 */
- (void)p_get_result_noti:(NSNotification *)noti{
    
    WWZSocketRequestModel *removeModel = nil;
    
    for (WWZSocketRequestModel *model in self.mRequestModels) {
        
        if (![model.name isEqualToString:noti.name]) {
            continue;
        }
        
        removeModel = model;
        
        if (noti.object) {// 成功
            
            model.success(noti.object);
            
        }else {// 失败
        
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"error": @"request time out"}];
            model.failure(error);
        }
        break;
    }
    // 移除block
    [self.mRequestModels removeObject:removeModel];
    
    if ([self p_canRemoveObserver:noti.name]) {
        
        // 移除通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    }
    
}

- (BOOL)p_canRemoveObserver:(NSString *)name{

    for (WWZSocketRequestModel *model in self.mRequestModels) {
        
        if ([model.name isEqualToString:name]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - help
/**
 *  格式化指令
 */
- (NSString *)p_formatCmdWithApiName:(NSString *)apiName parameters:(id)parameters{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) return nil;
    
    NSString *param = [[[[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"  \"" withString:@"\""] stringByReplacingOccurrencesOfString:@" : " withString:@":"];
    
    return [[self.api_model stringByReplacingOccurrencesOfString:@"[api]" withString:apiName] stringByReplacingOccurrencesOfString:@"[param]" withString:param];
}


@end
