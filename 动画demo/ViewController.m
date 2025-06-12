//
//  ViewController.m
//  动画demo
//
//  Created by 王玉松 on 2025/6/9.
//

#import "ViewController.h"
#import "CardStackView.h"

@interface ViewController ()
@property(nonatomic,assign) int index;
 @property (weak, nonatomic) IBOutlet UIImageView *iconView;
@end

@implementation ViewController
 - (void)viewDidLoad
 {
     [super viewDidLoad];
     
     NSArray *array = @[[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"1"]],[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"2"]],[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"3"]],[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"1"]]];
     CardStackView *carouselView = [[CardStackView alloc]init];
     carouselView.frame = CGRectMake(20, 300, 350, 185);
     carouselView.backgroundColor = UIColor.redColor;
//     carouselView.imageViews = array;
     carouselView.images = @[[UIImage imageNamed:@"1"],[UIImage imageNamed:@"2"],[UIImage imageNamed:@"3"],[UIImage imageNamed:@"1"]];
     carouselView.onCardTapped = ^(NSInteger index, UIImage * _Nonnull image) {
         NSLog(@"%ld",index);
     };
     [self.view addSubview:carouselView];
     
   
 }

-(void)test1{
    self.index=1;
    [self nextOnClick:nil];
    
    // 创建向左滑动手势识别器
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeLeft];
        
        // 创建向右滑动手势识别器
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:swipeRight];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"向左滑动");
        [self nextOnClick:nil];

        
    } else if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"向右滑动");
        [self preOnClick:nil];
    }
}


 - (IBAction)preOnClick:(UIButton *)sender {
     self.index--;
     if (self.index<1) {
         self.index=2;
     }
     self.iconView.image=[UIImage imageNamed: [NSString stringWithFormat:@"%d.png",self.index]];

//创建核心动画
     CATransition *ca=[CATransition animation];
     //告诉要执行什么动画
     //设置过度效果
     ca.type=@"cube";
     //设置动画的过度方向（向左）
     ca.subtype=kCATransitionFromLeft;
     //设置动画的时间
     ca.duration=0.5;
     //添加动画
     [self.iconView.layer addAnimation:ca forKey:nil];
 }

 //下一张
 - (IBAction)nextOnClick:(UIButton *)sender {
     self.index++;
     if (self.index>2) {
         self.index=1;
     }
    self.iconView.image=[UIImage imageNamed: [NSString stringWithFormat:@"%d.png",self.index]];

     //1.创建核心动画
     CATransition *ca=[CATransition animation];

     //1.1告诉要执行什么动画
     //1.2设置过度效果
     ca.type=@"cube";
     //1.3设置动画的过度方向（向右）
     ca.subtype=kCATransitionFromRight;
     //1.4设置动画的时间
     ca.duration=0.5;
     //1.5设置动画的起点
     ca.startProgress=0.5;
     //1.6设置动画的终点
 //    ca.endProgress=0.5;

     //2.添加动画
     [self.iconView.layer addAnimation:ca forKey:nil];
 }


@end
