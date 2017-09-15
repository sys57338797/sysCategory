//
//  NSString+verification.m
//  CWGJCarOwner
//
//  Created by mutouren on 9/17/15.
//  Copyright (c) 2015 mutouren. All rights reserved.
//

#import "NSString+Extension.h"
#import <CoreText/CoreText.h>


@implementation NSString (verification)



#pragma mark 判断字符串是否为web端的null,是返回@""
+ (NSString*)stringVerifyNullWithContent:(NSString*)content
{
    if(content== nil || content == NULL || [content isEqual:[NSNull null]]||[content isEqual:@"(null)"])
        return @"";
    
    return content;
}

#pragma mark 验证转成NSNumber
- (BOOL)VerifyToNSNumber
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    
    NSNumber *ber = nil;
    ber = [f numberFromString:self];
    return ber?YES:NO;
}


#pragma mark 验证车牌
- (BOOL)VerifyCarNo
{
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[A-Z]{1}[a-zA-Z_0-9]{5}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    BOOL isMatch = [carTest evaluateWithObject:self];
    return isMatch;
}

#pragma mark 验证手机号码
- (BOOL)VerifyPhone
{
    NSString *pattern = @"^(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

#pragma mark 验证短信验证码
- (BOOL)VerifySMSNote
{
    NSString *pattern = @"^[A-Za-z0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

#pragma mark 判断是否是数字
- (BOOL)isNumText{
    NSString * regex        = @"(/^[0-9]*$/)";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch            = [pred evaluateWithObject:self];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark 转换钱的小数点位数，只有小数点后一位的只取到小数点后1位，是整数的取整数,最多保留后2位
- (NSString*)getMoneyString
{
    NSString *money = [NSString stringWithFormat:@"%.02f",[self doubleValue]];
    double d = [money doubleValue];
    int i = d;
    if (d != i) {
        if ([[money substringFromIndex:money.length-1] isEqualToString:@"0"]) {
            money = [money substringToIndex:money.length-1];
        }
        
        return money;
    }
    
    return [NSString stringWithFormat:@"%d",i];
}

- (NSString*)getMoneyStringWithDouble:(double)value
{
    NSString *money = [NSString stringWithFormat:@"%.02f",value];
    
    return [money getMoneyString];
}

@end


@implementation NSString (frame)

- (NSArray *)getSeparatedLinesWidthForFont:(UIFont *)font maxWidth:(CGFloat)width {
    
    NSMutableArray *resArray = [NSMutableArray array];
    if (self.length && font) {
        NSMutableAttributedString *attSelf = [[NSMutableAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName:font}];
        
        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attSelf);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0,0,width,100000));
        
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
        
        NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
        
        for (id line in lines)
        {
            CTLineRef lineRef = (__bridge CTLineRef )line;
            //        CFRange lineRange = CTLineGetStringRange(lineRef);
            //        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
            //        NSString *lineString = [attString.string substringWithRange:range];
            //        NSLog(@"lineString===>%@",lineString);
            
            CGFloat asc,des,lead;
            double lineWidth = CTLineGetTypographicBounds(lineRef, &asc, &des, &lead);
            [resArray addObject:@(lineWidth)];
            
        }
    }
    
    return (NSArray *)resArray;
}

@end

@implementation NSString (line)

- (NSInteger)lineCountForFont:(UIFont *)font maxWidth:(CGFloat)width {
    
    if (self.length && font) {
        NSMutableAttributedString *attSelf = [[NSMutableAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName:font}];
        
        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attSelf);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0,0,width,100000));
        
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
        
        NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
        
        return lines.count;
    }
    
    return 0;
}

@end
