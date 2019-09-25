# 第三天

####0.第三方框架SDWebImage

（1）SDWebImage基本使用
```objc
    01 设置imageView的图片
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:app.icon] placeholderImage:[UIImage imageNamed:@"placehoder"]];

    02 设置图片并计算下载进度
       //下载并设置图片
    /*
     第一个参数：要下载图片的url地址
     第二个参数：设置该imageView的占位图片
     第三个参数：传一个枚举值，告诉程序你下载图片的策略是什么
     第一个block块：获取当前图片数据的下载进度
         receivedSize：已经下载完成的数据大小
         expectedSize：该文件的数据总大小
     第二个block块：当图片下载完成之后执行该block中的代码
         image:下载得到的图片数据
         error:下载出现的错误信息
         SDImageCacheType：图片的缓存策略（不缓存，内存缓存，沙盒缓存）
         imageURL：下载的图片的url地址
     */
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:app.icon] placeholderImage:[UIImage imageNamed:@"placehoder"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {

        //计算当前图片的下载进度
        NSLog(@"%.2f",1.0 *receivedSize / expectedSize);

    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

    }];

    03 系统级内存警告如何处理（面试）
    //取消当前正在进行的所有下载操作
    [[SDWebImageManager sharedManager] cancelAll];

    //清除缓存数据(面试)
    //cleanDisk：删除过期的文件数据，计算当前未过期的已经下载的文件数据的大小，如果发现该数据大小大于我们设置的最大缓存数据大小，那么程序内部会按照按文件数据缓存的时间从远到近删除，知道小于最大缓存数据为止。

    //clearMemory:直接删除文件，重新创建新的文件夹
    //[[SDWebImageManager sharedManager].imageCache cleanDisk];
    [[SDWebImageManager sharedManager].imageCache clearMemory];

    04 SDWebImage默认的缓存时间是1周
    05 如何播放gif图片
    /*
    5-1 把用户传入的gif图片->NSData
    5-2 根据该Data创建一个图片数据源（NSData->CFImageSourceRef）
    5-3 计算该数据源中一共有多少帧，把每一帧数据取出来放到图片数组中
    5-4 根据得到的数组+计算的动画时间-》可动画的image
    [UIImage animatedImageWithImages:images duration:duration];
    */

    06 如何判断当前图片类型，只判断图片二进制数据的第一个字节
    + (NSString *)sd_contentTypeForImageData:(NSData *)data;

    07 内部如何进行缓存处理？使用了NSCache类，使用和NSDictionary类似
    08 沙盒缓存图片的命名方式为对该图片的URL进行MD5加密  echo -n "url" |MD5
    09 当接收到内存警告之后，内部会自动清理内存缓存
    10 图片的下载顺序，默认是先进先出的

```
（2）SDWebImage内部结构

![PNG](1-2.png)

---

####1.Runloop基础知识
- 1.1 字面意思

		a 运行循环
		b 跑圈

- 1.2 基本作用（作用重大）

		a 保持程序的持续运行(ios程序为什么能一直活着不会死)
		b 处理app中的各种事件（比如触摸事件、定时器事件【NSTimer】、selector事件【选择器·performSelector···】）
		c 节省CPU资源，提高程序性能，有事情就做事情，没事情就休息

- 1.3 重要说明

        （1）如果没有Runloop,那么程序一启动就会退出，什么事情都做不了。
        （2）如果有了Runloop，那么相当于在内部有一个死循环，能够保证程序的持续运行
        （2）main函数中的Runloop
        		a 在UIApplication函数内部就启动了一个Runloop
        			该函数返回一个int类型的值
        		b 这个默认启动的Runloop是跟主线程相关联的

- 1.4 Runloop对象

        （1）在iOS开发中有两套api来访问Runloop
            a.foundation框架【NSRunloop】
            b.core foundation框架【CFRunloopRef】
        （2）NSRunLoop和CFRunLoopRef都代表着RunLoop对象,它们是等价的，可以互相转换
        （3）NSRunLoop是基于CFRunLoopRef的一层OC包装，所以要了解RunLoop内部结构，需要多研究CFRunLoopRef层面的API（Core Foundation层面）


- 1.5 Runloop参考资料

```objc
（1）苹果官方文档
https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html

（2）CFRunLoopRef开源代码下载地址：
http://opensource.apple.com/source/CF/CF-1151.16/

```

- 1.6 Runloop与线程

		1.Runloop和线程的关系：一个Runloop对应着一条唯一的线程
    		问题：如何让子线程不死
    		回答：给这条子线程开启一个Runloop
		2.Runloop的创建：主线程Runloop已经创建好了，子线程的runloop需要手动创建
		3.Runloop的生命周期：在第一次获取时创建，在线程结束时销毁

- 1.7 获得Runloop对象

```objc
1.获得当前Runloop对象
    //01 NSRunloop
     NSRunLoop * runloop1 = [NSRunLoop currentRunLoop];
    //02 CFRunLoopRef
    CFRunLoopRef runloop2 =   CFRunLoopGetCurrent();

2.拿到当前应用程序的主Runloop（主线程对应的Runloop）
    //01 NSRunloop
     NSRunLoop * runloop1 = [NSRunLoop mainRunLoop];
    //02 CFRunLoopRef
     CFRunLoopRef runloop2 =   CFRunLoopGetMain();

3.注意点：开一个子线程创建runloop,不是通过alloc init方法创建，而是直接通过调用currentRunLoop方法来创建，它本身是一个懒加载的。
4.在子线程中，如果不主动获取Runloop的话，那么子线程内部是不会创建Runloop的。可以下载CFRunloopRef的源码，搜索_CFRunloopGet0,查看代码。
5.Runloop对象是利用字典来进行存储，而且key是对应的线程Value为该线程对应的Runloop。

```
- 1.8 Runloop相关类

（1）Runloop运行原理图

![PNG](2.png)

（2）五个相关的类

	a.CFRunloopRef
	b.CFRunloopModeRef【Runloop的运行模式】
	c.CFRunloopSourceRef【Runloop要处理的事件源】
	d.CFRunloopTimerRef【Timer事件】
	e.CFRunloopObserverRef【Runloop的观察者（监听者）】

（3）Runloop和相关类之间的关系图

 ![PNG](1.png)

（4）Runloop要想跑起来，它的内部必须要有一个mode,这个mode里面必须有source\observer\timer，至少要有其中的一个。

- CFRunloopModeRef

    	1.CFRunloopModeRef代表着Runloop的运行模式
    	2.一个Runloop中可以有多个mode,一个mode里面又可以有多个source\observer\timer等等
    	3.每次runloop启动的时候，只能指定一个mode,这个mode被称为该Runloop的当前mode
    	4.如果需要切换mode,只能先退出当前Runloop,再重新指定一个mode进入
    	5.这样做主要是为了分割不同组的定时器等，让他们相互之间不受影响
    	6.系统默认注册了5个mode
    	    a.kCFRunLoopDefaultMode：App的默认Mode，通常主线程是在这个Mode下运行
            b.UITrackingRunLoopMode：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响
            c.UIInitializationRunLoopMode: 在刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用
            d.GSEventReceiveRunLoopMode: 接受系统事件的内部 Mode，通常用不到
            e.kCFRunLoopCommonModes: 这是一个占位用的Mode，不是一种真正的Mode


- CFRunloopTimerRef

（1）NSTimer相关代码
```objc
/*
	说明：
	（1）runloop一启动就会选中一种模式，当选中了一种模式之后其它的模式就都不鸟。一个mode里面可以添加多个NSTimer,也就是说以后当创建NSTimer的时候，可以指定它是在什么模式下运行的。
	（2）它是基于时间的触发器，说直白点那就是时间到了我就触发一个事件，触发一个操作。基本上说的就是NSTimer
	（3）相关代码
*/
- (void)timer2
{
    //NSTimer 调用了scheduledTimer方法，那么会自动添加到当前的runloop里面去，而且runloop的运行模式kCFRunLoopDefaultMode

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];

    //更改模式
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

}

- (void)timer1
{
    //    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];

    NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];

    //定时器添加到UITrackingRunLoopMode模式，一旦runloop切换模式，那么定时器就不工作
    //    [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];

    //定时器添加到NSDefaultRunLoopMode模式，一旦runloop切换模式，那么定时器就不工作
    //    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

    //占位模式：common modes标记
    //被标记为common modes的模式 kCFRunLoopDefaultMode  UITrackingRunLoopMode
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

    //    NSLog(@"%@",[NSRunLoop currentRunLoop]);
}

- (void)run
{
    NSLog(@"---run---%@",[NSRunLoop currentRunLoop].currentMode);
}

- (IBAction)btnClick {

    NSLog(@"---btnClick---");
}

```

（2）GCD中的定时器
```objc
//0.创建一个队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);

    //1.创建一个GCD的定时器
    /*
     第一个参数：说明这是一个定时器
     第四个参数：GCD的回调任务添加到那个队列中执行，如果是主队列则在主线程执行
     */
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    //2.设置定时器的开始时间，间隔时间以及精准度

    //设置开始时间，三秒钟之后调用
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW,3.0 *NSEC_PER_SEC);
    //设置定时器工作的间隔时间
    uint64_t intevel = 1.0 * NSEC_PER_SEC;

    /*
     第一个参数：要给哪个定时器设置
     第二个参数：定时器的开始时间DISPATCH_TIME_NOW表示从当前开始
     第三个参数：定时器调用方法的间隔时间
     第四个参数：定时器的精准度，如果传0则表示采用最精准的方式计算，如果传大于0的数值，则表示该定时切换i可以接收该值范围内的误差，通常传0
     该参数的意义：可以适当的提高程序的性能
     注意点：GCD定时器中的时间以纳秒为单位（面试）
     */

    dispatch_source_set_timer(timer, start, intevel, 0 * NSEC_PER_SEC);

    //3.设置定时器开启后回调的方法
    /*
     第一个参数：要给哪个定时器设置
     第二个参数：回调block
     */
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"------%@",[NSThread currentThread]);
    });

    //4.执行定时器
    dispatch_resume(timer);

    //注意：dispatch_source_t本质上是OC类，在这里是个局部变量，需要强引用
    self.timer = timer;

GCD定时器补充
/*
 DISPATCH_SOURCE_TYPE_TIMER         定时响应（定时器事件）
 DISPATCH_SOURCE_TYPE_SIGNAL        接收到UNIX信号时响应

 DISPATCH_SOURCE_TYPE_READ          IO操作，如对文件的操作、socket操作的读响应
 DISPATCH_SOURCE_TYPE_WRITE         IO操作，如对文件的操作、socket操作的写响应
 DISPATCH_SOURCE_TYPE_VNODE         文件状态监听，文件被删除、移动、重命名
 DISPATCH_SOURCE_TYPE_PROC          进程监听,如进程的退出、创建一个或更多的子线程、进程收到UNIX信号

 下面两个都属于Mach相关事件响应
    DISPATCH_SOURCE_TYPE_MACH_SEND
    DISPATCH_SOURCE_TYPE_MACH_RECV
 下面两个都属于自定义的事件，并且也是有自己来触发
    DISPATCH_SOURCE_TYPE_DATA_ADD
    DISPATCH_SOURCE_TYPE_DATA_OR
 */
```

- CFRunloopSourceRef

    	1.是事件源也就是输入源，有两种分类模式；
    	  一种是按照苹果官方文档进行划分的
    	  另一种是基于函数的调用栈来进行划分的（source0和source1）。
        2.具体的分类情况
            （1）以前的分法
                Port-Based Sources
                Custom Input Sources
                Cocoa Perform Selector Sources

            （2）现在的分法
                Source0：非基于Port的
                Source1：基于Port的
        3.可以通过打断点的方式查看一个方法的函数调用栈

- CFRunLoopObserverRef

（1）CFRunLoopObserverRef是观察者，能够监听RunLoop的状态改变

（2）如何监听
```objc
 //创建一个runloop监听者
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(),kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {

        NSLog(@"监听runloop状态改变---%zd",activity);
    });

    //为runloop添加一个监听者
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);

    CFRelease(observer);
```
（3）监听的状态
```objc
typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    kCFRunLoopEntry = (1UL << 0),   //即将进入Runloop
    kCFRunLoopBeforeTimers = (1UL << 1),    //即将处理NSTimer
    kCFRunLoopBeforeSources = (1UL << 2),   //即将处理Sources
    kCFRunLoopBeforeWaiting = (1UL << 5),   //即将进入休眠
    kCFRunLoopAfterWaiting = (1UL << 6),    //刚从休眠中唤醒
    kCFRunLoopExit = (1UL << 7),            //即将退出runloop
    kCFRunLoopAllActivities = 0x0FFFFFFFU   //所有状态改变
};
```

- 1.9 Runloop运行逻辑
-
![PNG](3.png)
--------------------
![PNG](4.png)

---

####2.Runloop应用

    1）NSTimer
    2）ImageView显示：控制方法在特定的模式下可用
    3）PerformSelector
    4）常驻线程：在子线程中开启一个runloop
    5）自动释放池
        第一次创建：进入runloop的时候
        最后一次释放：runloop退出的时候
        其它创建和释放：当runloop即将休眠的时候会把之前的自动释放池释放，然后重新创建一个新的释放池

---

###3.网络基础
- 3.1 网络基础

		001 问题：为什么要学习网络编程？
		    回答：（1）网络编程是一种实时更新应用数据的常用手段
                 （2）网络编程是开发优秀网络应用的前提和基础

		002 网络基本概念
			2-1 客户端（就是手机或者ipad等手持设备上面的APP）
			2-2 服务器（远程服务器-本地服务器）
			2-3 请求（客户端索要数据的方式）
			2-4 响应（需要客户端解析数据）
			2-5 数据库（服务器的数据从哪里来）

- 3.2 Http

		001 URL
			1-1 如何找到服务器（通过一个唯一的URL）
			1-2 URL介绍
				a. 统一资源定位符
				b. url格式（协议\主机地址\路径）
				    协议：不同的协议，代表着不同的资源查找方式、资源传输方式
                    主机地址：存放资源的主机（服务器）的IP地址（域名）
                    路径：资源在主机（服务器）中的具体位置

			1-3 请求协议
				【file】访问的是本地计算机上的资源，格式是file://（不用加主机地址）
				【ftp】访问的是共享主机的文件资源，格式是ftp://
				【mailto】访问的是电子邮件地址，格式是mailto:
				【http】超文本传输协议，访问的是远程的网络资源，格式是http://（网络请求中最常用的协议）

		002 http协议
			2-1 http协议简单介绍
			    a.超文本传输协议
			    b.规定客户端和服务器之间的数据传输格式
                c.让客户端和服务器能有效地进行数据沟通

			2-2 http协议优缺点
				a.简单快速（协议简单，服务器端程序规模小，通信速度快）
				b.灵活（允许传输各种数据）
				c.非持续性连接(1.1之前版本是非持续的，即限制每次连接只处理一个请求，服务器对客户端的请求做出响应后，马上断开连接，这种方式可以节省传输时间)
			2-3 基本通信过程
                a.请求：客户端向服务器索要数据
                b.响应：服务器返回客户端相应的数据

		003 GET和POST请求
			3-1 http里面发送请求的方法
			GET（常用）、POST（常用）、OPTIONS、HEAD、PUT、DELETE、TRACE、CONNECT、PATCH

			3-2 GET和POST请求的对比【区别在于参数如何传递】
                GET
                在请求URL后面以?的形式跟上发给服务器的参数，多个参数之间用&隔开，比如
                http://ww.test.com/login?username=123&pwd=234&type=JSON
                由于浏览器和服务器对URL长度有限制，因此在URL后面附带的参数是有限制的，通常不能超过1KB

                POST
                发给服务器的参数全部放在请求体中
                理论上，POST传递的数据量没有限制（具体还得看服务器的处理能力）

			3-3 如何选择【除简单数据查询外，其它的一律使用POST请求】
    			a.如果要传递大量数据，比如文件上传，只能用POST请求
                b.GET的安全性比POST要差些，如果包含机密\敏感信息，建议用POST
                c.如果仅仅是索取数据（数据查询），建议使用GET
                d.如果是增加、修改、删除数据，建议使用POST
		004 iOS中发送http请求的方案
			4-1 苹果原生
				NSURLConnection 03年推出的古老技术
				NSURLSession 	13年推出iOS7之后，以取代NSURLConnection【重点】
				CFNetwork		底层技术、C语言的

			4-2 第三方框架
				ASIHttpRequest
				AFNetworking 		【重点】
				MKNetworkKit

		005 http请求通信过程
			5-1 请求
				【包括请求头+请求体·非必选】
			5-2 响应
				【响应头+响应体】
			5-3 通信过程
				a.发送请求的时候把请求头和请求体（请求体是非必须的）包装成一个请求对象
				b.服务器端对请求进行响应，在响应信息中包含响应头和响应体，响应信息是对服务器端的描述，具体的信息放在响应体中传递给客户端
			5-4 状态码
				【200】：请求成功
				【400】：客户端请求的语法错误，服务器无法解析
				【404】：无法找到资源
				【500】：服务器内部错误，无法完成请求
```

- Posted by 博客园·[文顶顶](http://www.cnblogs.com/wendingding/)
- 联系作者 简书·[文顶顶](http://www.jianshu.com/users/c5703017b9f5/latest_articleshttp://www.jianshu.com/users/c5703017b9f5/latest_articles) 新浪微博·[文顶顶_iOS](http://weibo.com/p/1005053800117445/home?from=page_100505&mod=TAB#place)
- 原创文章，版权声明：自由转载-非商用-非衍生-保持署名 | [小码哥教育·文顶顶](http://520it.com)
