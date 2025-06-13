//
//  CardStackView.m
//  动画demo
//
//  Created by 王玉松 on 2025/6/9.
//

#import "CardStackView.h"

@interface CardStackView () <UIGestureRecognizerDelegate,CAAnimationDelegate>

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSTimer *autoPlayTimer;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) CGFloat imageOverlap;
@property (nonatomic, strong) NSArray<NSNumber *> *cardRotationAngles;

@end

@implementation CardStackView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _imageViews = [NSMutableArray array];
    _currentIndex = 0;
    _isAnimating = NO;
    _imageOverlap = 120.0;
    _autoPlayInterval = 1.0;
    
    // 设置不同卡片的旋转角度
    _cardRotationAngles = @[
        @(-1.0 * M_PI / 180.0),  // 第一张卡片
        @(5.0 * M_PI / 180.0),    // 第二张卡片
        @(-5.0 * M_PI / 180.0)    // 第三张卡片
    ];
    
    // 添加手势识别器
    [self setupGestures];
}

#pragma mark - Public Methods

- (void)setImages:(NSArray<UIImage *> *)images {
    _images = [images copy];
    [self.imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imageViews removeAllObjects];
    [self setupCardViews];
}

-(void)setImageViews:(NSMutableArray<UIImageView *> *)imageViews{
    [self.imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _imageViews = [imageViews mutableCopy];
    [self setupCardImgeViews];
}

- (void)startAutoPlay {
    if (!self.autoPlayTimer && self.autoPlay) {
        self.autoPlayTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoPlayInterval
                                                            target:self
                                                          selector:@selector(triggerCardAnimation)
                                                          userInfo:nil
                                                           repeats:YES];
    }
}

- (void)stopAutoPlay {
    [self.autoPlayTimer invalidate];
    self.autoPlayTimer = nil;
}

- (void)triggerCardAnimation {
    if (!self.isAnimating && self.imageViews.count > 0) {
        [self animateCurrentImageOut];
    }
}

#pragma mark - Private Methods

- (void)setupGestures {
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panGesture];
    
    // 添加点击手势
      UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
      tapGesture.numberOfTapsRequired = 1;
      [self addGestureRecognizer:tapGesture];
      
      // 设置手势优先级，点击手势优先于拖拽手势
      [panGesture requireGestureRecognizerToFail:tapGesture];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    if (self.isAnimating) return;
    UIImageView *currentImageView = self.imageViews[self.currentIndex];
       CGPoint translation = [gesture translationInView:self];
    static CGAffineTransform originalTransform;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
                 // 记录原始变换
                 originalTransform = currentImageView.transform;
                 break;
             }
        case UIGestureRecognizerStateChanged: {
                 // 只处理水平方向的移动，限制在30px范围内
                 CGFloat maxDistance = 30.0;
                 CGFloat horizontalDistance = fabs(translation.x);
                 CGFloat verticalDistance = fabs(translation.y);

                 CGFloat limitedX = translation.x;
                 CGFloat limitedY = translation.y;

                 NSLog(@"===%f",limitedX);
                 NSLog(@"===%f",translation.y);

                 if (horizontalDistance > maxDistance) {
                     // 限制水平移动距离
                     limitedX = translation.x > 0 ? maxDistance : -maxDistance;
                 }
                 
                if (verticalDistance > maxDistance) {
                    // 限制水平移动距离
                    limitedY = translation.y > 0 ? maxDistance : -maxDistance;
                }
                 // 只进行水平移动，保持原始旋转角度
                 CGAffineTransform currentTransform = originalTransform;
                 currentTransform = CGAffineTransformTranslate(currentTransform, limitedX, limitedY);
                 currentImageView.transform = currentTransform;
                 break;
             }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            [self triggerCardAnimation];

//            CGPoint translation = [gesture translationInView:self];
//            CGPoint velocity = [gesture velocityInView:self];
//            
//            // 计算滑动距离
//            CGFloat distance = sqrt(translation.x * translation.x + translation.y * translation.y);
//            
//            // 计算滑动速度
//            CGFloat speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
//            
//            // 设置触发阈值
//            CGFloat distanceThreshold = 10.0;  // 最小滑动距离
//            CGFloat speedThreshold = 100.0;    // 最小滑动速度
//            
//            // 如果滑动距离足够远或速度足够快就触发动画
//            if (distance > distanceThreshold || speed > speedThreshold) {
//                [self triggerCardAnimation];
//            }
            // 获取当前移动距离
            CGFloat horizontalDistance = fabs(translation.x);
            
            // 如果移动距离超过阈值（25px），触发飞出动画
            if (horizontalDistance > 25.0) {
                [self triggerCardAnimation];
            } else {
                // 恢复原位
                [UIView animateWithDuration:0.3
                                    delay:0
                   usingSpringWithDamping:0.7
                    initialSpringVelocity:0.5
                                  options:UIViewAnimationOptionCurveEaseOut
                               animations:^{
                    currentImageView.transform = originalTransform;
                } completion:nil];
            }
            break;
        }
        default:
            break;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (self.isAnimating) return;
    
    CGPoint tapLocation = [gesture locationInView:self];
    
    // 从前往后检查哪张图片被点击了（按层级顺序）
    for (NSInteger i = 0; i < self.imageViews.count; i++) {
        UIImageView *imageView = self.imageViews[i];
        
        // 将点击位置转换到图片视图的坐标系
        CGPoint pointInImageView = [self convertPoint:tapLocation toView:imageView];
        
        // 检查点击位置是否在图片视图内
        if ([imageView pointInside:pointInImageView withEvent:nil]) {
            // 通过tag获取原始索引
            NSInteger originalIndex = imageView.tag;
            UIImage *tappedImage = imageView.image;
            
            // 调用代理方法
            if (self.delegate && [self.delegate respondsToSelector:@selector(cardStackView:didTapCardAtIndex:withImage:)]) {
                [self.delegate cardStackView:self didTapCardAtIndex:originalIndex withImage:tappedImage];
            }
            
            // 调用block回调
            if (self.onCardTapped) {
                self.onCardTapped(originalIndex, tappedImage);
            }
            
            // 输出调试信息
            NSLog(@"点击了第 %ld 张图片 (原始索引: %ld, 当前显示位置: %ld)", (long)originalIndex, (long)originalIndex, (long)i);
            break;
        }
    }
}

- (NSInteger)getOriginalIndexForImageView:(UIImageView *)targetImageView {
    // 直接通过tag获取原始索引
    return targetImageView.tag;
}

- (void)setupCardImgeViews {
    CGFloat cardWidth = self.bounds.size.width;
    CGFloat cardHeight = self.bounds.size.height;
    
    for (NSInteger i = 0; i < self.imageViews.count; i++) {
        UIImageView *imageView = self.imageViews[i];
        CGFloat xOffset;
//        if (i == 0) {
//            xOffset = 8.0;
//        } else if (i == 1) {
//            xOffset = 16.0;
//        } else {
//            xOffset = 0.0;
//        }
        xOffset = 0.0;
        // 所有图片都放在相同位置
        imageView.frame = CGRectMake(xOffset,0,cardWidth,cardHeight);
        imageView.backgroundColor = UIColor.clearColor;
        imageView.layer.cornerRadius = 10;
        imageView.layer.maskedCorners = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.layer.zPosition = self.imageViews.count - i;  // 保持层级关系
        // 重要：设置tag来保存原始索引
        imageView.tag = i;
        // 设置初始旋转角度
        NSInteger rotationIndex = i % self.cardRotationAngles.count;
        if (i < 2) {
                 rotationIndex = i;  // 第一张和第二张使用各自的旋转角度
        } else {
            rotationIndex = 2;  // 第三张及以后使用第三张的旋转角度
        }
        CGFloat rotationAngle = [self.cardRotationAngles[rotationIndex] doubleValue];
        imageView.transform = CGAffineTransformMakeRotation(rotationAngle);
        
        // 添加阴影效果
//        imageView.layer.shadowColor = [UIColor blackColor].CGColor;
//        imageView.layer.shadowOffset = CGSizeMake(0, 2);
//        imageView.layer.shadowOpacity = 0.3;
//        imageView.layer.shadowRadius = 4;
        
        // 确保图片视图的边界不会被旋转影响
//        imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        
        [self addSubview:imageView];
    }
}

- (void)setupCardViews {
    CGFloat cardWidth = self.bounds.size.width;
    CGFloat cardHeight = self.bounds.size.height;
    
    for (NSInteger i = 0; i < self.images.count; i++) {
        
        CGFloat xOffset;
//        if (i == 0) {
//            xOffset = 8.0;
//        } else if (i == 1) {
//            xOffset = 16.0;
//        } else {
//            xOffset = 0.0;
//        }
        xOffset = 0.0;

        // 所有图片都放在相同位置
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset,
                                                                               0,
                                                                              cardWidth,
                                                                              cardHeight)];
        imageView.image = self.images[i];
        imageView.backgroundColor = UIColor.clearColor;
        imageView.layer.cornerRadius = 10;
        imageView.layer.maskedCorners = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.layer.zPosition = self.images.count - i;  // 保持层级关系
        imageView.tag = i;

        // 设置初始旋转角度
        NSInteger rotationIndex = i % self.cardRotationAngles.count;
        if (i < 2) {
                 rotationIndex = i;  // 第一张和第二张使用各自的旋转角度
        } else {
            rotationIndex = 2;  // 第三张及以后使用第三张的旋转角度
        }
        CGFloat rotationAngle = [self.cardRotationAngles[rotationIndex] doubleValue];
        imageView.transform = CGAffineTransformMakeRotation(rotationAngle);
        
        // 添加阴影效果
//        imageView.layer.shadowColor = [UIColor blackColor].CGColor;
//        imageView.layer.shadowOffset = CGSizeMake(0, 2);
//        imageView.layer.shadowOpacity = 0.3;
//        imageView.layer.shadowRadius = 4;
        
        // 确保图片视图的边界不会被旋转影响
//        imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        
        [self addSubview:imageView];
        [self.imageViews addObject:imageView];
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    if (self.isAnimating) return;
    [self triggerCardAnimation];
}

- (void)animateCurrentImageOut {
    if (self.isAnimating) return;
    self.isAnimating = YES;
    
    UIImageView *currentImageView = self.imageViews[self.currentIndex];
    
    // 上下抖动动画
//    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
//    shakeAnimation.values = @[@0, @-20, @20,@0];
//    shakeAnimation.duration = 0.4;
//    shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    
    // 飞出动画组（1秒）
    CAAnimationGroup *flyOutGroup = [CAAnimationGroup animation];
    
    // 1. X轴移动动画（向右飞出）
    CABasicAnimation *moveXAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    moveXAnimation.fromValue = @0;
    moveXAnimation.toValue = @(self.bounds.size.width * 1.0);
    
    // 2. Y轴移动动画（向上飞出）
    CABasicAnimation *moveYAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    moveYAnimation.fromValue = @0;
    moveYAnimation.toValue = @(-self.bounds.size.height * 4);
    
    // 3. 旋转动画（45度角）
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    NSInteger rotationIndex = self.currentIndex % self.cardRotationAngles.count;
    CGFloat fromRotation = [self.cardRotationAngles[rotationIndex] doubleValue];
    CGFloat toRotation = 45.0 * M_PI / 180.0;  // 45度角
    rotationAnimation.fromValue = @(fromRotation);
    rotationAnimation.toValue = @(toRotation);
    
    // 4. 缩放动画
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @1.0;
    scaleAnimation.toValue = @0.5;
    
    // 5. 透明度动画
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @1.0;
    opacityAnimation.toValue = @0.0;
    
    // 组合所有动画
    flyOutGroup.animations = @[moveXAnimation, moveYAnimation, rotationAnimation, scaleAnimation, opacityAnimation];
    flyOutGroup.duration = 1.0;  // 动画持续1秒
    flyOutGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    flyOutGroup.fillMode = kCAFillModeForwards;
    flyOutGroup.removedOnCompletion = NO;
    flyOutGroup.delegate = self;
    
    // 添加3D效果
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / 500.0;
    currentImageView.layer.sublayerTransform = perspective;
    
    // 添加动画
    [currentImageView.layer addAnimation:flyOutGroup forKey:@"flyOutAnimation"];
    
    // 更新图片位置
    [self updateImagePositions];
}

- (void)updateImagePositions {
    UIImageView *currentImageView = self.imageViews[self.currentIndex];
    [self.imageViews removeObjectAtIndex:self.currentIndex];
    [self.imageViews addObject:currentImageView];
    
    // 更新所有图片的位置和旋转角度
    [UIView animateWithDuration:0.5
                          delay:0.4
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        for (NSInteger i = 0; i < self.imageViews.count; i++) {
            UIImageView *imageView = self.imageViews[i];
            imageView.layer.zPosition = self.imageViews.count - i;
            
            // 根据新的位置设置 x 偏移
//            CGFloat xOffset;
//            if (i == 0) {
//                xOffset = 8.0;  // 第一张卡片偏移 8px
//            } else if (i == 1) {
//                xOffset = 16.0; // 第二张卡片偏移 16px
//            } else {
//                xOffset = 0.0;  // 第三张及以后的卡片不偏移
//            }
//            
//            // 更新位置
//            imageView.frame = CGRectMake(xOffset,
//                                       0,
//                                       self.bounds.size.width,
//                                       self.bounds.size.height);
            
            // 更新旋转角度
            NSInteger rotationIndex;
            if (i < 2) {
                rotationIndex = i;
            } else {
                rotationIndex = 2;
            }
            CGFloat rotationAngle = [self.cardRotationAngles[rotationIndex] doubleValue];
            imageView.transform = CGAffineTransformMakeRotation(rotationAngle);
        }
    } completion:nil];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        self.isAnimating = NO;
        // 重置最后一张图片的位置和变换
        UIImageView *lastImageView = [self.imageViews lastObject];
        
        // 先移除所有动画效果
        [lastImageView.layer removeAllAnimations];
        
        // 重置所有变换和透明度
        lastImageView.layer.transform = CATransform3DIdentity;
        lastImageView.layer.opacity = 1.0;
        lastImageView.transform = CGAffineTransformIdentity;
        
        // 计算最后一张卡片应该的位置
        NSInteger lastIndex = self.imageViews.count - 1;
//        CGFloat xOffset;
//        if (lastIndex == 0) {
//            xOffset = 8.0;
//        } else if (lastIndex == 1) {
//            xOffset = 16.0;
//        } else {
//            xOffset = 0.0;
//        }
        
        // 重置到正确位置
        lastImageView.frame = CGRectMake(0,
                                       0,
                                       self.bounds.size.width,
                                       self.bounds.size.height);
        
        // 设置正确的旋转角度
        NSInteger rotationIndex;
        if (lastIndex < 2) {
            rotationIndex = lastIndex;
        } else {
            rotationIndex = 2;
        }
        CGFloat rotationAngle = [self.cardRotationAngles[rotationIndex] doubleValue];
        lastImageView.transform = CGAffineTransformMakeRotation(rotationAngle);
        
        // 确保所有图片都可见且在正确的层级
        for (NSInteger i = 0; i < self.imageViews.count; i++) {
            UIImageView *imageView = self.imageViews[i];
            imageView.hidden = NO;
            imageView.alpha = 1.0;
            imageView.layer.zPosition = self.imageViews.count - i;
        }
    }
}

#pragma mark - Cleanup

- (void)dealloc {
    [self stopAutoPlay];
}

@end
