//
//  UIImage+color.m
//  CWGJMerchant
//
//  Created by mac on 15/9/16.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (color)


+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return pressedColorImg;
}

- (UIImage *)watermarkCenterImage:(NSString *)text
                             font:(UIFont *)font
                            color:(UIColor *)color
                         maxWidth:(CGFloat)maxWidth {
    //只一行显示
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    //文字的属性
    NSDictionary *dic = @{
                          NSFontAttributeName:font,
                          NSParagraphStyleAttributeName:style,
                          NSForegroundColorAttributeName:color
                          };
    CGSize size = [text boundingRectWithSize:CGSizeMake(maxWidth, self.size.height) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading  attributes:dic context:nil].size;
    
    CGSize imageSize = self.size;
    CGFloat imageGapX = 6.0f;
    
    imageSize.width = MAX(size.width+imageGapX*2, imageSize.width);
    imageSize.width = MIN(imageSize.width, maxWidth);
    
    //1.获取上下文
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    //2.绘制图片
    [self drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    //3.绘制水印文字
    
    CGFloat textW = MIN(imageSize.width - imageGapX*2, size.width);
    CGFloat textH = size.height;
    CGFloat textX = (imageSize.width - textW)/2;
    CGFloat textY = (imageSize.height - textH)/2;
    CGRect rect = CGRectMake(textX, textY, textW, textH);
    //将文字绘制上去
    [text drawInRect:rect withAttributes:dic];
    //4.获取绘制到得图片
    UIImage *watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //5.结束图片的绘制
    UIGraphicsEndImageContext();
    return watermarkImage;
    
}


@end

@implementation UIImage (screen)


/*
 rect:截屏的位置大小
 */
- (UIImage *)screenShotWithRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(self.size, YES, 1);
    
    //设置截屏大小
    UIImageView *view = [[UIImageView alloc] initWithImage:self];
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *resImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    CGImageRelease(imageRefRect);
    
    return resImage;
}

#pragma mark - 截屏相关函数
+ (UIImage *)screenShot:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    CALayer *rootLayer = view.layer;
    CGContextRef context = UIGraphicsGetCurrentContext();
    // doesn't tint tabBar-background in iOS7
    [rootLayer renderInContext:context];
    UIImage *rootLayerImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rootLayerImage;
}

@end
