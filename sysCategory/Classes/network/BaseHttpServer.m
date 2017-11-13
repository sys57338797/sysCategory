//
//  BaseHttpServer.m
//
//  Created by mutouren on 12/23/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import "BaseHttpServer.h"
#import "httpServerContext.h"
#import "HSLogger.h"
#import "BaseHttpServerManager.h"
#import "AFNetworking.h"

@interface BaseHttpServer ()
@property (nonatomic, strong) NSDate *requestTime;              //请求时时间
@property (nonatomic,weak,nullable) AFHTTPRequestOperation *preRequest;
@end

@implementation BaseHttpServer

- (id)init
{
    self = [super init];
    if (self) {
        
        _delegate = nil;
        _paramSource = nil;
        _requestStatus = BaseHttpServerRequestStatusDefault;
        
        if ([self conformsToProtocol:@protocol(BaseHttpServerDelegate)]) {
            self.child = (id <BaseHttpServerDelegate>)self;
        }
        else {
            NSLog(@">>> error: not conforms to protocol BaseHttpServerDelegate !");
        }
    }
    
    return self;
}

#pragma mark - 请求接口

- (void)requestData
{
    NSString *domain = [self needWaitingDomainIp];
    if (domain) {
        [[BaseHttpServerManager sharedInstance] createQueueForWaitingDomainIp:self.child domain:domain];
    }
    else{
        [self createOperation];
    }
}

#pragma mark - 开始请求

- (void)createOperation
{
    NSDictionary *params = nil;
    
    [HSLogger logWithHttpServer:self];
    
    if (self.requestParam) {
        params = [NSDictionary dictionaryWithDictionary:self.requestParam];
    }
    else {
        NSLog(@">>> error: http request missing parameter!!");
    }
    params = [self configParams:params];
    
    /*
    //是否要取消先前的请求//
    */
    
    [self requestDataOperationWithParam:params];
}

- (void)requestDataOperationWithParam:(NSDictionary *)params
{
    if ([self isNetWorkReachable]) {
        if ([self.child requestUrl].length > 0) {
            switch (self.child.requestType) {
                case BaseHttpServerRequestTypeGet:
                {
                    self.preRequest = [[BaseHttpServerManager sharedInstance] callGETWithParams:params url:[self.child requestUrl] success:^(HttpResponse *response) {
                        [self requestSuccess:response];
                    } fail:^(HttpResponse *response) {
                        
                        [self requestFail:response requestStatus:BaseHttpServerRequestStatusDefault];
                    }];
                    break;
                }
                case BaseHttpServerRequestTypeSynPost:
                {
                    self.preRequest = nil;
                    
                    HttpResponse *response = [[BaseHttpServerManager sharedInstance] callSynPOSTWithParams:params url:[self.child requestUrl]];
                    if (response.status == HttpResponseStatusSuccess) {
                        [self requestSuccess:response];
                    }
                    else {
                        
                        [self requestFail:response requestStatus:BaseHttpServerRequestStatusDefault];
                    }
                    break;
                }
                case BaseHttpServerRequestTypeAsynPost:
                {
                    self.preRequest = [[BaseHttpServerManager sharedInstance] callAsynPOSTWithParams:params url:[self.child requestUrl] success:^(HttpResponse *response) {
                        [self requestSuccess:response];
                    } fail:^(HttpResponse *response) {
                        
                        [self requestFail:response requestStatus:BaseHttpServerRequestStatusDefault];
                    }];
                    break;
                }
                case BaseHttpServerRequestTypeAsynPostAndUpdateFile:
                {
                    self.preRequest = [[BaseHttpServerManager sharedInstance] callAsynPOSTWithParams:params url:[self.child requestUrl] updateFileData:self.updateData success:^(HttpResponse *response) {
                        [self requestSuccess:response];
                    } fail:^(HttpResponse *response) {
                        
                        [self requestFail:response requestStatus:BaseHttpServerRequestStatusDefault];
                    }];
                    break;
                }
                    
                default:
                    break;
            }
        }
        else {
            [self requestFail:nil requestStatus:BaseHttpServerRequestStatusNonMainIP];
        }
    }
    else {
        [self requestFail:nil requestStatus:BaseHttpServerRequestStatusNoNetWork];
    }
}

#pragma mark 统一接收接口请求成功

- (void)requestSuccess:(HttpResponse*)response
{
    NSTimeInterval shostTime = [self requestShortestTime];
    if (shostTime) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(shostTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self requestSuccessExe:response];
        });
    }
    else {
        [self requestSuccessExe:response];
    }
}

- (void)requestSuccessExe:(HttpResponse*)response
{
    _requestStatus = BaseHttpServerRequestStatusSuccess;
    
    if ([self parseRequestSuccessReturnValue:response]) {
        [HSLogger logWithHttpServer:self HttpResponse:response];
        [self performSelectorOnMainThread:@selector(requestCallDidSuccess) withObject:nil waitUntilDone:YES];
    }
    else {
        [self requestFail:response requestStatus:BaseHttpServerRequestStatusFailCode];
    }
}

#pragma mark 统一接收接口请求失败

- (void)requestFail:(HttpResponse*)response requestStatus:(BaseHttpServerRequestStatus)status
{
    NSTimeInterval shostTime = [self requestShortestTime];
    if (shostTime) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(shostTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self requestFailExe:response requestStatus:status];
        });
    }
    else {
        [self requestFailExe:response requestStatus:status];
    }
}

- (void)requestFailExe:(HttpResponse*)response requestStatus:(BaseHttpServerRequestStatus)status
{
    [HSLogger logWithHttpServer:self HttpResponse:response];
    _requestStatus = status;
    //解析上层返回的状态
    if (status == BaseHttpServerRequestStatusDefault) {
        if (response) {
            switch (response.status) {
                case HttpResponseStatusErrorTimeout:
                    _requestStatus = BaseHttpServerRequestStatusTimeout;
                    break;
                case HttpResponseStatusErrorNoNetwork:
                    _requestStatus = BaseHttpServerRequestStatusNoNetWork;
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    [self parseRequestFailReturnValue:response];
    
    [self performSelectorOnMainThread:@selector(requestCallDidFailed) withObject:nil waitUntilDone:YES];
}

#pragma mark 是否需要依赖操作

- (NSString*)needWaitingDomainIp
{
    //在子类中重写返回依赖的domain类型(NSString)
    return nil;
}

- (BOOL)parseRequestSuccessReturnValue:(HttpResponse*)response
{
    return YES;
}

- (void)parseRequestFailReturnValue:(HttpResponse*)response
{
    NSLog(@"super parseRequestFailReturnValue");
}

#pragma mark - 配置参数

- (NSDictionary*)configParams:(NSDictionary*)params
{
    return params;
}

#pragma mark - 请求参数

- (NSDictionary *)requestParamsForServer
{
    if (self.paramSource&&[self.paramSource respondsToSelector:@selector(requestParamsForServer:)]) {
        return [self.paramSource requestParamsForServer:self];
    }
    
    return nil;
}

- (void)requestCallDidSuccess
{
    [self beforeRequestCallSuccess];
    [self.delegate requestCallDidSuccess:self];
}

- (void)requestCallDidFailed
{
    [self beforeRequestCallFail];
    [self.delegate requestCallDidFailed:self];
}

- (void)beforeRequestCallSuccess
{
    if (self.extensionDelegate&&[self.extensionDelegate respondsToSelector:@selector(extensionBeforeRequestCallSuccess:)]) {
        [self.extensionDelegate extensionBeforeRequestCallSuccess:self];
    }
}

- (void)beforeRequestCallFail
{
    if (self.extensionDelegate&&[self.child respondsToSelector:@selector(extensionBeforeRequestCallFail:)]) {
        [self.extensionDelegate extensionBeforeRequestCallFail:self];
    }
}

#pragma mark - 取消之前的http请求

- (void)cancelPreviousRequest
{
    if (self.preRequest) {
        [self.preRequest cancel];
    }
}

#pragma - 是否在最短时间内

- (NSTimeInterval)requestShortestTime
{
    NSTimeInterval res = 0;
    
    if (self.requestTime) {
        NSTimeInterval requestTime = [[NSDate date] timeIntervalSinceDate:self.requestTime];
        if (requestTime < [BaseHttpServerManager sharedInstance].requestShortestTime) {
            res = [BaseHttpServerManager sharedInstance].requestShortestTime - requestTime;
        }
    }
    
    NSLog(@"isRequestShortestTime===>%f",res);
    
    return res;
}

- (NSString*)BaseHttpServerRequestType
{
    if (self.child) {
        switch ([self.child requestType]) {
        case BaseHttpServerRequestTypeGet:
            return @"BaseHttpServerRequestTypeGet";
            case BaseHttpServerRequestTypeSynPost:
                return @"BaseHttpServerRequestTypeSynPost";
            case BaseHttpServerRequestTypeAsynPost:
                return @"BaseHttpServerRequestTypeAsynPost";
            case BaseHttpServerRequestTypeAsynPostAndUpdateFile:
                return @"BaseHttpServerRequestTypeAsynPostAndUpdateFile";
            case BaseHttpServerRequestTypeRestGet:
                return @"BaseHttpServerRequestTypeRestGet";
            case BaseHttpServerRequestTypeRestPost:
                return @"BaseHttpServerRequestTypeRestPost";
        default:
            break;
        }
    }
    
    return @"";
}

- (NSString*)BaseHttpServerRequestStatus
{
    
    switch (self.requestStatus) {
        case BaseHttpServerRequestStatusDefault:
            return @"BaseHttpServerRequestStatusDefault";
        case BaseHttpServerRequestStatusSuccess:
            return @"BaseHttpServerRequestStatusSuccess";
        case BaseHttpServerRequestStatusTimeout:
            return @"BaseHttpServerRequestStatusTimeout";
        case BaseHttpServerRequestStatusNoNetWork:
            return @"BaseHttpServerRequestStatusNoNetWork";
        case BaseHttpServerRequestStatusFailCode:
            return @"BaseHttpServerRequestStatusFailCode";
        case BaseHttpServerRequestStatusNonMainIP:
            return @"BaseHttpServerRequestStatusNonMainIP";
        default:
            break;
    }
    return @"";
}

- (BOOL)isNetWorkReachable
{
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}

@end
