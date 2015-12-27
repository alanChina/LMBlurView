//
//  UIImage+Helper.h
//  LMBlurView
//
//  Created by by on 15/12/27.
//  Copyright © 2015年 dlm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper)
#pragma mark ---- Blur
/**
 *  获取模糊的图片
 *
 *  @param radius    模拟半径
 *  @param blurLevel 模糊程度
 *  @param tintColor 模糊浅色调
 *
 *  @return 模糊的图片
 */
- (UIImage *)blurredImageWithRadius:(CGFloat)radius blurLevel:(NSUInteger)blurLevel tintColor:(UIColor *)tintColor;

- (UIImage*)blurredImage:(CGFloat)blurAmount;

+ (UIImage *)screenshot;
+ (UIImage *)imageWithColor:(UIColor *)color;

/** 图片颜色替换 颜色转换为透明 */
- (UIImage*)imageToTransparent:(UIImage*) image;
@end
