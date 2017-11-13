//
//  NSString+verification.h
//  CWGJCarOwner
//
//  Created by mutouren on 9/17/15.
//  Copyright (c) 2015 mutouren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface NSString (verification)

#pragma mark 判断字符串是否为web端的null,是返回@""
+ (NSString*)stringVerifyNullWithContent:(NSString*)content;

#pragma mark 验证转成NSNumber
- (BOOL)VerifyToNSNumber;

#pragma mark 验证车牌
- (BOOL)VerifyCarNo;

#pragma mark 验证手机号码
- (BOOL)VerifyPhone;

#pragma mark 验证短信验证码
- (BOOL)VerifySMSNote;

#pragma mark 判断是否是数字
- (BOOL)isNumText;

#pragma mark 转换钱的小数点位数，只有小数点后一位的只取到小数点后1位，是整数的取整数,最多保留后2位
- (NSString*)getMoneyString;

- (NSString*)getMoneyStringWithDouble:(double)value;



@end


@interface NSString (frame)


/**
 *计算 NSString每行的width

 @param font 字体
 @param width 最大的宽度
 @return NSnumber 每行的width
 */
- (NSArray *)getSeparatedLinesWidthForFont:(UIFont *)font maxWidth:(CGFloat)width;

@end


@interface NSString (line)

- (NSInteger)lineCountForFont:(UIFont *)font maxWidth:(CGFloat)width;

@end
