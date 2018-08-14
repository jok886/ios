//
//  WWZTCPSocketServer.m
//  wwz
//
//  Created by wwz on 17/2/10.
//  Copyright © 2017年 cn.szwwz. All rights reserved.
//

#import "WWZTCPSocketServer.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

#define WZLog(fmt, ...) self.isCanLogging ? NSLog((@"%s " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__) : nil

#define WWZ_BACK_GCD(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
// 主线程
#define WWZ_MAIN_GCD(block) dispatch_async(dispatch_get_main_queue(),block)


NSString *const SERVER_ERROR_NOTI_NAME = @"wwz_server_error_noti";

@interface NSString (Json)
/**
 *  json字符串格式化
 */
- (NSString *)wwz_json;

@end

@interface WWZTCPSocketServer ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

// @{host:socket}
@property (nonatomic, strong) NSMutableDictionary *mConnectedSocketsDict;

@end

@implementation WWZTCPSocketServer

static int client_tag = 0;
static float read_timeout = -1;

#pragma mark - 开始监听
- (BOOL)socketListeningPort:(uint16_t)port{
    
    NSError *error = nil;
    if (![self.socket acceptOnPort:port error:&error]) {
        WZLog(@"listening failed");
        return NO;
    }
    WZLog(@"tcp start listening on port:%d", self.socket.localPort);
    
    // 心跳
    [self p_socketPong];
    
    return YES;
}

#pragma mark - 断开socket
- (void)disconnectSocket{
    
    WZLog(@"断开socket");
    [self.socket disconnect];
    
    [self.mConnectedSocketsDict enumerateKeysAndObjectsUsingBlock:^(NSString *host, GCDAsyncSocket *socket, BOOL * _Nonnull stop) {
        [socket disconnect];
    }];

    [self.mConnectedSocketsDict removeAllObjects];
}

#pragma mark - 发送请求
- (void)sendDataToAllConnectedSocket:(NSString *)message{
    
    [self.mConnectedSocketsDict enumerateKeysAndObjectsUsingBlock:^(NSString *host, GCDAsyncSocket *socket, BOOL * _Nonnull stop) {

        [self sendDataToSocketWithHost:host message:message];
    }];
}
- (void)sendDataToSocketWithHost:(NSString *)host message:(NSString *)message{

    if (!message||message.length == 0) {
        return;
    }
    if ([message rangeOfString:@"'"].length>0) {
        message = [message stringByReplacingOccurrencesOfString:@"'" withString:@""];
    }
    WZLog(@"%@", message);
    // 根据服务器要求发送固定格式的数据
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    GCDAsyncSocket *socket = self.mConnectedSocketsDict[host];
    
    if (socket) {
        [socket writeData:data withTimeout:-1 tag:client_tag];
    }
}
#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{

    NSString *host = [newSocket connectedHost];
    UInt16 port = [newSocket connectedPort];
    
    self.mConnectedSocketsDict[host] = newSocket;
    
    WZLog(@"accepted client success:%@, host:%@, port:%d，count:++%d", [NSThread currentThread], host, port,(int)self.mConnectedSocketsDict.count);
    // 监听新socket的数据，数到/r/n
    [self p_readDataWithSocket:newSocket tag:client_tag];
    
    WWZ_MAIN_GCD(^{
        if ([self.tcpSocketServerDelegate respondsToSelector:@selector(tcpSocketServer:didAcceptNewSocketHost:)]) {
            [self.tcpSocketServerDelegate tcpSocketServer:self didAcceptNewSocketHost:host];
        }
    });
   
}
/**
 *  写回调
 *
 *  @param sock 执行写操作的socket
 *  @param tag  tag
 */
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    WZLog(@"write_socket:%@:%@, tag:%ld", [NSThread currentThread], [sock connectedHost], tag);
    //    if (tag == sever_tag) {// 服务器标识
    //        WZLog(@"-*--*-*-*-*-*-*-*-*--");
    //        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:read_timeout tag:0];
    //    }
    //    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:read_timeout tag:0];
}

#pragma mark - 收到数据回调
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    if (!data || data.length == 0) {
        
        [self p_readDataWithSocket:sock tag:(int)tag];
        
        return;
    }
    if (_endKey) {
        
        if (data.length <= self.endDataKey.length) {
            
            [self p_readDataWithSocket:sock tag:(int)tag];
            
            return;
        }
        // 删掉最后self.endDataKey'\n'
        data = [data subdataWithRange:NSMakeRange(0, data.length-self.endDataKey.length)];
    }
    
    // data==>string
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    WZLog(@"+++++socket host==>%@, data length==>%d, json format==>%@+++++", [sock connectedHost], (int)data.length, [text wwz_json]);
    
    if (!text||text.length == 0) {
        
        
        if (data.length > 0) {
            
            WWZ_MAIN_GCD(^{
                
                if ([self.tcpSocketServerDelegate respondsToSelector:@selector(tcpSocketServer:didReadResult:fromHost:)]) {
                    [self.tcpSocketServerDelegate tcpSocketServer:self didReadResult:data fromHost:[sock connectedHost]];
                }
            });
            
        }
        
        [self p_readDataWithSocket:sock tag:(int)tag];
        
        return;
    }
    id jsonResult = [self p_jsonSerializationWithString:text];
    
    NSString *retcode = @"-1";
    
    NSString *retmsg = @"";
    
    if ([jsonResult isKindOfClass:[NSError class]]) {// json 解析失败
        
        retmsg = [[[(NSError *)jsonResult userInfo] allValues] lastObject];
        WWZ_MAIN_GCD(^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SERVER_ERROR_NOTI_NAME object:jsonResult userInfo:@{retcode : retmsg}];
        });
        
    }else if (!jsonResult||(![jsonResult isKindOfClass:[NSDictionary class]]&&![jsonResult isKindOfClass:[NSArray class]])){// 不存在或不是字典或数组
        
        retmsg = @"not json format";
        
        WWZ_MAIN_GCD(^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SERVER_ERROR_NOTI_NAME object:jsonResult userInfo:@{retcode : retmsg}];
        });
        
    }else{// 有效数据
        
        WWZ_MAIN_GCD(^{
            
            if ([self.tcpSocketServerDelegate respondsToSelector:@selector(tcpSocketServer:didReadResult:fromHost:)]) {
                [self.tcpSocketServerDelegate tcpSocketServer:self didReadResult:jsonResult fromHost:[sock connectedHost]];
            }
        });
    }
    // 读完当前数据后继续读数
    [self p_readDataWithSocket:sock tag:(int)tag];
}
/**
 *  超时处理
 */
//- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
//                 elapsed:(NSTimeInterval)elapsed
//               bytesDone:(NSUInteger)length
//{
//    WZLog(@"超时");
//    if (elapsed <= read_timeout)
//    {
//        NSString *warningMsg = @"Are you still there?\r\n";
//        NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
//        
//        [sock writeData:warningData withTimeout:-1 tag:warning_tag];
//        
//        return read_timeout;
//    }
//    
//    return 0.0;
//}
/**
 *  断线
 */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    
    NSString *host = [sock connectedHost];
    WZLog(@"disconnect_socket_host:%@", host);
    
    WWZ_MAIN_GCD(^{
        
        if ([self.tcpSocketServerDelegate respondsToSelector:@selector(tcpSocketServer:didDisconnectHost:)]) {
            [self.tcpSocketServerDelegate tcpSocketServer:self didDisconnectHost:host];
        }
    });
 
    [self.mConnectedSocketsDict removeObjectForKey:host];
}

#pragma mark - 私有方法
- (void)p_socketPong{
    
    WWZ_BACK_GCD(^{
        while (1) {
            // 给新连接的socket发送心跳
            [self sendDataToAllConnectedSocket:@"wwz socket heat"];
            sleep(5);
        }
    });
}

/**
 *  读取数据
 */
- (void)p_readDataWithSocket:(GCDAsyncSocket *)socket tag:(int)tag{
    
    if (_endKey) {
        // 读到'\n'
        [socket readDataToData:self.endDataKey withTimeout:read_timeout tag:tag];
    }else{
        [socket readDataWithTimeout:read_timeout tag:tag];
    }
}

/**
 *  json string ==> 字典
 */
- (id)p_jsonSerializationWithString:(NSString *)jsonString{
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    // 转字典
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        return error;
    }else{
        return result;
    }
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
- (NSData *)endDataKey{
    
    return [self.endKey dataUsingEncoding:NSUTF8StringEncoding];
}
- (NSMutableDictionary *)mConnectedSocketsDict{

    if (!_mConnectedSocketsDict) {
        _mConnectedSocketsDict = [NSMutableDictionary dictionary];
    }
    return _mConnectedSocketsDict;
}

- (void)dealloc{

    [self disconnectSocket];
}
@end

#pragma mark - json

@implementation NSString (Json)
/**
 *  json字符串格式化
 */
- (NSString *)wwz_json{
    
    NSString *spacing = @"\t";
    NSString *enterKey = @"\n";
    
    int number = 0;
    
    // 添加空格block
    NSString *(^addSpaceBlock)(int) = ^NSString *(int num){
        NSMutableString *mString = [NSMutableString string];
        for (int i = 0; i < num; i++) {
            [mString appendString:spacing];
        }
        return mString;
    };
    
    NSMutableString *mString = [NSMutableString stringWithFormat:@"%@", enterKey];
    
    // 第一个字符
    NSString *firstCharacter = [self substringWithRange:NSMakeRange(0, 1)];
    // 打印：当前字符。
    [mString appendString:firstCharacter];
    
    if ([firstCharacter isEqualToString:@"["] || [firstCharacter isEqualToString:@"{"]) {
        
        //（3）前方括号、前花括号，的后面必须换行。打印：换行。
        [mString appendString:enterKey];
        
        //（4）每出现一次前方括号、前花括号；缩进次数增加一次。打印：新行缩进。
        number++;
        [mString appendString:addSpaceBlock(number)];
    }
    
    // 是否在引号内
    BOOL isInQuotation = NO;
    //遍历输入字符串。
    for (int i = 1; i < self.length; i++) {
        
        //1、获取当前字符。
        NSString *subCharacter = [self substringWithRange:NSMakeRange(i, 1)];
        
        // 如果是":",反转isInColon
        if ([subCharacter isEqualToString:@"\""]&&![[self substringWithRange:NSMakeRange(i-1, 1)] isEqualToString:@"\\"]) {
            
            isInQuotation = !isInQuotation;
        }
        
        if (isInQuotation) {// 当前字符处于引号内
            
            //（2）打印：当前字符。
            [mString appendString:subCharacter];
            continue;
        }
        //2、如果当前字符是前方括号、前花括号做如下处理：
        if ([subCharacter isEqualToString:@"["] || [subCharacter isEqualToString:@"{"]) {
            
            // (1）如果前面还有字符，前面字符为“：”，打印：换行和缩进字符字符串
            if ([[self substringWithRange:NSMakeRange(i-1, 1)] isEqualToString:@":"]) {
                
                [mString appendString:enterKey];
                [mString appendString:addSpaceBlock(number)];
            }
            //（2）打印：当前字符。
            [mString appendString:subCharacter];
            
            //（3）前方括号、前花括号，的后面必须换行。打印：换行。
            [mString appendString:enterKey];
            
            //（4）每出现一次前方括号、前花括号；缩进次数增加一次。打印：新行缩进。
            number++;
            [mString appendString:addSpaceBlock(number)];
            
        }else if ([subCharacter isEqualToString:@"]"]||[subCharacter isEqualToString:@"}"]) {//3、如果当前字符是后方括号、后花括号做如下处理：
            
            //（1）后方括号、后花括号，的前面必须换行。打印：换行。
            [mString appendString:enterKey];
            //（2）每出现一次后方括号、后花括号；缩进次数减少一次。打印：缩进。
            number--;
            [mString appendString:addSpaceBlock(number)];
            //（3）打印：当前字符。
            [mString appendString:subCharacter];
            //（4）如果当前字符后面还有字符，并且字符不为“，”，打印：换行。
            if (((i+1)<self.length) && ![[self substringWithRange:NSMakeRange(i+1, 1)] isEqualToString:@","]) {
                
                [mString appendString:enterKey];
            }
        }else if ([subCharacter isEqualToString:@","]) {//4、如果当前字符是逗号。逗号后面换行，并缩进，不改变缩进次数。
            
            [mString appendString:subCharacter];
            [mString appendString:enterKey];
            [mString appendString:addSpaceBlock(number)];
            
        }else{// 其它正常打印
            [mString appendString:subCharacter];
        }
    }
    return mString;
}
@end

