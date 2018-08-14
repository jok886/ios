//
//  WWZUDPSocket.m
//  wwz
//
//  Created by wwz on 16/6/18.
//  Copyright © 2016年 cn.szwwz. All rights reserved.
//

#import "WWZUDPSocket.h"

#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

@interface WWZUDPSocket ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;

@end


@implementation WWZUDPSocket

- (void)startListen:(uint16_t)port{

    NSError *error = nil;
    if (![self.udpSocket bindToPort:port error:&error])
        NSLog(@"error bind port: %@", [error localizedDescription]);
    
    if (![self.udpSocket enableBroadcast:YES error:&error])
        NSLog(@"Error enableBroadcast: %@", [error localizedDescription]);
    
    if (![self.udpSocket beginReceiving:&error])
        NSLog(@"Error receiving: %@", [error localizedDescription]);

}

/**
 *  广播数据
 */
- (void)broadcastMessage:(NSString *)message toPort:(uint16_t)port{
    
    [self sendMessage:message toHost:@"255.255.255.255" port:port];
}

/**
 *  往指定ip发送数据
 */
- (void)sendMessage:(NSString *)message toHost:(NSString *)host port:(uint16_t)port{

    [self sendData:[message dataUsingEncoding:NSUTF8StringEncoding] toHost:host port:port];
}
/**
 *  往指定ip发送数据
 */
- (void)sendData:(NSData *)data toHost:(NSString *)host port:(uint16_t)port{
    
    [self.udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:0];
}

/**
 *  关闭socket
 */
- (void)close{
    
    [self.udpSocket close];
}
#pragma mark - GCDAsyncUdpSocketDelegate
/**
 *  数据已发出
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    
//    WZLog();
}
/**
 *  updSocket关闭
 */
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    
   NSLog(@"error %@", error);
}
/**
 *  收到upd数据
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    
    NSString *host = [GCDAsyncUdpSocket hostFromAddress:address];
    
    if ([self.delegate respondsToSelector:@selector(udpSocket:didReceiveData:fromHost:)]) {
        [self.delegate udpSocket:self didReceiveData:data fromHost:host];
    }
}

#pragma mark - updSocket
- (GCDAsyncUdpSocket *)udpSocket{
    if (!_udpSocket) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_udpSocket setIPv6Enabled:YES];
    }
    return _udpSocket;
}

@end
