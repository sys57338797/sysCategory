//
//  BaseHttpServerManager.h
//
//  Created by mutouren on 12/23/15.
//  Copyright © 2015 mutouren. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "HttpResponse.h"
#import "AFNetworking.h"

@class BaseHttpServer;

static NSTimeInterval kAFNetworkingTimeoutSeconds = 10.0f;

typedef void (^HttpFailureBlock)(HttpResponse* response);
typedef void (^HttpSuccessBlock)(HttpResponse* response);

typedef void (^AFNetworkFormDataBlock)(id <AFMultipartFormData> formData);

@interface BaseHttpServerManager : NSObject

@property (nonatomic, assign) NSTimeInterval requestShortestTime;       //请求最短时间

+ (instancetype)sharedInstance;

// create AFHTTPRequestOperation

- (HttpResponse*)callSynPOSTWithParams:(NSDictionary *)params url:(NSString *)url;

- (AFHTTPRequestOperation *)callGETWithParams:(NSDictionary *)params url:(NSString*)url success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail;

- (AFHTTPRequestOperation *)callAsynPOSTWithParams:(NSDictionary *)params url:(NSString*)url success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail;

- (AFHTTPRequestOperation *)callAsynPOSTWithParams:(NSDictionary *)params url:(NSString *)url updateFileData:(NSData*)data success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail;

// cancel AFHTTPRequestOperation

- (void)cancelAllHttpOperation;

// waiting domain ip

- (void)createQueueForWaitingDomainIp:(BaseHttpServer*)requestServer domain:(NSString*)domain;

@end
