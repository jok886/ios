# 第五天

##### 1.0 JSON解析

- 1.1 JSON简单介绍

    001 问：什么是JSON
        答：
        （1）JSON是一种轻量级的数据格式，一般用于数据交互
        （2）服务器返回给客户端的数据，一般都是JSON格式或者XML格式（文件下载除外）
    002 相关说明
        （1）JSON的格式很像OC中的字典和数组
        （2）标准JSON格式key必须是双引号
    003 JSON解析方案
        a.第三方框架  JSONKit\SBJSON\TouchJSON
        b.苹果原生（NSJSONSerialization）

- 1.2  JSON解析相关代码

（1）json数据->OC对象
```objc
//把json数据转换为OC对象
-(void)jsonToOC
{
    //1. 确定url路径
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/login?username=33&pwd=33&type=JSON"];

    //2.创建一个请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    //3.使用NSURLSession发送一个异步请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {

        //4.当接收到服务器响应的数据后，解析数据(JSON--->OC)

        /*
         第一个参数：要解析的JSON数据，是NSData类型也就是二进制数据
         第二个参数: 解析JSON的可选配置参数
         NSJSONReadingMutableContainers 解析出来的字典和数组是可变的
         NSJSONReadingMutableLeaves 解析出来的对象中的字符串是可变的  iOS7以后有问题
         NSJSONReadingAllowFragments 被解析的JSON数据如果既不是字典也不是数组, 那么就必须使用这个
         */
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",dict);

    }];
}

```
（2）OC对象->JSON对象
```objc
 //1.要转换成JSON数据的OC对象*这里是一个字典
    NSDictionary *dictM = @{
                            @"name":@"wendingding",
                            @"age":@100,
                            @"height":@1.72
                            };
    //2.OC->JSON
    /*
     注意：可以通过+ (BOOL)isValidJSONObject:(id)obj;方法判断当前OC对象能否转换为JSON数据
     具体限制：
         1.obj 是NSArray 或 NSDictionay 以及他们派生出来的子类
         2.obj 包含的所有对象是NSString,NSNumber,NSArray,NSDictionary 或NSNull
         3.字典中所有的key必须是NSString类型的
         4.NSNumber的对象不能是NaN或无穷大
     */
    /*
     第一个参数：要转换成JSON数据的OC对象，这里为一个字典
     第二个参数：NSJSONWritingPrettyPrinted对转换之后的JSON对象进行排版，无意义
     */
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictM options:NSJSONWritingPrettyPrinted error:nil];

    //3.打印查看Data是否有值
    /*
     第一个参数：要转换为STring的二进制数据
     第二个参数：编码方式，通常采用NSUTF8StringEncoding
     */
    NSString *strM = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",strM);
```
（3）OC对象和JSON数据格式之间的一一对应关系
```objc
//OC对象和JSON数据之间的一一对应关系
-(void)oCWithJSON
{
    //JSON的各种数据格式
    //NSString *test = @"\"wendingding\"";
    //NSString *test = @"true";
    NSString *test = @"{\"name\":\"wendingding\"}";

    //把JSON数据->OC对象,以便查看他们之间的一一对应关系
    //注意点：如何被解析的JSON数据如果既不是字典也不是数组（比如是NSString）, 那么就必须使用这NSJSONReadingAllowFragments
    id obj = [NSJSONSerialization JSONObjectWithData:[test dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];

    NSLog(@"%@", [obj class]);


    /* JSON数据格式和OC对象的一一对应关系
         {} -> 字典
         [] -> 数组
         "" -> 字符串
         10/10.1 -> NSNumber
         true/false -> NSNumber
         null -> NSNull
     */
}
}
```
（4）如何查看复杂的JSON数据

```objc
方法一：
    在线格式化http://tool.oschina.net/codeformat/json
方法二：
    把解析后的数据写plist文件，通过plist文件可以直观的查看JSON的层次结构。
    [dictM writeToFile:@"/Users/文顶顶/Desktop/videos.plist" atomically:YES];
```

（5）视频的简单播放

```objc
    //0.需要导入系统框架
    #import <MediaPlayer/MediaPlayer.h>

    //1.拿到该cell对应的数据字典
    XMGVideo *video = self.videos[indexPath.row];

    NSString *videoStr = [@"http://120.25.226.186:32812" stringByAppendingPathComponent:video.url];

    //2.创建一个视频播放器
    MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:videoStr]];
    //3.present播放控制器

    [self presentViewController:vc animated:YES completion:nil];
```
- 1.3 字典转模型框架

（1）相关框架

     a.Mantle 需要继承自MTModel
     b.JSONModel 需要继承自JSONModel
     c.MJExtension 不需要继承，无代码侵入性

（2）自己设计和选择框架时需要注意的问题

    a.侵入性
    b.易用性，是否容易上手
    c.扩展性，很容易给这个框架增加新的功能

（3）MJExtension框架的简单使用

```objc
//1.把字典数组转换为模型数组
    //使用MJExtension框架进行字典转模型
        self.videos = [XMGVideo objectArrayWithKeyValuesArray:videoArray];

//2.重命名模型属性的名称
//第一种重命名属性名称的方法，有一定的代码侵入性
//设置字典中的id被模型中的ID替换
+(NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"ID":@"id"
             };
}

//第二种重命名属性名称的方法，代码侵入性为零
    [XMGVideo setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"ID":@"id"
                 };
    }];

//3.MJExtension框架内部实现原理-运行时
```
##### 2.0 XML解析

- 2.1 XML简单介绍

（1） XML：可扩展标记语言

        a.语法
        b.XML文档的三部分（声明、元素和属性）
        c.其它注意点（注意不能交叉包含、空行换行、XML文档只能有一个根元素等）

（2） XML解析

        a.XML解析的两种方式
            001 SAX:从根元素开始，按顺序一个元素一个元素的往下解析，可用于解析大、小文件
            002 DOM:一次性将整个XML文档加载到内存中，适合较小的文件
        b.解析XML的工具
            001 苹果原生NSXMLParser:使用SAX方式解析，使用简单
            002 第三方框架
                libxml2:纯C语言的，默认包含在iOS SDK中，同时支持DOM和SAX的方式解析
                GDataXML:采用DOM方式解析，该框架由Goole开发，是基于xml2的

- 2.2 XML解析

（1）使用NSXMLParser解析XML步骤和代理方法
```objc
//解析步骤：
//4.1 创建一个解析器
NSXMLParser *parser = [[NSXMLParser alloc]initWithData:data];
//4.2 设置代理
parser.delegate = self;
//4.3 开始解析
[parser parse];

-----------------------------------------

//1.开始解析XML文档
-(void)parserDidStartDocument:(nonnull NSXMLParser *)parser

//2.开始解析XML中某个元素的时候调用，比如<video>
-(void)parser:(nonnull NSXMLParser *)parser didStartElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(nonnull NSDictionary<NSString *,NSString *> *)attributeDict
{
    if ([elementName isEqualToString:@"videos"]) {
        return;
    }
    //字典转模型
    XMGVideo *video = [XMGVideo objectWithKeyValues:attributeDict];
    [self.videos addObject:video];
}

//3.当某个元素解析完成之后调用，比如</video>
-(void)parser:(nonnull NSXMLParser *)parser didEndElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName

//4.XML文档解析结束
-(void)parserDidEndDocument:(nonnull NSXMLParser *)parser
```

（2）使用GDataParser解析XML的步骤和方法

```objc

//4.0 配置环境
// 001 先导入框架，然后按照框架使用注释配置环境
// 002 GDataXML框架是MRC的，所以还需要告诉编译器以MRC的方式处理GDataXML的代码

//4.1 加载XML文档（使用的是DOM的方式一口气把整个XML文档都吞下）
    GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithData:data options:kNilOptions error:nil];

//4.2 获取XML文档的根元素，根据根元素取出XML中的每个子元素
  NSArray * elements = [doc.rootElement elementsForName:@"video"];

//4.3 取出每个子元素的属性并转换为模型
for (GDataXMLElement *ele in elements) {

    XMGVideo *video = [[XMGVideo alloc]init];
    video.name = [ele attributeForName:@"name"].stringValue;
    video.length = [ele attributeForName:@"length"].stringValue.integerValue;
    video.url = [ele attributeForName:@"url"].stringValue;
    video.image = [ele attributeForName:@"image"].stringValue;
    video.ID = [ele attributeForName:@"id"].stringValue;

    //4.4 把转换好的模型添加到tableView的数据源self.videos数组中
    [self.videos addObject:video];
}

```

#####3.0 多值参数和中文输出问题

（1）多值参数如何设置请求路径
```objc
//多值参数
/*
 如果一个参数对应着多个值，那么直接按照"参数=值&参数=值"的方式拼接
 */
-(void)test
{
    //1.确定URL
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/weather?place=Beijing&place=Guangzhou"];
    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    //3.发送请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {

        //4.解析
        NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
    }];
}
```

（2）如何解决字典和数组中输出乱码的问题
```objc
答：给字典和数组添加一个分类，重写descriptionWithLocale方法，在该方法中拼接元素格式化输出。
-(nonnull NSString *)descriptionWithLocale:(nullable id)locale
```
#####4.0 小文件下载

（1）第一种方式（NSData）
```objc
//使用NSDta直接加载网络上的url资源（不考虑线程）
-(void)dataDownload
{
    //1.确定资源路径
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/images/minion_01.png"];

    //2.根据URL加载对应的资源
    NSData *data = [NSData dataWithContentsOfURL:url];

    //3.转换并显示数据
    UIImage *image = [UIImage imageWithData:data];
    self.imageView.image = image;

}
```
（2）第二种方式（NSURLConnection-sendAsync）
```objc
//使用NSURLConnection发送异步请求下载文件资源
-(void)connectDownload
{
    //1.确定请求路径
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/images/minion_01.png"];

    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    //3.使用NSURLConnection发送一个异步请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        //4.拿到并处理数据
        UIImage *image = [UIImage imageWithData:data];
        self.imageView.image = image;

    }];

}
```
（3）第三种方式（NSURLConnection-delegate）
```objc
//使用NSURLConnection设置代理发送异步请求的方式下载文件
-(void)connectionDelegateDownload
{
    //1.确定请求路径
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];

    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    //3.使用NSURLConnection设置代理并发送异步请求
    [NSURLConnection connectionWithRequest:request delegate:self];

}

#pragma mark--NSURLConnectionDataDelegate

//当接收到服务器响应的时候调用，该方法只会调用一次
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //创建一个容器，用来接收服务器返回的数据
    self.fileData = [NSMutableData data];

    //获得当前要下载文件的总大小（通过响应头得到）
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    self.totalLength = res.expectedContentLength;
    NSLog(@"%zd",self.totalLength);

    //拿到服务器端推荐的文件名称
    self.fileName = res.suggestedFilename;

}
//当接收到服务器返回的数据时会调用
//该方法可能会被调用多次
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    NSLog(@"%s",__func__);

    //拼接每次下载的数据
    [self.fileData appendData:data];

    //计算当前下载进度并刷新UI显示
    self.currentLength = self.fileData.length;

    NSLog(@"%f",1.0* self.currentLength/self.totalLength);
    self.progressView.progress = 1.0* self.currentLength/self.totalLength;


}
//当网络请求结束之后调用
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //文件下载完毕把接受到的文件数据写入到沙盒中保存

    //1.确定要保存文件的全路径
    //caches文件夹路径
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

    NSString *fullPath = [caches stringByAppendingPathComponent:self.fileName];

    //2.写数据到文件中
    [self.fileData writeToFile:fullPath atomically:YES];

    NSLog(@"%@",fullPath);
}

//当请求失败的时候调用该方法
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%s",__func__);
}

```
#####5.0  大文件的下载

（1）实现思路

    边接收数据边写文件以解决内存越来越大的问题
（2）核心代码
```objc

//当接收到服务器响应的时候调用，该方法只会调用一次
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //0.获得当前要下载文件的总大小（通过响应头得到）
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    self.totalLength = res.expectedContentLength;
    NSLog(@"%zd",self.totalLength);

    //创建一个新的文件，用来当接收到服务器返回数据的时候往该文件中写入数据
    //1.获取文件管理者
    NSFileManager *manager = [NSFileManager defaultManager];

    //2.拼接文件的全路径
    //caches文件夹路径
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

    NSString *fullPath = [caches stringByAppendingPathComponent:res.suggestedFilename];
    self.fullPath  = fullPath;
    //3.创建一个空的文件
    [manager createFileAtPath:fullPath contents:nil attributes:nil];

}
//当接收到服务器返回的数据时会调用
//该方法可能会被调用多次
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{

    //1.创建一个用来向文件中写数据的文件句柄
    //注意当下载完成之后，该文件句柄需要关闭，调用closeFile方法
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.fullPath];

    //2.设置写数据的位置(追加)
    [handle seekToEndOfFile];

    //3.写数据
    [handle writeData:data];

    //4.计算当前文件的下载进度
    self.currentLength += data.length;

    NSLog(@"%f",1.0* self.currentLength/self.totalLength);
    self.progressView.progress = 1.0* self.currentLength/self.totalLength;
}
```
#####6.0  大文件断点下载

（1）实现思路

    在下载文件的时候不再是整块的从头开始下载，而是看当前文件已经下载到哪个地方，然后从该地方接着往后面下载。可以通过在请求对象中设置请求头实现。

（2）解决方案（设置请求头）
```
//2.创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    //2.1 设置下载文件的某一部分
    // 只要设置HTTP请求头的Range属性, 就可以实现从指定位置开始下载
    /*
     表示头500个字节：Range: bytes=0-499
     表示第二个500字节：Range: bytes=500-999
     表示最后500个字节：Range: bytes=-500
     表示500字节以后的范围：Range: bytes=500-
     */
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.currentLength];
    [request setValue:range forHTTPHeaderField:@"Range"];

```
（3）注意点（下载进度并判断是否需要重新创建文件）
```objc
//获得当前要下载文件的总大小（通过响应头得到）
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;

    //注意点：res.expectedContentLength获得是本次请求要下载的文件的大小（并非是完整的文件的大小）
    //因此：文件的总大小 == 本次要下载的文件大小+已经下载的文件的大小
    self.totalLength = res.expectedContentLength + self.currentLength;

    NSLog(@"----------------------------%zd",self.totalLength);

    //0 判断当前是否已经下载过，如果当前文件已经存在，那么直接返回
    if (self.currentLength >0) {
        return;
    }

```
#####7.0  输出流

（1）使用输出流也可以实现和NSFileHandle相同的功能

（2）如何使用
```objc
    //1.创建一个数据输出流
    /*
     第一个参数：二进制的流数据要写入到哪里
     第二个参数：采用什么样的方式写入流数据，如果YES则表示追加，如果是NO则表示覆盖
     */
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:fullPath append:YES];

    //只要调用了该方法就会往文件中写数据
    //如果文件不存在，那么会自动的创建一个
    [stream open];
    self.stream = stream;

    //2.当接收到数据的时候写数据
    //使用输出流写数据
    /*
     第一个参数：要写入的二进制数据
     第二个参数：要写入的数据的大小
     */
    [self.stream write:data.bytes maxLength:data.length];

    //3.当文件下载完毕的时候关闭输出流
    //关闭输出流
    [self.stream close];
    self.stream = nil;
```

#####8.0  使用多线程下载文件思路

```objc
01 开启多条线程，每条线程都只下载文件的一部分（通过设置请求头中的Range来实现）
02 创建一个和需要下载文件大小一致的文件，判断当前是那个线程，根据当前的线程来判断下载的数据应该写入到文件中的哪个位置。（假设开5条线程来下载10M的文件，那么线程1下载0-2M，线程2下载2-4M一次类推，当接收到服务器返回的数据之后应该先判断当前线程是哪个线程，假如当前线程是线程2，那么在写数据的时候就从文件的2M位置开始写入）
03 代码相关：使用NSFileHandle这个类的seekToFileOfSet方法，来向文件中特定的位置写入数据。
04 技术相关
    a.每个线程通过设置请求头下载文件中的某一个部分
    b.通过NSFileHandle向文件中的指定位置写数据
```

#####9.0  文件的压缩和解压缩

（1）说明

    使用ZipArchive来压缩和解压缩文件需要添加依赖库（libz）,使用需要包含SSZipArchive文件，如果使用cocoaPoads来安装框架，那么会自动的配置框架的使用环境

（2）相关代码
```objc
//压缩文件的第一种方式
/*
 第一个参数：压缩文件要保存的位置
 第二个参数：要压缩哪几个文件
 */
[SSZipArchive createZipFileAtPath:fullpath withFilesAtPaths:arrayM];

//压缩文件的第二种方式
/*
 第一个参数：文件压缩到哪个地方
 第二个参数：要压缩文件的全路径
 */
[SSZipArchive createZipFileAtPath:fullpath withContentsOfDirectory:zipFile];

//如何对压缩文件进行解压
/*
 第一个参数：要解压的文件
 第二个参数：要解压到什么地方
 */
[SSZipArchive unzipFileAtPath:unZipFile toDestination:fullpath];
````
#####10.0  文件的上传
- 10.1 文件上传步骤

        （1）确定请求路径
        （2）根据URL创建一个可变的请求对象
        （3）设置请求对象，修改请求方式为POST
        （4）设置请求头，告诉服务器我们将要上传文件（Content-Type）
        （5）设置请求体（在请求体中按照既定的格式拼接要上传的文件参数和非文件参数等数据）
            001 拼接文件参数
            002 拼接非文件参数
            003 添加结尾标记
        （6）使用NSURLConnection sendAsync发送异步请求上传文件
        （7）解析服务器返回的数据


- 10.2 文件上传设置请求体的数据格式

        //请求体拼接格式
        //分隔符：----WebKitFormBoundaryhBDKBUWBHnAgvz9c

        //01.文件参数拼接格式

         --分隔符
         Content-Disposition:参数
         Content-Type:参数
         空行
         文件参数

        //02.非文件拼接参数
         --分隔符
         Content-Disposition:参数
         空行
         非文件的二进制数据

        //03.结尾标识
        --分隔符--

- 10.3 文件上传相关代码

```objc
- (void)upload
{
    //1.确定请求路径
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/upload"];

    //2.创建一个可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    //3.设置请求方式为POST
    request.HTTPMethod = @"POST";

    //4.设置请求头
    NSString *filed = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",Kboundary];
    [request setValue:filed forHTTPHeaderField:@"Content-Type"];

    //5.设置请求体
    NSMutableData *data = [NSMutableData data];
    //5.1 文件参数
    /*
     --分隔符
     Content-Disposition:参数
     Content-Type:参数
     空行
     文件参数
     */
    [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KnewLine];
    [data appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"test.png\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KnewLine];
    [data appendData:[@"Content-Type: image/png" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KnewLine];
    [data appendData:KnewLine];
    [data appendData:KnewLine];

    UIImage *image = [UIImage imageNamed:@"test"];
    NSData *imageData = UIImagePNGRepresentation(image);
    [data appendData:imageData];
    [data appendData:KnewLine];

    //5.2 非文件参数
    /*
     --分隔符
     Content-Disposition:参数
     空行
     非文件参数的二进制数据
     */

    [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KnewLine];
    [data appendData:[@"Content-Disposition: form-data; name=\"username\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KnewLine];
    [data appendData:KnewLine];
    [data appendData:KnewLine];

    NSData *nameData = [@"wendingding" dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:nameData];
    [data appendData:KnewLine];

    //5.3 结尾标识
    //--分隔符--
    [data appendData:[[NSString stringWithFormat:@"--%@--",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KnewLine];

    request.HTTPBody = data;

    //6.发送请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * __nullable response, NSData * __nullable data, NSError * __nullable connectionError) {

        //7.解析服务器返回的数据
        NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
    }];
}

```
- 10.4 如何获得文件的MIMEType类型

（1）直接对该对象发送一个异步网络请求，在响应头中通过response.MIMEType拿到文件的MIMEType类型
```objc
//如果想要及时拿到该数据，那么可以发送一个同步请求
- (NSString *)getMIMEType
{
    NSString *filePath = @"/Users/文顶顶/Desktop/备课/其它/swift.md";

    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]] returningResponse:&response error:nil];
    return response.MIMEType;
}

//对该文件发送一个异步请求，拿到文件的MIMEType
- (void)MIMEType
{

    //    NSString *file = @"file:///Users/文顶顶/Desktop/test.png";

    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:@"/Users/文顶顶/Desktop/test.png"]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * __nullable response, NSData * __nullable data, NSError * __nullable connectionError) {
        //       response.MIMEType
        NSLog(@"%@",response.MIMEType);

    }];
}
```
（2）通过UTTypeCopyPreferredTagWithClass方法
```objc
//注意：需要依赖于框架MobileCoreServices
- (NSString *)mimeTypeForFileAtPath:(NSString *)path
{
    if (![[[NSFileManager alloc] init] fileExistsAtPath:path]) {
        return nil;
    }

    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)(MIMEType);
}
```

#####11.0 NSURLConnection和Runloop（面试）
（1）两种为NSURLConnection设置代理方式的区别

```objc
    //第一种设置方式：
    //通过该方法设置代理，会自动的发送请求
    // [[NSURLConnection alloc]initWithRequest:request delegate:self];

    //第二种设置方式：
    //设置代理，startImmediately为NO的时候，该方法不会自动发送请求
    NSURLConnection *connect = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO];
    //手动通过代码的方式来发送请求
    //注意该方法内部会自动的把connect添加到当前线程的RunLoop中在默认模式下执行
    [connect start];
 ```

（2）如何控制代理方法在哪个线程调用

```objc
    //说明：默认情况下，代理方法会在主线程中进行调用（为了方便开发者拿到数据后处理一些刷新UI的操作不需要考虑到线程间通信）
    //设置代理方法的执行队列
    [connect setDelegateQueue:[[NSOperationQueue alloc]init]];

```


（3）开子线程发送网络请求的注意点，适用于自动发送网络请求模式
```objc

//在子线程中发送网络请求-调用startf方法发送
-(void)createNewThreadSendConnect1
{
    //1.创建一个非主队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    //2.封装操作，并把任务添加到队列中执行
    [queue addOperationWithBlock:^{

        NSLog(@"%@",[NSThread currentThread]);
        //2-1.确定请求路径
        NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/login?username=dd&pwd=ww&type=JSON"];

        //2-2.创建请求对象
        NSURLRequest *request = [NSURLRequest requestWithURL:url];

        //2-3.使用NSURLConnection设置代理，发送网络请求
        NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES];

        //2-4.设置代理方法在哪个队列中执行，如果是非主队列，那么代理方法将再子线程中执行
        [connection setDelegateQueue:[[NSOperationQueue alloc]init]];

        //2-5.发送网络请求
        //注意：start方法内部会把当前的connect对象作为一个source添加到当前线程对应的runloop中
        //区别在于，如果调用start方法开发送网络请求，那么再添加source的过程中，如果当前runloop不存在
        //那么该方法内部会自动创建一个当前线程对应的runloop,并启动。
        [connection start];

    }];
}

//在子线程中发送网络请求-自动发送网络请求
-(void)createNewThreadSendConnect2
{
    NSLog(@"-----");
    //1.创建一个非主队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    //2.封装操作，并把任务添加到队列中执行
    [queue addOperationWithBlock:^{

        //2-1.确定请求路径
        NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/login?username=dd&pwd=ww&type=JSON"];

        //2-2.创建请求对象
        NSURLRequest *request = [NSURLRequest requestWithURL:url];

        //2-3.使用NSURLConnection设置代理，发送网络请求
        //注意：该方法内部虽然会把connection添加到runloop,但是如果当前的runloop不存在，那么不会主动创建。
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];

        //2-4.设置代理方法在哪个队列中执行，如果是非主队列，那么代理方法将再子线程中执行
        [connection setDelegateQueue:[[NSOperationQueue alloc]init]];

        //2-5 创建当前线程对应的runloop,并开启
       [[NSRunLoop currentRunLoop]run];
    }];
}

```

---
