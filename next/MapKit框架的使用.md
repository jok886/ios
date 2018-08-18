# MapKit框架的使用

----
----

## 一. 地图的基本使用
### 1. 设置地图显示类型
1. 地图的样式可以手动设置, 在iOS9.0之前有3种, iOS9.0之后增加了2种

2. 设置方式
		
		self.mapView.mapType = MKMapTypeStandard;
		
	|    枚举类型   	 				|      对应含义      |
	| ------------ 					|   -------------   |
	| MKMapTypeStandard 			| 标准地图  	        |
	| MKMapTypeSatellite 			| 卫星地图 	        |
	| MKMapTypeHybrid	 			| 混合模式(标准+卫星) |
	| MKMapTypeSatelliteFlyover 	| 3D立体卫星(iOS9.0) |
	| MKMapTypeHybridFlyover 	    | 3D立体混合(iOS9.0) |	

### 2. 设置地图控制项
1. 地图的旋转, 缩放, 移动等等操作行为都可以开启或者关闭

2. 设置方式
	
		self.customMapView.zoomEnabled = YES; 	// 是否缩放
		self.customMapView.scrollEnabled = YES; // 是否滚动 
		self.customMapView.rotateEnabled = YES; // 是否旋转
		self.customMapView.pitchEnabled = NO; // 是否显示3DVIEW


### 3. 设置地图显示项
1. 地图上的指南针, 比例尺, 建筑物, POI点都可以控制是否显示

2. 设置方式

		    
    	self.customMapView.showsCompass = YES; // 是否显示指南针
    	self.customMapView.showsScale = YES; // 是否显示比例尺
    	self.customMapView.showsTraffic = YES; // 是否显示交通
    	self.customMapView.showsBuildings = YES; // 是否显示建筑物

### 4. 显示用户位置
1. 可以设置显示用户当前所在位置, 以一个蓝点的形式呈现在地图上

2. 设置方式

		方案1:
			self.customMapView.showsUserLocation = YES;
		效果: 
			会在地图上显示一个蓝点, 标识用户所在位置; 但地图不会缩放, 而且当用户位置移动时, 地图不会跟随用户位置移动而移动
		
		方案2:
			self.customMapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
		效果:
			会在地图上显示一个蓝点, 标识用户所在位置; 而且地图缩放到合适比例,显示用户位置, 当用户位置移动时, 地图会跟随用户位置移动而移动; 但是有时候失效;

	**注意事项: 如果要显示用户位置, 在iOS8.0之后, 需要主动请求用户授权**


### 5. 测试环境
		1. 加载地图数据需要联网
		2. XCode版本根据测试选择不同版本(iOS9.0 只能使用 XCode7.0版本)
		3. iOS系统版本根据测试选择不同版本(例如地图类型, 在iOS9.0之后才有新增)

### 6. 常见问题总结
		1. 地图加载不显示?
			检查网络是否通畅
			
		2. 地图放的太大都是格子, 禁止浏览
			正常, 为了安全等原因, 不会看的太详细
			
		3. 地图运行起来APP占用内存非常大
			正常, 地图加载了很多资源
			
		4. 用户位置不显示
			首先, 检查代码, 是否有设置显示用户位置,是否有进行请求位置授权
			其次, 查看模拟器是否有位置信息
			第三, 重置模拟器, 模拟器又发神经了.

----

## 二. 地图的中级使用
### 1. 查看当前用户位置信息
1. 设置地图代理
2. 实现代理方法

		-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
		{
			NSLog(@"%@", userLocation);
		}

### 2. 调整地图显示中心
1. 确定地图中心经纬度坐标

		CLLocationCoordinate2D center =  CLLocationCoordinate2DMake(21.123, 121.345);

2. 设置地图中心为给定的经纬度坐标

		[mapView setCenterCoordinate:center animated:YES];

### 3. 调整地图显示区域
1. 获取合适的区域跨度

		实现当地图区域发生改变时调用的代理代理方法, 并调整地图区域到合适比例, 并在对应的方法中, 获取对应的跨度信息
		代码如下:
			- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
			{
				NSLog(@"%f---%f", mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
			}

2. 创建一个区域(包含区域中心, 和区域跨度)

			CLLocationCoordinate2D center =  CLLocationCoordinate2DMake(21.123, 121.345);
		    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
		    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);

3. 设置地图显示区域

			[self.mapView setRegion:region animated:YES];


4. 概念解释
	
		MKCoordinateSpan 跨度解释：
			latitudeDelta：纬度跨度，因为南北纬各90.0度，所以此值的范围是（0.0---180.0）；此值表示，整个地图视图宽度，显示多大跨度;
			
			longitudeDelta：经度跨度，因为东西经各180.0度，所以此值范围是（0.0---360.0）：此值表示，整个地图视图高度，显示多大跨度;
			
			注意：地图视图显示，不会更改地图的比例，会以地图视图高度或宽度较小的那个为基准，按比例调整


### 4. MKUserLocation 大头针数据模型详解
	
	 MKUserLocation : 被称作“大头针(数据)模型”;
	 	其实喊什么都行，本质就是一个数据模型，只不过此模型遵循了大头针要遵循的协议（MKAnnotation）
     
     重要属性:
     	location	:  用户当前所在位置信息(CLLocation对象)
     	title		:  大头针标注要显示的标题(NSString对象)
     	subtitle	:  大头针标注要显示的子标题(NSString对象)
	
### 5. 测试环境
		1. 加载地图数据需要联网
		2. XCode版本不限
		3. iOS系统版本不限

### 6. 常见问题总结

		1. 地图上的蓝点为啥不显示?
			第一: 确定代码是否有误(例如, 是否显示了用户位置)
			第二: 确定模拟器是否设置位置
			第三: 看下位置在哪, 是不是不在当前地图显示区域
			
		2. 地图跨度设置之后, 最终显示的跨度和设置数值不一致?
			因为地球的不是正方形的, 随着用户的位置移动, 会自动修正地图跨度, 保持地图不变形;

----

## 三. 地图高级-大头针基本使用 
### 1. 理论支撑(必须掌握)

	按照MVC的原则
	*  在地图上操作大头针,实际上是控制大头针数据模型
		1. 添加大头针就是添加大头针数据模型
		2. 删除大头针就是删除大头针数据模型

### 2. 在地图上添加大头针视图

1. 自定义大头针数据模型
	
		1) 创建继承自NSObject的数据模型XMGAnnotation, 遵循大头针数据模型必须遵循的协议（MKAnnotation）
		2) 注意将协议@property 中的readonly 去掉;
	
2. 创建大头针数据模型, 并初始化参数

		XMGAnnotation *annotation = [[XMGAnnotation alloc] init];
    	annotation.coordinate = coordinate;
    	annotation.title = @"小码哥";
    	annotation.subtitle = @"小码哥分部";

3. 调用地图的添加大头针数据模型方法

		[self.customMapView addAnnotation:annotation];

### 3. 移除大头针(所有大头针)

		NSArray *annotations = self.customMapView.annotations;
		[self.customMapView removeAnnotations:annotations]; 
		
### 4. 场景模拟
	
1. 场景描述: 

		鼠标点击在地图哪个位置, 就在对应的位置添加一个大头针, 并在标注弹框中显示对应的城市和街道;
		
2. 实现步骤

		1. 获取触摸点在地图上对应的坐标
			UITouch *touch = [touches anyObject];
    		CGPoint touchPoint = [touch locationInView:self.customMapView];
    		
    	2. 将坐标转换成为经纬度
    		CLLocationCoordinate2D center = [self.customMapView convertPoint:touchPoint toCoordinateFromView:self.customMapView];
    		
    	3. 根据经纬度创建大头针数据模型, 并添加在地图上
    		XMGAnnotation *annotation = [[XMGAnnotation alloc] init];
    		annotation.coordinate = coordinate;
    		annotation.title = @"小码哥";
    		annotation.subtitle = @"小码哥分部";
    		[self.customMapView addAnnotation:annotation];
		
		4. 利用反地理编码, 获取该点对应的城市和街道名称, 然后修改大头针数据模型
			注意: 设置弹框数据时, 对应的大头针数据模型应有对应的占位数据(这样对应的UI才会生成,后面才能重新修改数据)
	
### 5. 测试环境
	
		1. 加载地图数据需要联网
		2. XCode版本不限
		3. iOS系统版本不限

### 6. 常见问题总结

		1. 反地理编码无法获取对应的数据
			第一: 检查是否有联网
			第二: 检查代码是否有误
			第三: 有时存在某些位置没有反地理编码结果, 换个点尝试, 如果都没有, 排除此原因
			
		2. 大头针协议遵循,属性?
			@property , 其实就是生成了get, 和 set 方法;
			所以, 遵循这个协议, 等同于实现该属性的get, set方法

----

## 四. 地图高级-大头针的自定义 
### 1. 理论支撑

	按照MVC的原则
		1. 每当添加一个大头针数据模型时, 地图就会调用对应的代理方法, 查找对应的大头针视图,显示在地图上;
		2. 如果该方法没有实现, 或者返回nil, 那么就会使用系统默认的大头针视图

### 2. 模拟系统默认的大头针实现方案
1. 实现当添加大头针数据模型时,地图回调的代理方法
	
		-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(XMGAnnotation *)annotation
		{
		
		}

2. 实现须知
	   
		1. 大头针系统对应的视图是 MKPinAnnotationView，它继承自 MKAnnotationView
		2. 地图上的大头针视图，和tableview上的cell一样，都使用“循环利用”的机制

3. 实现代码
		
		static NSString *pinID = @"pinID";
    	MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
    	if (!pinView) {
        	pinView = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:pinID];
	    }
    	pinView.annotation = annotation;

    	// 弹出标注
    	pinView.canShowCallout = YES;

    	// 修改大头针颜色
    	pinView.pinColor = MKPinAnnotationColorPurple;

    	// 设置大头针从天而降
    	pinView.animatesDrop = YES;

    	// 设置大头针可以被拖拽(父类中的属性)
    	pinView.draggable = YES;

    	return pinView;


### 3. 自定义大头针

1. 实现当添加大头针数据模型时,地图回调的代理方法
	
		-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(XMGAnnotation *)annotation
		{
		
		}

2. 实现须知
	   
		1. 如果想要自定义大头针, 必须使用 MKAnnotationView 或者 自定义的子类
		2. 但是不能直接使用系统默认的大头针, 会无效

3. 实现代码
	
	    // 自定义大头针
    	static NSString *pinID = @"pinID";
    	MKAnnotationView *customPinView = [mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
    	if (!customPinView) {
        	customPinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinID];
    	}

    	// 设置大头针图片
    		customPinView.image = [UIImage imageNamed:@"category_3"];
    		
    	// 设置大头针可以弹出标注
    		customPinView.canShowCallout = YES;
    		
    	// 设置标注左侧视图
    		UIImageView *leftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    		leftIV.image = [UIImage imageNamed:@"huba.jpeg"];
    		customPinView.leftCalloutAccessoryView = leftIV;

    	// 设置标注右侧视图
    		UIImageView *rightIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    		rightIV.image = [UIImage imageNamed:@"eason.jpg"];
    		customPinView.rightCalloutAccessoryView = rightIV;

    	// 设置标注详情视图（iOS9.0）
    		customPinView.detailCalloutAccessoryView = [[UISwitch alloc] init];

    	return customPinView;
	
### 4. 代理方法补充	
1. 选中一个大头针时调用

		-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
		{
    		NSLog(@"选中%@", [view.annotation title]);
		}

2. 取消选中大头针时调用

		-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
		{
    		NSLog(@"取消选中%@", [view.annotation title]);
		}

### 5. 测试环境

		1. 加载地图数据需要联网
		2. XCode版本不限
		3. iOS系统版本不限
		
### 6. 常见问题总结

		1. 代码运行在低版本的XCode上, 编译失败
			第一: 语法错误; XCode7.0 对于OC语法优化了一些, 需要手动调整
			第二: iOS9.0的SDK, 在XCode7.0之前的版本没有对应的API

----

## 五. 利用系统App导航 
### 1. 导航的三种实现方案
	
	1. 可以将需要导航的位置丢给系统的地图APP进行导航
	2. 发送网络请求到公司服务器获取导航数据, 然后自己手动绘制导航
	3. 利用三方SDK实现导航(百度)

### 2. 直接将起点和终点, 传递给系统地图, 利用系统APP, 进行导航

1. 利用"反推法", 记住关键代码即可
2. 代码如下:
						
		// 根据两个地标对象进行调用系统导航
		- (void)beginNavWithBeginPlacemark:(CLPlacemark *)beginPlacemark andEndPlacemark:(CLPlacemark *)endPlacemark
		{
    		// 创建起点:根据 CLPlacemark 地标对象创建 MKPlacemark 地标对象
		    MKPlacemark *itemP1 = [[MKPlacemark alloc] initWithPlacemark:beginPlacemark];
		    MKMapItem *item1 = [[MKMapItem alloc] initWithPlacemark:itemP1];

		    // 创建终点:根据 CLPlacemark 地标对象创建 MKPlacemark 地标对象
		    MKPlacemark *itemP2 = [[MKPlacemark alloc] initWithPlacemark:endPlacemark];
		    MKMapItem *item2 = [[MKMapItem alloc] initWithPlacemark:itemP2];

		    NSDictionary *launchDic = @{
                                // 设置导航模式参数
                                MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
                                // 设置地图类型
                                MKLaunchOptionsMapTypeKey : @(MKMapTypeHybridFlyover),
                                // 设置是否显示交通
                                MKLaunchOptionsShowsTrafficKey : @(YES),

                                };
    		// 根据 MKMapItem 数组 和 启动参数字典 来调用系统地图进行导航
    		[MKMapItem openMapsWithItems:@[item1, item2] launchOptions:launchDic];
		}
		
3. 注意: CLPlacemark地标对象没法直接手动创建, 只能通过(反)地理编码获取

### 3. 补充
1. 3D视图

        补充1：类似于地图街景，增强用户体验
	    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(23.132931, 113.375924);
    	MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:center fromEyeCoordinate:CLLocationCoordinate2DMake(center.latitude, center.longitude + 0.001) eyeAltitude:1];
    	self.mapView.camera = camera;
    	
2. 地图截图

	    // 截图附加选项
    	MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    	// 设置截图区域(在地图上的区域,作用在地图)
    	options.region = self.mapView.region;
		// options.mapRect = self.mapView.visibleMapRect;

    	// 设置截图后的图片大小(作用在输出图像)
    	options.size = self.mapView.frame.size;
    	// 设置截图后的图片比例（默认是屏幕比例， 作用在输出图像）
    	options.scale = [[UIScreen mainScreen] scale];

    	MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    	[snapshotter startWithCompletionHandler:^(MKMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error) {
            NSLog(@"截图错误：%@",error.localizedDescription);
        }else
        {
            // 设置屏幕上图片显示
            self.snapshootImageView.image = snapshot.image;
            // 将图片保存到指定路径（此处是桌面路径，需要根据个人电脑不同进行修改）
            NSData *data = UIImagePNGRepresentation(snapshot.image);
            [data writeToFile:@"/Users/wangshunzi/Desktop/snap.png" atomically:YES];
        }
    	}];


### 4. 测试环境

		1. 加载地图数据需要联网
		2. XCode版本不限
		3. iOS系统版本不限

### 5. 常见问题总结

		1. 需要注意地标对象不能手动创建, 因为里面的属性是readonly; 只能通过(反)地理编码获取

----

## 六. 获取导航路线信息 
### 1. 实现须知
1. 获取导航路线, 需要想苹果服务器发送网络请求
2. 记住关键对象MKDirections

### 2.代码实现

	// 根据两个地标，向苹果服务器请求对应的行走路线信息
	- (void)directionsWithBeginPlackmark:(CLPlacemark *)beginP andEndPlacemark:(CLPlacemark *)endP
	{

    	// 创建请求
    	MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];

    	// 设置开始地标
    	MKPlacemark *beginMP = [[MKPlacemark alloc] initWithPlacemark:beginP];
    	request.source = [[MKMapItem alloc] initWithPlacemark:beginMP];

    	// 设置结束地标
    	MKPlacemark *endMP = [[MKPlacemark alloc] initWithPlacemark:endP];
    	request.destination = [[MKMapItem alloc] initWithPlacemark:endMP];
    	
    	// 根据请求，获取实际路线信息
    	MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {

        [response.routes enumerateObjectsUsingBlock:^(MKRoute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%@--", obj.name);
            [obj.steps enumerateObjectsUsingBlock:^(MKRouteStep * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"%@", obj.instructions);
            }];
        }];

    }];

	}

### 3. 导航路线对象详解

        /** 
         MKDirectionsResponse对象解析
            source ：开始位置
            destination ：结束位置
            routes ： 路线信息 （MKRoute对象）

         MKRoute对象解析
            name ： 路的名称
            advisoryNotices ： 注意警告信息
            distance ： 路线长度（实际物理距离，单位是m）
            polyline ： 路线对应的在地图上的几何线路（由很多点组成，可绘制在地图上）
            steps ： 多个行走步骤组成的数组（例如“前方路口左转”，“保持直行”等等， MKRouteStep 对象）
         
        MKRouteStep对象解析
            instructions ： 步骤说明（例如“前方路口左转”，“保持直行”等等）
            transportType ： 通过方式（驾车，步行等）
            polyline ： 路线对应的在地图上的几何线路（由很多点组成，可绘制在地图上）
         
        注意：
            MKRoute是一整条长路；MKRouteStep是这条长路中的每一截；

         */

### 4. 测试环境

		1. 请求路线数据需要联网
		2. XCode版本不限
		3. iOS系统版本不限

### 5. 常见问题总结

		1. 类太多, 记不住咋办?
			此功能不常用, 只需要知道有这一个功能. 如果到时用到, 直接回过头来找代码;

----

## 七. 绘制导航路线 
### 1. 理论支持

1. 路线也是一个覆盖层
2. 在地图上操作覆盖层,其实操作的是覆盖层的数据模型
 	添加覆盖层:在地图上添加覆盖层数据模型
 	删除覆盖层:在地图上移除覆盖层数据模型


### 2. 添加导航路线到地图

1. 获取几何路线的数据模型  (id <MKOverlay>)overlay
2. 地图添加覆盖层(几何路线也是一个覆盖层), 直接添加覆盖层数据模型
	
		[self.mapView addOverlay:overlay];

3. 设置地图代理, 代理遵循协议 MKMapViewDelegate
4. 实现地图添加覆盖层数据模型时, 回调的代理方法; 通过此方法, 返回对应的渲染图层

		- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
		{
    		// 创建折线渲染对象
    		if ([overlay isKindOfClass:[MKPolyline class]]) 
    		{
        		MKPolylineRenderer *lineRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        		// 设置线宽
        		lineRenderer.lineWidth = 6;
        		// 设置线颜色
        		lineRenderer.strokeColor = [UIColor redColor];
        		return lineRenderer;
    		}
		}
	

### 3. 练习: 添加圆形覆盖层到地图
1. 创建圆形区域覆盖层的数据模型
	
		MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.mapView.centerCoordinate radius:1000000];

2. 添加覆盖层数据模型

		[self.mapView addOverlay:circle];

3. 实现代理方法

		-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
		{
    		// 创建圆形区域渲染对象
    		if ([overlay isKindOfClass:[MKCircle class]]) 
    		{
    			MKCircleRenderer *circleRender = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        		circleRender.fillColor = [UIColor cyanColor];
        		circleRender.alpha = 0.6;
        		return circleRender;
    		}
    		return nil;
		}


### 4. 测试环境

		1. 地图加载需要联网
		2. XCode版本不限
		3. iOS系统版本不限

### 5. 常见问题总结
	
		1. 东西太多, 记不住?
			只需要记得一个思想, 按照MVC的原则, 我们操作覆盖层, 就是操作覆盖层数据模型; 然后地图, 会调用其对应的代理方法, 获取对应的覆盖层渲染层;
			类记不住没关系, 主要记住大致思路就可以.

----

## 八. 集成百度地图 
### 1. 集成原因
	1. 有些功能, 系统自带的高德地图无法实现, 例如POI检索等等
	2. 一般实现导航功能, 会集成百度地图的比较多;

### 2. 集成步骤
	1. 下载对应的SDK
	2. 按照集成文档一步一步实现

### 3. 开发经验
	1. 不要把所有的功能全部都写在控制器当中, 最好封装成一个单独的工具类
	2. 如果集成过程中出现问题, 先查看官方文档

### 4. 测试环境
	1. 需要联网
	2. XCode版本不限
	3. iOS系统版本不限

### 5. 常见问题总结
	按照开发文档一步一步做, 一般没有什么问题; 注意集成细节就行.