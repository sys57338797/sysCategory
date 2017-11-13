//
//  UIDevice+phoneInfo.h
//  CWGJCarOwner
//
//  Created by mutouren on 9/18/15.
//  Copyright (c) 2015 mutouren. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - 设备屏幕尺寸
#define SCREEN_SIZE             [UIScreen mainScreen].bounds.size
#define SCREEN_SIZE_WIDTH       [UIScreen mainScreen].bounds.size.width
#define SCREEN_SIZE_HEIGHT      [UIScreen mainScreen].bounds.size.height

#pragma mark -

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#define IOS10_OR_LATER		( [UIDevice getIOSVersion] >= 10.0 )
#define IOS9_OR_LATER		( [OMTSystemInfo getIOSVersion] >= 9.0 )
#define IOS8_OR_LATER		( [OMTSystemInfo getIOSVersion] >= 8.0)
#define IOS7_OR_LATER		( [OMTSystemInfo getIOSVersion] >= 7.0 )
#define IOS6_OR_LATER		( [OMTSystemInfo getIOSVersion] >= 6.0 )

#define IOS9_OR_EARLIER		( !IOS10_OR_LATER )
#define IOS8_OR_EARLIER		( !IOS9_OR_LATER )
#define IOS7_OR_EARLIER		( !IOS8_OR_LATER )
#define IOS6_OR_EARLIER		( !IOS7_OR_LATER )
#define IOS5_OR_EARLIER		( !IOS6_OR_LATER )
#define IOS4_OR_EARLIER		( !IOS5_OR_LATER )
#define IOS3_OR_EARLIER		( !IOS4_OR_LATER )

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPOD ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])
#define IS_IPHONE (	!IS_IPAD )

#define IS_IPHONE4 (IS_SCREEN_35_INCH)
#define IS_IPHONE5 (IS_SCREEN_4_INCH)
#define IS_IPHONE6 (IS_SCREEN_47_INCH)
#define IS_IPHONE6_PLUS (IS_SCREEN_55_INCH)

#define IS_SCREEN_55_INCH       ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)
#define IS_SCREEN_47_INCH       ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_SCREEN_4_INCH        ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_SCREEN_35_INCH       ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_SCREEN_IPAD_35_INCH  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] bounds].size) : NO)


#define APP_STATUSBAR_ORIENTATION ([[UIApplication sharedApplication] statusBarOrientation])
#define IS_PORTRAIT   UIInterfaceOrientationIsPortrait(APP_STATUSBAR_ORIENTATION)
#define IS_LANDSCAPE    UIInterfaceOrientationIsLandscape(APP_STATUSBAR_ORIENTATION)


#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#define IOS9_OR_LATER		(NO)
#define IOS8_OR_LATER		(NO)
#define IOS7_OR_LATER		(NO)
#define IOS6_OR_LATER		(NO)
#define IOS5_OR_LATER		(NO)
#define IOS4_OR_LATER		(NO)
#define IOS3_OR_LATER		(NO)

#define IS_SCREEN_4_INCH	(NO)
#define IS_SCREEN_35_INCH	(NO)
#define IS_SCREEN_47_INCH	(NO)
#define IS_SCREEN_55_INCH	(NO)

#define IS_IPAD (NO)
#define IS_IPOD (NO)
#define IS_IPHONE (NO)

#define APP_STATUSBAR_ORIENTATION (0)
#define IS_PORTRAIT   (NO)
#define IS_LANDSCAPE  (NO)

#define IS_IPHONE4 (NO)
#define IS_IPHONE5 (NO)
#define IS_IPHONE6 (NO)
#define IS_IPHONE6_PLUS (NO)


#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)


@interface UIDevice (SystemInfo)

#pragma mark 返回系统版本
+ (float)getIOSVersion;

#pragma mark 返回是否是iphone4,4s,5,5s机型的宽度
+ (BOOL)isIPhone4Width;

#pragma mark 判断是否是iphone4和4s机型
+ (BOOL)isIphone4And4s;

#pragma mark 判断是否是iphone5和5s机型
+ (BOOL)isIphone5And5s;

#pragma mark 判断是否是6P或6sP
+ (BOOL)isIphone6P;

#pragma mark 判断是否是6或6s
+ (BOOL)isIphone6;

/**
 IDFA,对外唯一标示,如果用户完全重置系统（(设置程序 -> 通用 -> 还原 -> 还原位置与隐私) ，这个广告标示符会重新生成。另外如果用户明确的还原广告(设置程序-> 通用 -> 关于本机 -> 广告 -> 还原广告标示符) ，那么广告标示符也会重新生成。

 @return IDFA
 */
+ (NSString *)deviceIDFA;


/**
 IDFV,对内唯一标示

 @return IDFV
 */
+ (NSString *)deviceIDFV;

@end
