//
//  WWZTCPSocketServer.h
//  wwz
//
//  Created by wwz on 17/2/10.
//  Copyright © 2017年 cn.szwwz. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SERVER_ERROR_NOTI_NAME;// 收到错误数据通知

@class WWZTCPSocketServer;

@protocol WWZTCPSocketServerDelegate <NSObject>

@optional

/**
 *  收到新的连接
 */
- (void)tcpSocketServer:(WWZTCPSocketServer *)tcpSocketServer didAcceptNewSocketHost:(NSString *)newHost;

/**
 *  socket收到数据回调
 */
- (void)tcpSocketServer:(WWZTCPSocketServer *)tcpSocketServer didReadResult:(id)result fromHost:(NSString *)formHost;

/**
 *  socket断开连接
 */
- (void)tcpSocketServer:(WWZTCPSocketServer *)tcpSocketServer didDisconnectHost:(NSString *)host;
@end

@interface WWZTCPSocketServer : NSObject

@property (nonatomic, weak) id<WWZTCPSocketServerDelegate> tcpSocketServerDelegate;

/**
 *  读取结束字符
 */
@property (nonatomic, copy) NSString *endKey;

/**
 *  打印输出
 */
@property (nonatomic, getter=isCanLogging) BOOL canLogging;

/**
 *  监听端口
 */
- (BOOL)socketListeningPort:(uint16_t)port;

/**
 *  断开所有连接
 */
- (void)disconnectSocket;

/**
 *  发送信息到指定socket host
 */
- (void)sendDataToSocketWithHost:(NSString *)host message:(NSString *)message;
@end
