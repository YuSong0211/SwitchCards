//
//  CardStackView.h
//  动画demo
//
//  Created by 王玉松 on 2025/6/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class CardStackView;
// 点击回调代理
@protocol CardStackViewDelegate <NSObject>
@optional
- (void)cardStackView:(CardStackView *)cardStackView didTapCardAtIndex:(NSInteger)index withImage:(UIImage *)image;
@end


@interface CardStackView : UIView
// 图片数组
@property (nonatomic, strong) NSArray<UIImage *> *images;

@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViews;

// 代理
@property (nonatomic, weak) id<CardStackViewDelegate> delegate;

// 点击回调block
@property (nonatomic, copy) void(^onCardTapped)(NSInteger index, UIImage *image);

// 是否自动播放
@property (nonatomic, assign) BOOL autoPlay;

// 自动播放间隔时间（秒）
@property (nonatomic, assign) NSTimeInterval autoPlayInterval;

// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame;

// 开始自动播放
- (void)startAutoPlay;

// 停止自动播放
- (void)stopAutoPlay;

// 手动触发卡片飞出动画
- (void)triggerCardAnimation;
@end

NS_ASSUME_NONNULL_END
