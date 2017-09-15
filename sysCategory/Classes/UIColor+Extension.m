//
//  UIColor+HexString.m
//
//  Created by Micah Hainline
//  http://stackoverflow.com/users/590840/micah-hainline
//

#import "UIColor+Extension.h"


@implementation UIColor (HexString)

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

+ (NSArray *)colorArrayWithHexString:(NSString *)hexString {
    // 转为大写
    NSString *colorString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // 字符串长度为7-10位，如:#FFFFFF #FFFFFFAA 0xFFFFFF 0xFFFFFFAA
    if (colorString.length < 6) {
        return @[];
    }
    
    // 0X开头
    if ([colorString hasPrefix:@"0X"]) {
        colorString = [colorString substringFromIndex:2];
    }
    if ([colorString hasPrefix:@"#"]) {
        colorString = [colorString substringFromIndex:1];
    }
    if (!(colorString.length == 6 ||colorString.length == 8)) {
        return @[];
    }
    
    if (colorString.length == 6) {
        colorString = [@"FF" stringByAppendingString:colorString];
    }
    // 分解颜色为R, G, B, A
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    // Alpha
    NSString *alphaString = [colorString substringWithRange:range];
    
    // Red
    range.location = 2;
    NSString *rString = [colorString substringWithRange:range];
    
    // Green
    range.location = 4;
    NSString *gString = [colorString substringWithRange:range];
    
    // Blue
    range.location = 6;
    NSString *bString = [colorString substringWithRange:range];
    
    // 扫描值
    unsigned int r, g, b, a;
    [[NSScanner scannerWithString:alphaString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return @[@(r), @(g), @(b), @(a)];
}

+ (UIColor *)colorWithHexString:(NSString *)color
{
    NSArray *colorArray = [self colorArrayWithHexString:color];
    if (colorArray.count >= 3) {
        CGFloat red = [colorArray[0] floatValue];
        CGFloat green = [colorArray[1] floatValue];
        CGFloat blue = [colorArray[2] floatValue];
        CGFloat alpha = [colorArray[3] floatValue];
        return [UIColor colorWithRed:(red / 255.0f) green:(green / 255.0f) blue:(blue / 255.0f) alpha:(alpha / 255.0f)];
    }
    return [UIColor clearColor];
}

+ (UIColor *)colorWithRGBA:(NSString *)rgba {
    NSMutableArray *colorArray = [NSMutableArray arrayWithArray:[rgba componentsSeparatedByString:@","]];
    if (colorArray.count < 3 || colorArray.count > 4) {
        return [UIColor clearColor];
    }
    if (colorArray.count == 3) {
        [colorArray addObject:@(1)];
    }
    CGFloat red = [colorArray[0] floatValue];
    CGFloat green = [colorArray[1] floatValue];
    CGFloat blue = [colorArray[2] floatValue];
    CGFloat alpha = [colorArray[3] floatValue];
    return [UIColor colorWithRed:(red / 255.0f) green:(green / 255.0f) blue:(blue / 255.0f) alpha:alpha];
}

@end
