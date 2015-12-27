//
//  UIColor+RGBA.h
//  LMBlurView
//
//  Created by by on 15/12/26.
//  Copyright © 2015年 dlm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RGBA)

/**
 *  获取Color对象的十六进制字符串
 *
 *  @return
 */
- (NSString *)obtainColorHexString;
/**
 *  获取Color对象的RGBA值
 *
 *  @return RGBA字典
 */
- (NSDictionary *)obtainColorRGBComponents;
@end
