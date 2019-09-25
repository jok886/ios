# 第二天

###0.补充
```objc
使用Crearte函数创建的并发队列和全局并发队列的主要区别：
1.全局并发队列在整个应用程序中本身是默认存在的，并且对应有高优先级、默认优先级、低优先级和后台优先级一共四个并发队列，我们只是选择其中的一个直接拿来用。而Crearte函数是实打实的从头开始去创建一个队列。
2.在iOS6.0之前，在GCD中凡是使用了带Create和retain的函数在最后都需要做一次release操作。而主队列和全局并发队列不需要我们手动release。当然了，在iOS6.0之后GCD已经被纳入到了ARC的内存管理范畴中，即便是使用retain或者create函数创建的对象也不再需要开发人员手动释放，我们像对待普通OC对象一样对待GCD就OK。
3.在使用栅栏函数的时候，苹果官方明确规定栅栏函数只有在和使用create函数自己的创建的并发队列一起使用的时候才有效（没有给出具体原因）
4.其它区别涉及到XNU内核的系统级线程编程，不一一列举。
5.给出一些参考资料（可以自行研究）：

GCDAPI:https://developer.apple.com/library/ios/documentation/Performance/Reference/GCD_libdispatch_Ref/index.html#//apple_ref/c/func/dispatch_queue_create

Libdispatch版本源码：http://www.opensource.apple.com/source/libdispatch/libdispatch-187.5/
```
###1.单例模式
- 1.1 概念相关

（1）单例模式

    在程序运行过程，一个类只有一个实例
（2）使用场合

    在整个应用程序中，共享一份资源（这份资源只需要创建初始化1次）

- 1.2 ARC实现单例

（1）步骤

    01 在类的内部提供一个static修饰的全局变量
    02 提供一个类方法，方便外界访问
    03 重写+allocWithZone方法，保证永远都只为单例对象分配一次内存空间
    04 严谨起见，重写-copyWithZone方法和-MutableCopyWithZone方法

（2）相关代码

```objc
//提供一个static修饰的全局变量，强引用着已经实例化的单例对象实例
static XMGTools *_instance;

//类方法，返回一个单例对象
+(instancetype)shareTools
{
     //注意：这里建议使用self,而不是直接使用类名Tools（考虑继承）

    return [[self alloc]init];
}

//保证永远只分配一次存储空间
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    //使用GCD中的一次性代码
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _instance = [super allocWithZone:zone];
//    });

    //使用加锁的方式，保证只分配一次存储空间
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    }
    return _instance;
}
/*
1. mutableCopy 创建一个新的可变对象，并初始化为原对象的值，新对象的引用计数为 1；
2. copy 返回一个不可变对象。分两种情况：（1）若原对象是不可变对象，那么返回原对象，并将其引用计数加 1 ；（2）若原对象是可变对象，那么创建一个新的不可变对象，并初始化为原对象的值，新对象的引用计数为 1。
*/
//让代码更加的严谨
-(nonnull id)copyWithZone:(nullable NSZone *)zone
{
//    return [[self class] allocWithZone:zone];
    return _instance;
}

-(nonnull id)mutableCopyWithZone:(nullable NSZone *)zone
{
    return _instance;
}

```
- 1.3 MRC实现单例

（1）实现步骤

    01 在类的内部提供一个static修饰的全局变量
    02 提供一个类方法，方便外界访问
    03 重写+allocWithZone方法，保证永远都只为单例对象分配一次内存空间
    04 严谨起见，重写-copyWithZone方法和-MutableCopyWithZone方法
    05 重写release方法
    06 重写retain方法
    07 建议在retainCount方法中返回一个最大值

（2）配置MRC环境知识

    01 注意ARC不是垃圾回收机制，是编译器特性
    02 配置MRC环境：build setting ->搜索automatic ref->修改为NO

（3）相关代码
```objc
//提供一个static修饰的全局变量，强引用着已经实例化的单例对象实例
static XMGTools *_instance;

//类方法，返回一个单例对象
+(instancetype)shareTools
{
     //注意：这里建议使用self,而不是直接使用类名Tools（考虑继承）

    return [[self alloc]init];
}

//保证永远只分配一次存储空间
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    //使用GCD中的一次性代码
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _instance = [super allocWithZone:zone];
//    });

    //使用加锁的方式，保证只分配一次存储空间
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    }
    return _instance;
}

//让代码更加的严谨
-(nonnull id)copyWithZone:(nullable NSZone *)zone
{
//    return [[self class] allocWithZone:zone];
    return _instance;
}

-(nonnull id)mutableCopyWithZone:(nullable NSZone *)zone
{
    return _instance;
}

//在MRC环境下，如果用户retain了一次，那么直接返回instance变量，不对引用计数器+1
//如果用户release了一次，那么什么都不做，因为单例模式在整个程序运行过程中都拥有且只有一份，程序退出之后被释放，所以不需要对引用计数器操作
-(oneway void)release
{
}

-(instancetype)retain
{
    return _instance;
}

//惯用法，有经验的程序员通过打印retainCount这个值可以猜到这是一个单例
-(NSUInteger)retainCount
{
    return MAXFLOAT;
}

```
- 1.4 通用版本

（1）有意思的对话

    01 问:写一份单例代码在ARC和MRC环境下都适用？
    答：可以使用条件编译来判断当前项目环境是ARC还是MRC
    02 问:条件编译的代码呢，么么哒？
```objc
//答：条件编译
#if __has_feature(objc_arc)
//如果是ARC，那么就执行这里的代码1
#else
//如果不是ARC，那么就执行代理的代码2
#endif
```
    03 问：在项目里面往往需要实现很多的单例，比如下载、网络请求、音乐播放等等，弱弱的问一句单例可以用继承吗？
    答：单例是不可以用继承的，如果想一次写就，四处使用，那么推荐亲使用带参数的宏定义啦！
    04 问：宏定义怎么弄？
    答：这个嘛~~回头看一眼我的代码咯，亲。

（2）使用带参数的宏完成通用版单例模式代码

    01 注意条件编译的代码不能包含在宏定义里面
    02 宏定义的代码只需要写一次就好，之后直接拖到项目中用就OK


###2.NSOperation
- 2.1 NSOperation基本使用

（1）相关概念

    01 NSOperation是对GCD的包装
    02 两个核心概念【队列+操作】

（2）基本使用

    01 NSOperation本身是抽象类，只能只有它的子类
    02 三个子类分别是：NSBlockOperation、NSInvocationOperation以及自定义继承自NSOperation的类
    03 NSOperation和NSOperationQueue结合使用实现多线程并发

（3）相关代码
```objc
//  01 NSInvocationOperation
    //1.封装操作
    /*
     第一个参数：目标对象
     第二个参数：该操作要调用的方法，最多接受一个参数
     第三个参数：调用方法传递的参数，如果方法不接受参数，那么该值传nil
     */
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]
                                        initWithTarget:self selector:@selector(run) object:nil];

    //2.启动操作
    [operation start];
-------------------------------------------------
    //  02 NSBlockOperation
    //1.封装操作
    /*
     NSBlockOperation提供了一个类方法，在该类方法中封装操作
     */
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        //在主线程中执行
        NSLog(@"---download1--%@",[NSThread currentThread]);
    }];

    //2.追加操作，追加的操作在子线程中执行
    [operation addExecutionBlock:^{
        NSLog(@"---download2--%@",[NSThread currentThread]);
    }];

    [operation addExecutionBlock:^{
         NSLog(@"---download3--%@",[NSThread currentThread]);
    }];

    //3.启动执行操作
    [operation start];

----------------------------------------------
// 03 自定义NSOperation
    //如何封装操作？
    //自定义的NSOperation,通过重写内部的main方法实现封装操作
    -(void)main
    {
        NSLog(@"--main--%@",[NSThread currentThread]);
    }

    //如何使用？
    //1.实例化一个自定义操作对象
    XMGOperation *op = [[XMGOperation alloc]init];

    //2.执行操作
    [op start];
```
- 2.2 NSOperationQueue基本使用

（1）NSOperation中的两种队列

    01 主队列 通过mainQueue获得，凡是放到主队列中的任务都将在主线程执行
    02 非主队列 直接alloc init出来的队列。非主队列同时具备了并发和串行的功能，通过设置最大并发数属性来控制任务是并发执行还是串行执行
（2）相关代码
```objc
//自定义NSOperation
-(void)customOperation
{
    //1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    //2.封装操作
    //好处：1.信息隐蔽
    //2.代码复用

    XMGOperation *op1 = [[XMGOperation alloc]init];
    XMGOperation *op2 = [[XMGOperation alloc]init];

    //3.添加操作到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];
}

//NSBlockOperation
- (void)block
{
    //1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    //2.封装操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1----%@",[NSThread currentThread]);
    }];

    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2----%@",[NSThread currentThread]);

    }];

    [op2 addExecutionBlock:^{
        NSLog(@"3----%@",[NSThread currentThread]);
    }];

    [op2 addExecutionBlock:^{
        NSLog(@"4----%@",[NSThread currentThread]);
    }];

    //3.添加操作到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];

    //补充：简便方法
    [queue addOperationWithBlock:^{
        NSLog(@"5----%@",[NSThread currentThread]);
    }];

}

//NSInvocationOperation
- (void)invocation
{
    /*
     GCD中的队列：
     串行队列：自己创建的，主队列
     并发队列：自己创建的，全局并发队列

     NSOperationQueue
     主队列：[NSOperationQueue mainqueue];凡事放在主队列中的操作都在主线程中执行
     非主队列：[[NSOperationQueue alloc]init]，并发和串行，默认是并发执行的
     */

    //1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    //2.封装操作
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(download1) object:nil];

    NSInvocationOperation *op2 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(download2) object:nil];


    NSInvocationOperation *op3 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(download3) object:nil];


    //3.把封装好的操作添加到队列中
    [queue addOperation:op1];//[op1 start]
    [queue addOperation:op2];
    [queue addOperation:op3];
}

```
- 2.3 NSOperation其它用法

（1）设置最大并发数【控制任务并发和串行】
```objc
//1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    //2.设置最大并发数
    //注意点：该属性需要在任务添加到队列中之前进行设置
    //该属性控制队列是串行执行还是并发执行
    //如果最大并发数等于1，那么该队列是串行的，如果大于1那么是并行的
    //系统的最大并发数有个默认的值，为-1，如果该属性设置为0，那么不会执行任何任务
    queue.maxConcurrentOperationCount = 2;
```

（2）暂停和恢复以及取消
```objc
    //设置暂停和恢复
    //suspended设置为YES表示暂停，suspended设置为NO表示恢复
    //暂停表示不继续执行队列中的下一个任务，暂停操作是可以恢复的
    if (self.queue.isSuspended) {
        self.queue.suspended = NO;
    }else
    {
        self.queue.suspended = YES;
    }

    //取消队列里面的所有操作
    //取消之后，当前正在执行的操作的下一个操作将不再执行，而且永远都不在执行，就像后面的所有任务都从队列里面移除了一样
    //取消操作是不可以恢复的
    [self.queue cancelAllOperations];

---------自定义NSOperation取消操作--------------------------
-(void)main
{
    //耗时操作1
    for (int i = 0; i<1000; i++) {
        NSLog(@"任务1-%d--%@",i,[NSThread currentThread]);
    }
    NSLog(@"+++++++++++++++++++++++++++++++++");

    //苹果官方建议，每当执行完一次耗时操作之后，就查看一下当前队列是否为取消状态，如果是，那么就直接退出
    //好处是可以提高程序的性能
    if (self.isCancelled) {
        return;
    }

    //耗时操作2
    for (int i = 0; i<1000; i++) {
        NSLog(@"任务1-%d--%@",i,[NSThread currentThread]);
    }

    NSLog(@"+++++++++++++++++++++++++++++++++");
}
```

- 2.4 NSOperation实现线程间通信

（1）开子线程下载图片
```objc
 //1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    //2.使用简便方法封装操作并添加到队列中
    [queue addOperationWithBlock:^{

        //3.在该block中下载图片
        NSURL *url = [NSURL URLWithString:@"http://news.51sheyuan.com/uploads/allimg/111001/133442IB-2.jpg"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        NSLog(@"下载图片操作--%@",[NSThread currentThread]);

        //4.回到主线程刷新UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = image;
            NSLog(@"刷新UI操作---%@",[NSThread currentThread]);
        }];
    }];

```
（2）下载多张图片合成综合案例（设置操作依赖）
```objc
//02 综合案例
- (void)download2
{
    NSLog(@"----");
    //1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    //2.封装操作下载图片1
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{

        NSURL *url = [NSURL URLWithString:@"http://h.hiphotos.baidu.com/zhidao/pic/item/6a63f6246b600c3320b14bb3184c510fd8f9a185.jpg"];
        NSData *data = [NSData dataWithContentsOfURL:url];

        //拿到图片数据
        self.image1 = [UIImage imageWithData:data];
    }];


    //3.封装操作下载图片2
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:@"http://pic.58pic.com/58pic/13/87/82/27Q58PICYje_1024.jpg"];
        NSData *data = [NSData dataWithContentsOfURL:url];

        //拿到图片数据
        self.image2 = [UIImage imageWithData:data];
    }];

    //4.合成图片
    NSBlockOperation *combine = [NSBlockOperation blockOperationWithBlock:^{

        //4.1 开启图形上下文
        UIGraphicsBeginImageContext(CGSizeMake(200, 200));

        //4.2 画image1
        [self.image1 drawInRect:CGRectMake(0, 0, 200, 100)];

        //4.3 画image2
        [self.image2 drawInRect:CGRectMake(0, 100, 200, 100)];

        //4.4 根据图形上下文拿到图片数据
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        NSLog(@"%@",image);

        //4.5 关闭图形上下文
        UIGraphicsEndImageContext();

        //7.回到主线程刷新UI
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            self.imageView.image = image;
            NSLog(@"刷新UI---%@",[NSThread currentThread]);
        }];

    }];

    //5.设置操作依赖
    [combine addDependency:op1];
    [combine addDependency:op2];

    //6.添加操作到队列中执行
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:combine];
    }
```
###3.多图下载综合示例程序
（1）涉及知识点

         01 字典转模型
         02 存储数据到沙盒，从沙盒中加载数据
         03 占位图片的设置（cell的刷新问题）
         04 如何进行内存缓存（使用NSDictionary）
         05 在程序开发过程中的一些容错处理
         06 如何刷新tableView的指定行（解决数据错乱问题）
         07 NSOperation以及线程间通信相关知识

###4.第三方框架

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

    06 如何判断当前图片类型
    + (NSString *)sd_contentTypeForImageData:(NSData *)data;


```
（2）SDWebImage内部结构

![PNG](1.png)
