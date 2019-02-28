06-CABasicAnimation基础核心动画 
	
	核心动画之作用在层上面.
	动画的本质是改图层的某一个属性.
	CABasicAnimation *anim = [CABasicAnimation animation];
	图层有那些属性,这里才能写那些属性.
	anim.keyPath = @"transform.scale";
	anim.toValue = @0.5;
	告诉动画完成的时候不要移除
	anim.removedOnCompletion = NO;
	保存动画最前面的效果.
	anim.fillMode = kCAFillModeForwards;
	把动画添加到层上面.
	[_redView.layer addAnimation:anim forKey:nil];