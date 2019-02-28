02-自定义CALayer
	
	1.如何自定义Layer.
	自定义CALayer的方式创建UIView的方式非常相似.
	 CALayer *layer = [CALayer layer];
     layer.frame = CGRectMake(50, 50, 100, 100);
     layer.backgroundColor = [UIColor redColor].CGColor;
     [self.view.layer addSublayer:layer];

	给layer设置图片.
	layer.contents = (id)[UIImage imageNamed:@"阿狸头像"].CGImage;
	
	2.关于CALayer的疑惑?
	  为什么要使用CGImageRef、CGColorRef?
	  为了保证可移植性，QuartzCore不能使用UIImage、UIColor，只能使用CGImageRef、CGColorRef
	  
	  UIView和CALayer都能够显示东西,该怎样选择?
	  对比CALayer，UIView多了一个事件处理的功能。也就是说，CALayer不能处理用户的触摸事件，而UIView可以
	  如果显示出来的东西需要跟用户进行交互的话，用UIView；
	  如果不需要跟用户进行交互，用UIView或者CALayer都可以
	  CALayer的性能会高一些，因为它少了事件处理的功能，更加轻量级