//
//  LMBlurView.h
//  LMBlurView
//
//  Created by by on 15/12/26.
//  Copyright © 2015年 dlm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMBlurView : UIView

@property (nonatomic, strong) IBOutlet UIView *blurProviderView; // 模糊图片提供者
@property (nonatomic, strong) UIView *transitionView;            // 过渡的视图
@property (nonatomic, assign) NSUInteger blurLevel;              // 模糊程度 [0，1]
@property (nonatomic, assign) CGFloat  blurRadius;               // 模糊半径
@property (nonatomic, strong) UIColor  *tintColor;               //
@property (nonatomic, assign) BOOL     autoTransiton;            // 自动模糊过渡 前提设置了transitionView
@property (nonatomic, assign,getter=isBlurEnable) BOOL     blurEnable;               // 是否开启模糊

- (void)blurAsync:(BOOL)async completion:(void (^)())completion;
/**
 *  过渡模糊
 *
 *  @param byValue 模糊过渡值[0,1] 推荐0.8
 */
- (void)blurTransition:(CGFloat)byValue;
- (void)clearBlurImage;

@end
