//
//  UIImage+color.h
//  CWGJMerchant
//
//  Created by mac on 15/9/16.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (color)



/**
 *返回纯色的image

 @param color 颜色
 @param size 大小
 @return UIImage
 */
+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size;


/**
 *图片中间加上文字

 @param text 加的文字
 @param font 字体对象
 @param color 字体颜色
 @param maxWidth 如果文字的宽度太大了，设置个最大的宽度
 @return UIImage
 */
- (UIImage *)watermarkCenterImage:(NSString *)text
                             font:(UIFont *)font
                            color:(UIColor *)color
                         maxWidth:(CGFloat)maxWidth;

@end


@interface UIImage (screen)

/*
 rect:截屏的位置大小
 */
- (UIImage *)screenShotWithRect:(CGRect)rect;

#pragma mark - 截取当前视图的函数
+ (UIImage *)screenShot:(UIView *)view;



@end
