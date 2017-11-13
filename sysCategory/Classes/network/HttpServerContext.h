//
//  httpServerContext.h
//  test
//
//  Created by mutouren on 12/23/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface httpServerContext : NSObject


@property (nonatomic, strong) NSString *verName;            //版本名称
@property (nonatomic, strong) NSString *appType;            //版本类型(1管理版 2司机版 3采集板 4商户版 5收费员版)
@property (nonatomic, strong) NSString *cityName;           //城市名称
@property (nonatomic, strong) NSString *lat;                //经度
@property (nonatomic, strong) NSString *lon;                //纬度
@property (nonatomic, strong) NSString *sessionID;          //登录获取的sessionID

+ (instancetype)sharedInstance;

@end
