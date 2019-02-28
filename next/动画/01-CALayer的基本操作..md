01-CALayer的基本操作.

	1.CALayer简介:
		CALayer我们又称它叫做层.
		在每个UIView内部都有一个layer这样一个属性.
		UIView之所以能够显示,就是因为它里面有这个一个层,才具有显示的功能.
		我们通过操作CALayer对象,可以很方便地调整UIView的一些外观属性.
		可以给UIView设置阴影,圆角,边框等等...
		
	2.操作layer改变UIView外观.
	
		2.1.设置阴影
		默认图层是有阴影的, 只不过,是透明的
    	_RedView.layer.shadowOpacity = 1;
    	设置阴影的圆角
    	_RedView.layer.shadowRadius  =10;
    	设置阴影的颜色,把UIKit转换成CoreGraphics框架,用.CG开头
    	_RedView.layer.shadowColor = [UIColor blueColor].CGColor;
    	
    	2.2.设置边框
    	设置图层边框,在图层中使用CoreGraphics的CGColorRef
    	_RedView.layer.borderColor = [UIColor whiteColor].CGColor;
        _RedView.layer.borderWidth = 2;

		2.3.设置圆角
    	图层的圆角半径,圆角半径为宽度的一半, 就是一个圆
    	_RedView.layer.cornerRadius = 50;
		
	3.操作layer改变UIImageView的外观.
		
    	设置图形边框
    	_imageView.layer.borderWidth = 2;
    	_imageView.layer.borderColor = [UIColor whiteColor].CGColor;
		
		
		设置图片的圆角半径
		_imageView.layer.cornerRadius = 50;
		裁剪,超出裁剪区域的部分全部裁剪掉
    	_imageView.layer.masksToBounds = YES;
    	注意:UIImageView当中Image并不是直接添加在层上面的.这是添加在layer当中的contents里.
    	我们设置层的所有属性它只作用在层上面.对contents里面的东西并不起作用.所以我们看不到图片有圆角的效果.
    	想要让图片有圆角的效果.可以把masksToBounds这个属性设为YES,
    	当设为YES,把就会把超过根层以外的东西都给裁剪掉.
    	
    4.layer的 CATransform3D属性.
      
      只有旋转的时候才可以看出3D的效果.
      旋转
      x,y,z 分别代表x,y,z轴.
      CATransform3DMakeRotation(M_PI, 1, 0, 0);
      平移
      CATransform3DMakeTranslation(x,y,z)
      缩放
      CATransform3DMakeScale(x,y,z);
      
      可以通过KVC的方式进行设置属性.
      但是CATransform3DMakeRotation它的值,是一个结构体, 所以要把结构转成对象.
      NSValue *value = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 1, 0, 0)];
      [_imageView.layer setValue:value forKeyPath:@"transform.scale"];
     
     
      什么时候用KVC?
      当需要做一些快速缩放,平移,二维的旋转时用KVC.
      比如: [_imageView.layer setValue:@0.5 forKeyPath:@"transform.scale"];
      快速的进行缩放.
      后面forKeyPath属性值不是乱写的.苹果文档当中给了相关的属性.