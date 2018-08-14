//
//  WWZTCPSocketClient.m
//  SmartHome_iPad
//
//  Created by wwz on 16/3/2.
//  Copyright © 2016年 zgkjd. All rights reserved.
//

#import "WWZTCPSocketClient.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

//#ifdef DEBUG // 调试
//
//#define WZLog(fmt, ...) NSLog((@"%s " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__)
//
//#else // 发布
//
//#define WZLog(...)
//
//#endif

// G-C-D
// 主线程
#define WZ_MAIN_GCD(block) dispatch_async(dispatch_get_main_queue(),block)

@interface WWZTCPSocketClient ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

@end

@implementation WWZTCPSocketClient

@synthesize isConnecting = _isConnecting;

static int const WWZ_TCPSOCKET_CONNECT_TIMEOUT = 4;

static int const WWZ_TCPSOCKET_READ_TIMEOUT = -1;

static int const WWZ_TCPSOCKET_WRITE_TAG = 1;

static int const WWZ_TCPSOCKET_READ_TAG = 0;


- (void)setEndKeyString:(NSString *)endKeyString{
    
    _endKeyString = endKeyString;
    
    self.endKeyData = [endKeyString dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - 连接socket
- (void)connectToHost:(NSString*)host onPort:(uint16_t)port{

    _isConnecting = YES;
    
    [self disconnectSocket];
    
    NSError *error = nil;
    
    if (![self.socket connectToHost:[self p_convertedHostFromHost:host] onPort:port withTimeout:WWZ_TCPSOCKET_CONNECT_TIMEOUT error:&error]||error) {
        NSLog(@"connect fail error：%@", error);
    }
}

#pragma mark - 断开socket
- (void)disconnectSocket{
    
    if (self.socket.isConnected) {
        
        [self.socket disconnect];
        
        NSLog(@"disconnect socket");
    }
}

#pragma mark - 发送请求
- (void)sendDataToSocketWithString:(NSString *)string{
    
    if (!string||string.length == 0) {
        return;
    }
    if ([string rangeOfString:@"'"].length>0) {
        string = [string stringByReplacingOccurrencesOfString:@"'" withString:@""];
    }
//    WZLog(@"%@", string);
    // 根据服务器要求发送固定格式的数据
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [self sendDataToSocketWithData:data];
    
}
- (void)sendDataToSocketWithData:(NSData *)data{

    if (!data||data.length == 0) {
        return;
    }
    [self.socket writeData:data withTimeout:-1 tag:WWZ_TCPSOCKET_WRITE_TAG];
}
#pragma mark - GCDAsyncSocketDelegate
#pragma mark - 连接成功回调
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    
    NSLog(@"+++connect to server success+++");
    
    _isConnecting = NO;
    
    if ([self.tcpDelegate respondsToSelector:@selector(tcpSocket:didConnectToHost:port:)]) {
        WZ_MAIN_GCD(^{
            [self.tcpDelegate tcpSocket:self didConnectToHost:host port:port];
        });
    }
    
    [self p_readData];

}
#pragma mark - socket断线回调
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{

    NSLog(@"+++socket disconnect+++");
    
    _isConnecting = NO;
    
    if ([self.tcpDelegate respondsToSelector:@selector(tcpSocket:didDisconnectWithError:)]) {
        WZ_MAIN_GCD(^{
            [self.tcpDelegate tcpSocket:self didDisconnectWithError:err];
        });
    }
    
}
#pragma mark - 写成功
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    
    // 写成功后开始读数据
    [self p_readData];
}
#pragma mark - 收到数据回调
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    if (!data || data.length == 0) {
        
        [self p_readData];
        
        return;
    }
    if (self.endKeyData) {
        
        if (data.length <= self.endKeyData.length) {
            
            [self p_readData];
            
            return;
        }
        // 删掉最后self.endDataKey'\n'
        data = [data subdataWithRange:NSMakeRange(0, data.length-self.endKeyData.length)];
    }
    
    // data==>string
    NSString *readString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    NSLog(@"+++++read data length==>%d+++++", (int)data.length);
    
    if (!readString||readString.length == 0) {// data转string失败
        
        if (data.length > 0) {
            
            if ([self.tcpDelegate respondsToSelector:@selector(tcpSocket:didReadResult:)]) {
                
                WZ_MAIN_GCD(^{
                    
                    [self.tcpDelegate tcpSocket:self didReadResult:data];
                });
            }
        }
        
        [self p_readData];
        return;
    }

    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {// json解析失败
        
        if ([self.tcpDelegate respondsToSelector:@selector(tcpSocket:didReadResult:)]) {
            
            WZ_MAIN_GCD(^{
                [self.tcpDelegate tcpSocket:self didReadResult:readString];
            });
        }
    }else{// json解析成功
        
        if ([self.tcpDelegate respondsToSelector:@selector(tcpSocket:didReadResult:)]) {
            
            WZ_MAIN_GCD(^{
                
                [self.tcpDelegate tcpSocket:self didReadResult:result];
            });
        }
    }
    // 读完当前数据后继续读数
    [self p_readData];
}
/**
 *  读取数据
 */
- (void)p_readData{

    if (self.endKeyData) {
        // 读到'\n'
        [self.socket readDataToData:self.endKeyData withTimeout:WWZ_TCPSOCKET_READ_TIMEOUT tag:WWZ_TCPSOCKET_READ_TAG];
    }else{
        [self.socket readDataWithTimeout:WWZ_TCPSOCKET_READ_TIMEOUT tag:WWZ_TCPSOCKET_READ_TAG];
    }
}

/**
 *  ip转换(ipv6 ip转换)
 *
 *  @param host 旧host
 *
 *  @return 新ip
 */
- (NSString *)p_convertedHostFromHost:(NSString *)host{
    
    NSError *err = nil;
    
    NSMutableArray *addresses = [GCDAsyncSocket lookupHost:host port:0 error:&err];
    
    NSData *address4 = nil;
    NSData *address6 = nil;
    
    for (NSData *address in addresses)
    {
        if (!address4 && [GCDAsyncSocket isIPv4Address:address])
        {
            address4 = address;
        }
        else if (!address6 && [GCDAsyncSocket isIPv6Address:address])
        {
            address6 = address;
        }
    }
    
    NSString *ip;
    
    if (address6) {
        NSLog(@"===ipv6===：%@",[GCDAsyncSocket hostFromAddress:address6]);
        ip = [GCDAsyncSocket hostFromAddress:address6];
    }else {
        NSLog(@"===ipv4===：%@",[GCDAsyncSocket hostFromAddress:address4]);
        ip = [GCDAsyncSocket hostFromAddress:address4];
    }
    
    return ip;
    
}
#pragma mark - getter
/**
 *  socket
 */
- (GCDAsyncSocket *)socket{
    if (!_socket) {
        //1.创建串行队列，队列(queue)中的任务只会顺序执行
        dispatch_queue_t socketQueue = dispatch_queue_create("FirstSerialQueue", DISPATCH_QUEUE_SERIAL);
        
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
        _socket.IPv4PreferredOverIPv6 = NO;
    }
    return _socket;
}

/**
 *  socket连接状态
 */
- (BOOL)isConnected{
    
    return self.socket.isConnected;
}



@end
