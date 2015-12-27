//
//  UIColor+RGBA.m
//  LMBlurView
//
//  Created by by on 15/12/26.
//  Copyright © 2015年 dlm. All rights reserved.
//

#import "UIColor+RGBA.h"

@implementation UIColor (RGBA)
-(NSString *)obtainColorHexString{
    NSDictionary *colorDic = [self obtainColorRGBComponents];
    int r = [colorDic[@"R"] floatValue] * 255;
    int g = [colorDic[@"G"] floatValue] * 255;
    int b = [colorDic[@"B"] floatValue] * 255;
    NSString *red = [NSString stringWithFormat:@"%02x", r];
    NSString *green = [NSString stringWithFormat:@"%02x", g];
    NSString *blue = [NSString stringWithFormat:@"%02x", b];
    return [NSString stringWithFormat:@"#%@%@%@", red, green, blue];
}

-(NSDictionary *)obtainColorRGBComponents{
    CGFloat r=0,g=0,b=0,a=0;
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [self getRed:&r green:&g blue:&b alpha:&a];
    }else {
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
    return @{@"R":@(r),@"G":@(g),@"B":@(b),@"A":@(a)};
}


@end
