//
//  WWZUDPSocket.h
//  wwz
//
//  Created by wwz on 16/6/18.
//  Copyright © 2016年 cn.szwwz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WWZUDPSocket;

@protocol WWZUDPSocketDelegate <NSObject>

@optional

/**
 *  收到数据回调
 *
 *  @param udpSocket udpSocket
 *  @param data      receiveData
 *  @param host      ip
 */
- (void)udpSocket:(WWZUDPSocket *)udpSocket didReceiveData:(NSData *)data fromHost:(NSString *)host;

@end


@interface WWZUDPSocket : NSObject

@property (nonatomic, weak) id<WWZUDPSocketDelegate> delegate;

/**
 *  开始监听
 *  @param port  监听的端口号
 */
- (void)startListen:(uint16_t)port;

/**
 *  广播数据
 */
- (void)broadcastMessage:(NSString *)message toPort:(uint16_t)port;

/**
 *  往指定ip发送数据
 */
- (void)sendMessage:(NSString *)message toHost:(NSString *)host port:(uint16_t)port;

/**
 *  往指定ip发送数据
 */
- (void)sendData:(NSData *)data toHost:(NSString *)host port:(uint16_t)port;
/**
 *  关闭socket
 */
- (void)close;

@end
