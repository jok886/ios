# 第七天
###0.AFN框架基本使用
- 0.1 AFN内部结构

```objc
AFN结构体
    - NSURLConnection
        + AFURLConnectionOperation(已经被废弃)
        + AFHTTPRequestOperation(已经被废弃)
        + AFHTTPRequestOperationManager(封装了常用的 HTTP 方法)(已经被废弃)
            * 属性
                * baseURL :AFN建议开发者针对 AFHTTPRequestOperationManager 自定义个一个单例子类，设置 baseURL, 所有的网络访问，都只使用相对路径即可
                * requestSerializer :请求数据格式/默认是二进制的 HTTP
                * responseSerializer :响应的数据格式/默认是 JSON 格式
                * operationQueue
                * reachabilityManager :网络连接管理器
            * 方法
                * manager :方便创建管理器的类方法
                * HTTPRequestOperationWithRequest :在访问服务器时，如果要告诉服务器一些附加信息，都需要在 Request 中设置
                * GET
                * POST

    - NSURLSession
        + AFURLSessionManager
        + AFHTTPSessionManager(封装了常用的 HTTP 方法)
            * GET
            * POST
            * UIKit + AFNetworking 分类
            * NSProgress :利用KVO

    - 半自动的序列化&反序列化的功能
        + AFURLRequestSerialization :请求的数据格式/默认是二进制的
        + AFURLResponseSerialization :响应的数据格式/默认是JSON格式
    - 附加功能
        + 安全策略
            * HTTPS
            * AFSecurityPolicy
        + 网络检测
            * 对苹果的网络连接检测做了一个封装
            * AFNetworkReachabilityManager

建议:
可以学习下AFN对 UIKit 做了一些分类, 对自己能力提升是非常有帮助的
```
- 0.2 AFN的基本使用

（1）发送POST请求的方式
```objc
-(void)post
{
    //1.创建会话管理者
    //AFHTTPSessionManager内部是基于NSURLSession实现的
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    //2.创建参数
    NSDictionary *dict = @{
                           @"username":@"520it",
                           @"pwd":@"520it",
                           };

    //3.发送POST请求
    /*
     http://120.25.226.186:32812/login?username=ee&pwd=ee&type=JSON
     第一个参数：NSString类型的请求路径，AFN内部会自动将该路径包装为一个url并创建请求对象
     第二个参数：请求参数，以字典的方式传递，AFN内部会判断当前是POST请求还是GET请求，以选择直接拼接还是转换为NSData放到请求体中传递
     第三个参数：进度回调 此处为nil
     第四个参数：请求成功之后回调Block
     第五个参数：请求失败回调Block
     */
    [manager POST:@"http://120.25.226.186:32812/login" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        //注意：responseObject:请求成功返回的响应结果（AFN内部已经把响应体转换为OC对象，通常是字典或数组）
        NSLog(@"请求成功---%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败---%@",error);
    }];
}
```

（2）使用AFN下载文件
```objc
-(void)download
{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];


    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://120.25.226.186:32812/resources/images/minion_13.png"]];

    //3.创建下载Task
    /*
     第一个参数：请求对象
     第二个参数：进度回调
        downloadProgress.completedUnitCount :已经下载的数据
        downloadProgress.totalUnitCount：数据的总大小
     第三个参数：destination回调，该block需要返回值（NSURL类型），告诉系统应该把文件剪切到什么地方
        targetPath：文件的临时保存路径
        response：响应头信息
     第四个参数：completionHandler请求完成后回调
        response：响应头信息
        filePath：文件的保存路径，即destination回调的返回值
        error：错误信息
     */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);

    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {

        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        NSLog(@"%@\n%@",targetPath,fullPath);
        return [NSURL fileURLWithPath:fullPath];

    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"%@",filePath);
    }];

    //4.执行Task
    [downloadTask resume];
}
```

###1.AFN使用技巧

```objc
1.在开发的时候可以创建一个工具类，继承自我们的AFN中的请求管理者，再控制器中真正发请求的代码使用自己封装的工具类。
2.这样做的优点是以后如果修改了底层依赖的框架，那么我们修改这个工具类就可以了，而不用再一个一个的去修改。
3.该工具类一般提供一个单例方法，在该方法中会设置一个基本的请求路径。
4.该方法通常还会提供对GET或POST请求的封装。
5.在外面的时候通过该工具类来发送请求
6.单例方法：
+ (instancetype)shareNetworkTools
{
    static XMGNetworkTools *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 注意: BaseURL中一定要以/结尾
        instance = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://120.25.226.186:32812/"]];
    });
    return instance;
}
```

###2.AFN文件上传
```objc
1.文件上传拼接数据的第一种方式
[formData appendPartWithFileData:data name:@"file" fileName:@"xxoo.png" mimeType:@"application/octet-stream"];
2.文件上传拼接数据的第二种方式
 [formData appendPartWithFileURL:fileUrl name:@"file" fileName:@"xx.png" mimeType:@"application/octet-stream" error:nil];
3.文件上传拼接数据的第三种方式
 [formData appendPartWithFileURL:fileUrl name:@"file" error:nil];
4.【注】在资料中已经提供了一个用于文件上传的分类。

/*文件上传相关的代码如下*/
-(void)upload1
{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    //2.处理参数(非文件参数)
    NSDictionary *dict = @{
                           @"username":@"123"
                           };

    //3.发送请求上传文件
    /*
     第一个参数：请求路径（NSString类型）
     第二个参数：非文件参数，以字典的方式传递
     第三个参数：constructingBodyWithBlock 在该回调中拼接文件参数
     第四个参数：progress 进度回调
        uploadProgress.completedUnitCount:已经上传的数据大小
        uploadProgress.totalUnitCount：数据的总大小
     第五个参数：success 请求成功的回调
        task：上传Task
        responseObject:服务器返回的响应体信息（已经以JSON的方式转换为OC对象）
     第六个参数：failure 请求失败的回调
        task：上传Task
        error：错误信息
     */
    [manager POST:@"http://120.25.226.186:32812/upload" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        UIImage *image = [UIImage imageNamed:@"Snip20160117_1"];
        NSData *imageData = UIImagePNGRepresentation(image);

        //在该block中拼接要上传的文件参数
        /*
         第一个参数：要上传的文件二进制数据
         第二个参数：文件参数对应的参数名称，此处为file是该台服务器规定的（通常会在接口文档中提供）
         第三个参数：该文件上传到服务后以什么名称保存
         第四个参数：该文件的MIMeType类型
         */
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"123.png" mimeType:@"image/png"];

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%f",1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSLog(@"请求成功----%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSLog(@"请求失败----%@",error);
    }];
}

-(void)upload2
{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    //2.处理参数(非文件参数)
    NSDictionary *dict = @{
                           @"username":@"123"
                           };

    //3.发送请求上传文件
    /*
     第一个参数：请求路径（NSString类型）
     第二个参数：非文件参数，以字典的方式传递
     第三个参数：constructingBodyWithBlock 在该回调中拼接文件参数
     第四个参数：progress 进度回调
        uploadProgress.completedUnitCount:已经上传的数据大小
        uploadProgress.totalUnitCount：数据的总大小
     第五个参数：success 请求成功的回调
        task：上传Task
        responseObject:服务器返回的响应体信息（已经以JSON的方式转换为OC对象）
     第六个参数：failure 请求失败的回调
        task：上传Task
        error：错误信息
     */
    [manager POST:@"http://120.25.226.186:32812/upload" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        NSURL *fileUrl = [NSURL fileURLWithPath:@"/Users/文顶顶/Desktop/Snip20160117_1.png"];


        //在该block中拼接要上传的文件参数
        //第一种拼接方法
        /*
         第一个参数：要上传的文件的URL路径
         第二个参数：文件参数对应的参数名称，此处为file是该台服务器规定的（通常会在接口文档中提供）
         第三个参数：该文件上传到服务后以什么名称保存
         第四个参数：该文件的MIMeType类型
         第五个参数：错误信息，传地址
         */
        //[formData appendPartWithFileURL:fileUrl name:@"file" fileName:@"1234.png" mimeType:@"image/png" error:nil];


        //第二种拼接方法：简写方法
        /*
         第一个参数：要上传的文件的URL路径
         第二个参数：文件参数对应的参数名称，此处为file
         第三个参数：错误信息
         说明：AFN内部自动获得路径URL地址的最后一个节点作为文件的名称，内部调用C语言的API获得文件的类型
         */
        [formData appendPartWithFileURL:fileUrl name:@"file" error:nil];

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%f",1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSLog(@"请求成功----%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSLog(@"请求失败----%@",error);
    }];
}
```

###3.使用AFN进行序列化处理
```objc
/*
1.AFN它内部默认把服务器响应的数据当做json来进行解析，所以如果服务器返回给我的不是JSON数据那么请求报错，这个时候需要设置AFN对响应信息的解析方式。AFN提供了三种解析响应信息的方式，分别是：
1）AFXMLParserResponseSerializer----XML
2) AFHTTPResponseSerializer---------默认二进制响应数据
3）AFJSONResponseSerializer---------JSON

2.还有一种情况就是服务器返回给我们的数据格式不太一致（开发者工具Content-Type:text/xml）,那么这种情况也有可能请求不成功。解决方法:
1） 直接在源代码中修改，添加相应的Content-Type
2） 拿到这个属性，添加到它的集合中

3.相关代码
-(void)srializer
{
    //1.创建请求管理者，内部基于NSURLSession
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    /* 知识点1：设置AFN采用什么样的方式来解析服务器返回的数据*/

    //如果返回的是XML，那么告诉AFN，响应的时候使用XML的方式解析
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];

    //如果返回的就是二进制数据，那么采用默认二进制的方式来解析数据
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    //采用JSON的方式来解析数据
    //manager.responseSerializer = [AFJSONResponseSerializer serializer];


    /*知识点2 告诉AFN，再序列化服务器返回的数据的时候，支持此种类型
    [AFJSONResponseSerializer serializer].acceptableContentTypes = [NSSet setWithObject:@"text/xml"];

    //2.把所有的请求参数通过字典的方式来装载，GET方法内部会自动把所有的键值对取出以&符号拼接并最后用？符号连接在请求路径后面
    NSDictionary *dict = @{
                           @"username":@"223",
                           @"pwd":@"ewr",
                           @"type":@"XML"
                           };

    //3.发送GET请求
    [manager GET:@"http://120.25.226.186:32812/login" parameters:dict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {

        //4.请求成功的回调block
        NSLog(@"%@",[responseObject class]);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {

        //5.请求失败的回调，可以打印error的值查看错误信息
        NSLog(@"%@",error);
    }];
}
```

###4.使用AFN来检测网络状态

```objc
/*
说明：可以使用AFN框架中的AFNetworkReachabilityManager来监听网络状态的改变，也可以利用苹果提供的Reachability来监听。建议在开发中直接使用AFN框架处理。
 */
//使用AFN框架来检测网络状态的改变
-(void)AFNReachability
{
    //1.创建网络监听管理者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];

    //2.监听网络状态的改变
    /*
     AFNetworkReachabilityStatusUnknown          = 未知
     AFNetworkReachabilityStatusNotReachable     = 没有网络
     AFNetworkReachabilityStatusReachableViaWWAN = 3G
     AFNetworkReachabilityStatusReachableViaWiFi = WIFI
     */
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                break;

            default:
                break;
        }
    }];

    //3.开始监听
    [manager startMonitoring];
}

------------------------------------------------------------
//使用苹果提供的Reachability来检测网络状态，如果要持续监听网络状态的概念，需要结合通知一起使用。
//提供下载地址：https://developer.apple.com/library/ios/samplecode/Reachability/Reachability.zip

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //1.注册一个通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChange) name:kReachabilityChangedNotification object:nil];

    //2.拿到一个对象，然后调用开始监听方法
    Reachability *r = [Reachability reachabilityForInternetConnection];
    [r startNotifier];

    //持有该对象，不要让该对象释放掉
    self.r = r;
}

//当控制器释放的时候，移除通知的监听
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)networkChange
{
    //获取当前网络的状态
   if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus == ReachableViaWWAN)
    {
        NSLog(@"当前网络状态为3G");
        return;
    }

    if ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == ReachableViaWiFi)
    {
        NSLog(@"当前网络状态为wifi");
        return;
    }

    NSLog(@"当前没有网络");
}
```

###5.数据安全
```objc
01 攻城利器：Charles（公司中一般都使用该工具来抓包，并做网络测试）
注意：Charles在使用中的乱码问题，可以显示包内容，然后打开info.plist文件，找到java目录下面的VMOptions，在后面添加一项：-Dfile.encoding=UTF-8
02 MD5消息摘要算法是不可逆的。
03 数据加密的方式和规范一般公司会有具体的规定，不必多花时间。
```
###6.HTTPS的基本使用
```objc
1.https简单说明
    HTTPS（全称：Hyper Text Transfer Protocol over Secure Socket Layer），是以安全为目标的HTTP通道，简单讲是HTTP的安全版。
    即HTTP下加入SSL层，HTTPS的安全基础是SSL，因此加密的详细内容就需要SSL。 它是一个URI scheme（抽象标识符体系），句法类同http:体系。用于安全的HTTP数据传输。
    https:URL表明它使用了HTTP，但HTTPS存在不同于HTTP的默认端口及一个加密/身份验证层（在HTTP与TCP之间）。

2.HTTPS和HTTP的区别主要为以下四点：
        一、https协议需要到ca申请证书，一般免费证书很少，需要交费。
        二、http是超文本传输协议，信息是明文传输，https 则是具有安全性的ssl加密传输协议。
        三、http和https使用的是完全不同的连接方式，用的端口也不一样，前者是80，后者是443。
        四、http的连接很简单，是无状态的；HTTPS协议是由SSL+HTTP协议构建的可进行加密传输、身份认证的网络协议，比http协议安全。

3.简单说明
1）HTTPS的主要思想是在不安全的网络上创建一安全信道，并可在使用适当的加密包和服务器证书可被验证且可被信任时，对窃听和中间人攻击提供合理的保护。
2）HTTPS的信任继承基于预先安装在浏览器中的证书颁发机构（如VeriSign、Microsoft等）（意即“我信任证书颁发机构告诉我应该信任的”）。
3）因此，一个到某网站的HTTPS连接可被信任，如果服务器搭建自己的https 也就是说采用自认证的方式来建立https信道，这样一般在客户端是不被信任的。
4）所以我们一般在浏览器访问一些https站点的时候会有一个提示，问你是否继续。

4.对开发的影响。
4.1 如果是自己使用NSURLSession来封装网络请求，涉及代码如下。
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    NSURLSessionDataTask *task =  [session dataTaskWithURL:[NSURL URLWithString:@"https://www.apple.com"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [task resume];
}

/*
 只要请求的地址是HTTPS的, 就会调用这个代理方法
 我们需要在该方法中告诉系统, 是否信任服务器返回的证书
 Challenge: 挑战 质问 (包含了受保护的区域)
 protectionSpace : 受保护区域
 NSURLAuthenticationMethodServerTrust : 证书的类型是 服务器信任
 */
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    //    NSLog(@"didReceiveChallenge %@", challenge.protectionSpace);
    NSLog(@"调用了最外层");
    // 1.判断服务器返回的证书类型, 是否是服务器信任
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSLog(@"调用了里面这一层是服务器信任的证书");
        /*
         NSURLSessionAuthChallengeUseCredential = 0,                     使用证书
         NSURLSessionAuthChallengePerformDefaultHandling = 1,            忽略证书(默认的处理方式)
         NSURLSessionAuthChallengeCancelAuthenticationChallenge = 2,     忽略书证, 并取消这次请求
         NSURLSessionAuthChallengeRejectProtectionSpace = 3,            拒绝当前这一次, 下一次再询问
         */
//        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];

        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential , card);
    }
}

4.2 如果是使用AFN框架，那么我们不需要做任何额外的操作，AFN内部已经做了处理。
```

###7 WebView的基本使用

```objc
1 概念性知识
    01 webView是有缺点的，会导致内存泄露，而且这个问题是它系统本身的问题。
    02 手机上面的safai其实就是用webView来实现的
    03 现在的开发并不完全是原生的开发，而更加倾向于原生+Html5的方式
    04 webView是OC代码和html代码之间进行交互的桥梁

2 代码相关
/*A*网页操控相关方法**/
    [self.webView goBack];      回退
    [self.webView goForward];   前进
    [self.webView reload];      刷新

    //设置是否能够前进和回退
    self.goBackBtn.enabled = webView.canGoBack;
    self.fowardBtn.enabled = webView.canGoForward;

/*B*常用的属性设置**/
    self.webView.scalesPageToFit = YES; 设置网页自动适应
    self.webView.dataDetectorTypes = UIDataDetectorTypeAll; 设置检测网页中的格式类型，all表示检测所有类型包括超链接、电话号码、地址等。
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);

/*C*相关代理方法**/
    //每当将加载请求的时候调用该方法，返回YES 表示加载该请求，返回NO 表示不加载该请求
    //可以在该方法中拦截请求
    -(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
    {
        return ![request.URL.absoluteString containsString:@"dushu"];
    }

    //开始加载网页，不仅监听我们指定的请求，还会监听内部发送的请求
    -(void)webViewDidStartLoad:(UIWebView *)webView

    //网页加载完毕之后会调用该方法
    -(void)webViewDidFinishLoad:(UIWebView *)webView

    //网页加载失败调用该方法
    -(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error

/*D*其它知识点-加载本地资源**/
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"text.html" withExtension:nil];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
```

####8 HTML
```objc
1.Html决定网页的内容，css决定网页的样式，js决定网页的事件
2.html学习网站：http://www.w3school.com.cn

```
####9 OC和JS代码的互调
```objc
01 OC调用JS的代码
    NSString *str = [self.webView stringByEvaluatingJavaScriptFromString:@"sum()"];

02 JS怎么调用OC的说明
    新的需求：点击按钮的时候拨打电话
    但是我在点击按钮的时候，用户是不知道的，我们怎么能够知道用户点击了网页上面的一个按钮，只能通过一个技巧，那就是自己搞一个特定的协议头比如说xmg://,当我拦截到你的网络请求的时候，只需要判断一下当前的协议头是不是这个就能判断你现在是否是JS调用。
    OC里面有通过字符串生成SEL类型的方法，所以当拿到数据之后做下面的事情
    1）截取方法的名称
    2）将截取出来的字符串转换为SEL
    3）利用performSelect方法来调用SEL

03 涉及到的相关方法
    [@"abc" hasPrefix:@"A"] //判断字符串是否以一个固定的字符开头，这里为A
    //截串操作
    - (NSString *)substringFromIndex:(NSUInteger)from;
    //切割字符串，返回一个数组
    - (NSArray<NSString *> *)componentsSeparatedByString:(NSString *)separator;
    //替换操作
    - (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement
    //把string包装成SEL

    SEL selector = NSSelectorFromString(sel);

04 如何屏蔽警告
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            //-Warc-performSelector-leaks为唯一的警告标识
            [self performSelector:selector withObject:nil];
    #pragma clang diagnostic pop
```

####10 NSInvocation的基本使用
```objc
//封装invacation可以调用多个参数的方法
-(void)invacation
{
    //1.创建一个MethodSignature，签名中保存了方法的名称，参数和返回值
    //这个方法属于谁，那么就用谁来进行创建
    //注意：签名一般是用来设置参数和获得返回值的，和方法的调用没有太大的关系
    NSMethodSignature *signature = [ViewController instanceMethodSignatureForSelector:@selector(callWithNumber:andContext:withStatus:)];

    /*注意不要写错了方法名称
     //    NSMethodSignature *signature = [ViewController methodSignatureForSelector:@selector(call)];
     */

    //2.通过MethodSignature来创建一个NSInvocation
    //NSInvocation中保存了方法所属于的对象|方法名称|参数|返回值等等
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];

    /*2.1 设置invocation，来调用方法*/

    invocation.target = self;
    //    invocation.selector = @selector(call);
    //    invocation.selector = @selector(callWithNumber:);
    //    invocation.selector = @selector(callWithNumber:andContext:);
    invocation.selector = @selector(callWithNumber:andContext:withStatus:);

    NSString *number = @"10086";
    NSString *context = @"下课了";
    NSString *status = @"睡觉的时候";

    //注意：
    //1.自定义的参数索引从2开始，0和1已经被self and _cmd占用了
    //2.方法签名中保存的方法名称必须和调用的名称一致
    [invocation setArgument:&number atIndex:2];
    [invocation setArgument:&context atIndex:3];
    [invocation setArgument:&status atIndex:4];

    /*3.调用invok方法来执行*/
    [invocation invoke];
}
```
####11 异常处理
```objc
01 一般处理方式：
    a.app异常闪退，那么捕获crash信息，并记录在本地沙盒中。
    b.当下次用户重新打开app的时候，检查沙盒中是否保存有上次捕获到的crash信息。
    c.如果有那么利用专门的接口发送给服务器，以求在后期版本中修复。

02 如何抛出异常

    //抛出异常的两种方式
        // @throw  [NSException exceptionWithName:@"好大一个bug" reason:@"异常原因：我也不知道" userInfo:nil];

        //方式二
        NSString *info = [NSString stringWithFormat:@"%@方法找不到",NSStringFromSelector(aSelector)];
        //下面这种方法是自动抛出的
        [NSException raise:@"这是一个异常" format:info,nil];

03 如何捕获异常
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);

    void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    NSString *name = [exception name];//异常类型

    NSString *errorMsg = [NSString stringWithFormat:@"当前调用栈的信息：%@\nCrash的原因：%@\n异常类型：%@\n",arr,reason,name];
    //把该信息保存到本地沙盒，下次回传给服务器。
}

```
####补充
    关于JS相关的学习框架：WebViewJavascriptBridge

###12.Cocoapods的安装
```objc
1.先升级Gem
    sudo gem update --system
2.切换cocoapods的数据源
    【先删除，再添加，查看】
    gem sources --remove https://rubygems.org/
    gem sources -a https://ruby.taobao.org/
    gem sources -l
3.安装cocoapods
    sudo gem install cocoapods
    或者（如10.11系统）sudo gem install -n /usr/local/bin cocoapods
4.将Podspec文件托管地址从github切换到国内的oschina
    【先删除，再添加，再更新】
    pod repo remove master
    pod repo add master http://git.oschina.net/akuandev/Specs.git
    pod repo add master https://gitcafe.com/akuandev/Specs.git
    pod repo update
5.设置pod仓库
    pod setup
6.测试
    【如果有版本号，则说明已经安装成功】
    pod --version
7.利用cocoapods来安装第三方框架
    01 进入要安装框架的项目的.xcodeproj同级文件夹
    02 在该文件夹中新建一个文件podfile
    03 在文件中告诉cocoapods需要安装的框架信息
        a.该框架支持的平台
        b.适用的iOS版本
        c.框架的名称
        d.框架的版本
8.安装
pod install --no-repo-update
pod update --no-repo-update

9.说明
platform :ios, '8.0' 用来设置所有第三方库所支持的iOS最低版本
pod 'SDWebImage','~>2.6' 设置框架的名称和版本号
版本号的规则：
'>1.0'    可以安装任何高于1.0的版本
'>=1.0'   可以安装任何高于或等于1.0的版本
'<1.0'    任何低于1.0的版本
'<=1.0'   任何低于或等于1.0的版本
'~>0.1'   任何高于或等于0.1的版本，但是不包含高于1.0的版本
'~>0'     任何版本，相当于不指定版本，默认采用最新版本号

10.使用pod install命令安装框架后的大致过程：
01 分析依赖:该步骤会分析Podfile,查看不同类库之间的依赖情况。如果有多个类库依赖于同一个类库，但是依赖于不同的版本，那么cocoaPods会自动设置一个兼容的版本。
02 下载依赖:根据分析依赖的结果，下载指定版本的类库到本地项目中。
03 生成Pods项目：创建一个Pods项目专门用来编译和管理第三方框架，CocoaPods会将所需的框架，库等内容添加到项目中，并且进行相应的配置。
04 整合Pods项目：将Pods和项目整合到一个工作空间中，并且设置文件链接。


```

####13.Base64补充
```objc
1.Base64简单说明
    描述：Base64可以成为密码学的基石，非常重要。
    特点：可以将任意的二进制数据进行Base64编码
    结果：所有的数据都能被编码为并只用65个字符就能表示的文本文件。
    65字符：A~Z a~z 0~9 + / =
    对文件进行base64编码后文件数据的变化：编码后的数据~=编码前数据的4/3，会大1/3左右。

2.命令行进行Base64编码和解码
    编码：base64 123.png -o 123.txt
    解码：base64 123.txt -o test.png -D

2.Base64编码原理
    1)将所有字符转化为ASCII码；
    2)将ASCII码转化为8位二进制；
    3)将二进制3个归成一组(不足3个在后边补0)共24位，再拆分成4组，每组6位；
    4)统一在6位二进制前补两个0凑足8位；
    5)将补0后的二进制转为十进制；
    6)从Base64编码表获取十进制对应的Base64编码；

处理过程说明：
    a.转换的时候，将三个byte的数据，先后放入一个24bit的缓冲区中，先来的byte占高位。
    b.数据不足3byte的话，于缓冲区中剩下的bit用0补足。然后，每次取出6个bit，按照其值选择查表选择对应的字符作为编码后的输出。
    c.不断进行，直到全部输入数据转换完成。
    d.如果最后剩下两个输入数据，在编码结果后加1个“=”；
    e.如果最后剩下一个输入数据，编码结果后加2个“=”；
    f.如果没有剩下任何数据，就什么都不要加，这样才可以保证资料还原的正确性。

3.实现
    a.说明：
        1）从iOS7.0 开始，苹果就提供了base64的编码和解码支持
        2)如果是老项目，则还能看到base64编码和解码的第三方框架，如果当前不再支持iOS7.0以下版本，则建议替换。

    b.相关代码：
    //给定一个字符串，对该字符串进行Base64编码，然后返回编码后的结果
    -(NSString *)base64EncodeString:(NSString *)string
    {
        //1.先把字符串转换为二进制数据
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

        //2.对二进制数据进行base64编码，返回编码后的字符串
        return [data base64EncodedStringWithOptions:0];
    }

    //对base64编码后的字符串进行解码
    -(NSString *)base64DecodeString:(NSString *)string
    {
        //1.将base64编码后的字符串『解码』为二进制数据
        NSData *data = [[NSData alloc]initWithBase64EncodedString:string options:0];

        //2.把二进制数据转换为字符串返回
        return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }

    c.终端测试命令
        $ echo -n A | base64
        $ echo -n QQ== |base64 -D
```

####14.加密相关
```objc
网络应用程序数据的原则：

1. 在网络上"不允许"传输用户隐私数据的"明文"
2. 在本地"不允许"保存用户隐私数据的"明文"

加密相关

1. base64 编码格式
2. 密码学演化 "秘密本"-->RSA

RSA简单说明：加密算法算法是公开的，加密方式如下：

- "公钥"加密，"私钥"解密
- "私钥"加密，"公钥"解密

目前流行的加密方式:
---------------
- 哈希(散列)函数
    - MD5
    - SHA1
    - SHA256

- 对称加密算法
    - DES
    - 3DES
    - AES(高级密码标准，美国国家安全局使用的)

- 非对称加密算法(RSA)

散列函数:
---------------
特点：
    - 算法是公开的
    - "对相同的数据加密，得到的结果是一样的"
    - 对不同的数据加密，得到的结果是定长的，MD5对不同的数据进行加密，得到的结果都是 32 个字符长度的字符串
    - 信息摘要，信息"指纹"，是用来做数据识别的！
    - 不能反算的

用途：
    - 密码，服务器并不需要知道用户真实的密码！
    - 搜索
        张老师 杨老师 苍老师
        苍老师 张老师 杨老师

        张老师            1bdf605991920db11cbdf8508204c4eb
        杨老师             2d97fbce49977313c2aae15ea77fec0f
        苍老师             692e92669c0ca340eff4fdcef32896ee

        如何判断：对搜索的每个关键字进行三列，得到三个相对应的结果，按位相加结果如果是一样的，那搜索的内容就是一样的！
    - 版权
        版权保护，文件的识别。

破解：
    - http://www.cmd5.com 记录超过24万亿条，共占用160T硬盘 的密码数据，通过对海量数据的搜索得到的结果！

提升MD5加密安全性，有两个解决办法
1. 加"盐"(佐料)
2. HMAC：给定一个"秘钥"，对明文进行加密，并且做"两次散列"！-> 得到的结果，还是 32 个字符


```

- Posted by 博客园·[文顶顶](http://www.cnblogs.com/wendingding/)
- 联系作者 简书·[文顶顶](http://www.jianshu.com/users/c5703017b9f5/latest_articleshttp://www.jianshu.com/users/c5703017b9f5/latest_articles) 新浪微博·[文顶顶_iOS](http://weibo.com/p/1005053800117445/home?from=page_100505&mod=TAB#place)
- 原创文章，版权声明：自由转载-非商用-非衍生-保持署名 | [小码哥教育·文顶顶](http://520it.com)
