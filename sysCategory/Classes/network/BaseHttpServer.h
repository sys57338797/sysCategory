//
//  BaseHttpServer.h
//
//  Created by mutouren on 12/23/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpDefine.h"
#import "HttpResponse.h"

@class BaseHttpServer;

typedef NS_ENUM (NSUInteger, BaseHttpServerRequestStatus){
    BaseHttpServerRequestStatusDefault,         //没有网络请求，这个是server的默认状态。
    BaseHttpServerRequestStatusSuccess,         //网络请求返回成功的状态
    BaseHttpServerRequestStatusTimeout,         //请求超时状态
    BaseHttpServerRequestStatusNoNetWork,       //网络不通状态
    BaseHttpServerRequestStatusFailCode,        //接口返回成功时，返回码是错误的状态
    BaseHttpServerRequestStatusNonMainIP,       //获取主IP失败状态
};

typedef NS_ENUM (NSUInteger, BaseHttpServerRequestType){
    BaseHttpServerRequestTypeGet,
    BaseHttpServerRequestTypeSynPost,                   //同步post
    BaseHttpServerRequestTypeAsynPost,                  //异步post
    BaseHttpServerRequestTypeAsynPostAndUpdateFile,     //异步post带上传文件
    BaseHttpServerRequestTypeRestGet,
    BaseHttpServerRequestTypeRestPost
};

NS_ASSUME_NONNULL_BEGIN

typedef void (^BaseHttpServerWaitingBlock)();

#pragma mark - 此协议获取继承的接口返回参数,继承接口必须实现

@protocol BaseHttpServerParamSourceDelegate <NSObject>

@required
- (NSDictionary *)requestParamsForServer:(BaseHttpServer *)server;

@end

#pragma mark - 请求回调

@protocol BaseHttpServerCallBackDelegate <NSObject>
@required
- (void)requestCallDidSuccess:(BaseHttpServer *)server;
- (void)requestCallDidFailed:(BaseHttpServer *)server;
@end

@protocol BaseHttpServerCallbackDataReformer <NSObject>
@required
- (id)server:(BaseHttpServer *)server reformData:(NSDictionary *)data;
@end


#pragma mark - BaseHttpServerDelegate server的一些属性放在这里写,让派生类必须实现这个协议

@protocol BaseHttpServerDelegate <NSObject>

@required
- (NSString*)requestUrl;
- (NSString*)serviceID;
- (BaseHttpServerRequestType)requestType;

@optional

@end

#pragma mark - BaseHttpServerExtensionDelegate server扩展协议,当BaseHttpServer不能满足当前的业务逻辑时用

@protocol BaseHttpServerExtensionDelegate <NSObject>
- (void)extensionBeforeRequestCallSuccess:(BaseHttpServer*)server;
- (void)extensionBeforeRequestCallFail:(BaseHttpServer*)server;
@end


@interface BaseHttpServer : NSObject

@property (nonatomic, copy) NSString* httpServerId; 
@property (nonatomic, readonly) BaseHttpServerRequestStatus requestStatus;  //请求状态
@property (nonatomic, strong) NSDictionary *requestParam;                   //请求参数
@property (nonatomic, strong) NSData *updateData;                           //上传文件数据

@property (nonatomic, weak) id<BaseHttpServerDelegate> child;                       //派生类对象
@property (nonatomic, weak) id<BaseHttpServerCallBackDelegate> delegate;            //回调delegate。
@property (nonatomic, weak) id<BaseHttpServerParamSourceDelegate> paramSource;      //参数delegate。
@property (nonatomic, weak) id<BaseHttpServerExtensionDelegate> extensionDelegate;  //扩展delegate。

#pragma mark - 开始请求

- (void)createOperation;

#pragma mark - 请求接口,都用这个接口去请求数据

- (void)requestData;

- (nullable NSString*)needWaitingDomainIp;

#pragma mark - 配置参数

- (NSDictionary*)configParams:(NSDictionary*)params;

#pragma mark - 解析请求成功后的返回值是否正确

- (BOOL)parseRequestSuccessReturnValue:(HttpResponse*)response;

#pragma mark - 解析请求失败后的返回值

- (void)parseRequestFailReturnValue:(HttpResponse*)response;

#pragma mark - 返回当前状态

- (NSString*)BaseHttpServerRequestType;
- (NSString*)BaseHttpServerRequestStatus;

#pragma mark - 取消之前的同类请求

//取消AF队列里的全部请求放在manager里

- (void)cancelPreviousRequest;

NS_ASSUME_NONNULL_END

@end

