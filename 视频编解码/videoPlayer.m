
//videoPlayer.m
 
 
#import "videoPlayer.h"
#import "GCDAsyncSocket.h"
 
#import "libavcodec/avcodec.h"
#import "libswscale/swscale.h"
 
const int Header = 101;
const int Data = 102;
 
@interface videoPlayer () <GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *socket;
    NSData *startcodeData;
    NSData *lastStartCode;
 
    //ffmpeg
    AVFrame *frame;
    AVPicture picture;
    AVCodec *codec;
    AVCodecContext *codecCtx;
    AVPacket packet;
    struct SwsContext *img_convert_ctx;
 
    NSMutableData *keyFrame;
 
    int outputWidth;
    int outputHeight;
}
@end
 
@implementation videoPlayer
 
- (id)init
{
    self = [super init];
    if (self) {
        avcodec_register_all();
        frame = av_frame_alloc();
        codec = avcodec_find_decoder(AV_CODEC_ID_H264);
        codecCtx = avcodec_alloc_context3(codec);
        int ret = avcodec_open2(codecCtx, codec, nil);
        if (ret != 0){
            NSLog(@"open codec failed :%d",ret);
        }
 
        socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        keyFrame = [[NSMutableData alloc]init];
 
        outputWidth = 320;
        outputHeight = 240;
 
        unsigned char startcode[] = {0,0,1};
        startcodeData = [NSData dataWithBytes:startcode length:3];
    }
    return self;
}
 
- (void)startup
{
    NSError *error = nil;
    sharedUserData *userData = [sharedUserData sharedUserData];
    [socket connectToHost:[userData address]
                   onPort:9982
              withTimeout:-1
                    error:&error];
    NSLog(@"%@",error);
    if (!error) {
        [socket readDataToData:startcodeData withTimeout:-1 tag:0];
    }
}
 
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [socket readDataToData:startcodeData withTimeout:-1 tag:Data];
    if(tag == Data){
        int type = [self typeOfNalu:data];
        if (type == 7 || type == 8 || type == 6 || type == 5) { //SPS PPS SEI IDR
            [keyFrame appendData:lastStartCode];
            [keyFrame appendBytes:[data bytes] length:[data length] - [self startCodeLenth:data]];
        }
        if (type == 5 || type == 1) {//IDR P frame
            if (type == 5) {
                int nalLen = (int)[keyFrame length];
                av_new_packet(&packet, nalLen);
                memcpy(packet.data, [keyFrame bytes], nalLen);
                keyFrame = [[NSMutableData alloc] init];//reset keyframe
            }else{
                NSMutableData *nalu = [[NSMutableData alloc]initWithData:lastStartCode];
                [nalu appendBytes:[data bytes] length:[data length] - [self startCodeLenth:data]];
                int nalLen = (int)[nalu length];
                av_new_packet(&packet, nalLen);
                memcpy(packet.data, [nalu bytes], nalLen);
            }
 
            int ret, got_picture;
            //NSLog(@"decode start");
            ret = avcodec_decode_video2(codecCtx, frame, &got_picture, &packet);
            //NSLog(@"decode finish");
            if (ret < 0) {
                NSLog(@"decode error");
                return;
            }
            if (!got_picture) {
                NSLog(@"didn't get picture");
                return;
            }
            static int sws_flags =  SWS_FAST_BILINEAR;
            //outputWidth = codecCtx->width;
            //outputHeight = codecCtx->height;
            if (!img_convert_ctx)
                img_convert_ctx = sws_getContext(codecCtx->width,
                                                 codecCtx->height,
                                                 codecCtx->pix_fmt,
                                                 outputWidth,
                                                 outputHeight,
                                                 PIX_FMT_YUV420P,
                                                 sws_flags, NULL, NULL, NULL);
 
            avpicture_alloc(&picture, PIX_FMT_YUV420P, outputWidth, outputHeight);
            ret = sws_scale(img_convert_ctx, (const uint8_t* const*)frame->data, frame->linesize, 0, frame->height, picture.data, picture.linesize);
 
            [self display];
            //NSLog(@"show frame finish");
            avpicture_free(&picture);
            av_free_packet(&packet);
        }
    }
    [self saveStartCode:data];
}
 
- (void)display
{
 
}
 
- (int)typeOfNalu:(NSData *)data
{
    char first = *(char *)[data bytes];
    return first & 0x1f;
}
 
- (int)startCodeLenth:(NSData *)data
{
    char temp = *((char *)[data bytes] + [data length] - 4);
    return temp == 0x00 ? 4 : 3;
}
 
- (void)saveStartCode:(NSData *)data
{
    int startCodeLen = [self startCodeLenth:data];
    NSRange startCodeRange = {[data length] - startCodeLen, startCodeLen};
    lastStartCode = [data subdataWithRange:startCodeRange];
}
 
- (void)shutdown
{
    if(socket)[socket disconnect];
}
 
- (void)dealloc
{
    // Free scaler
    if(img_convert_ctx)sws_freeContext(img_convert_ctx);
 
    // Free the YUV frame
    if(frame)av_frame_free(&frame);
	
 
    // Close the codec
    if (codecCtx) avcodec_close(codecCtx);
}
 
@end