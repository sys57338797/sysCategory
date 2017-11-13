//
//  BaseHttpServerManager.m
//
//  Created by mutouren on 12/23/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import "BaseHttpServerManager.h"
#import "NSURLRequest+RequestParams.h"
#import "HttpServerContext.h"
#import "HttpSignatureGenerator.h"
#import "domainIPHttpServer.h"

@interface BaseHttpServerManager ()<DomainIpDelegate>

@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;

@property (nonatomic, strong) NSMutableSet *waitingPoolMain;
@property (nonatomic, strong) NSMutableSet *waitingPoolUpload;

@end

@implementation BaseHttpServerManager

+ (instancetype)sharedInstance
{
    static BaseHttpServerManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BaseHttpServerManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [domainIPHttpServer shareInstance].dependencyDelegate = self;
    }
    return self;
}

- (void)createQueueForWaitingDomainIp:(BaseHttpServer*)requestServer domain:(NSString *)domain
{
    domainIPHttpServer *domainSer = [domainIPHttpServer shareInstance];
    
    if ([domain isEqualToString:KDomainIPServerParamOwnerMainIP]) {
        if (domainSer.mainIp) {
            [requestServer createOperation];
            return;
        }
        [self.waitingPoolMain addObject:requestServer];
    }
    else if ([domain isEqualToString:KDomainIPServerParamOwnerUploadIP]) {
        if (domainSer.uploadIp) {
            [requestServer createOperation];
            return;
        }
        [self.waitingPoolUpload addObject:requestServer];
    }
    
    [domainSer requestMainAndUploadIPWithParam:domain];
}

#pragma mark - Public Methods

- (HttpResponse*)callSynPOSTWithParams:(NSDictionary *)params url:(NSString *)url
{
    NSURLRequest *request = [self httpPOSTRequestWithUrl:url requestParams:params];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
     AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    
    [requestOperation setResponseSerializer:responseSerializer];
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    return [[HttpResponse alloc]initResponseWithRequest:requestOperation.request responseData:requestOperation.responseData error:requestOperation.error];
}

- (AFHTTPRequestOperation *)callGETWithParams:(NSDictionary *)params url:(NSString *)url success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail
{
    NSURLRequest *request = [self httpGetRequestWithUrl:url requestParams:params];
    return [self callHttpWithRequest:request success:success fail:fail];
}

- (AFHTTPRequestOperation *)callAsynPOSTWithParams:(NSDictionary *)params url:(NSString *)url success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail
{
    NSURLRequest *request = [self httpPOSTRequestWithUrl:url requestParams:params];
    return [self callHttpWithRequest:request success:success fail:fail];
}

- (AFHTTPRequestOperation *)callAsynPOSTWithParams:(NSDictionary *)params url:(NSString *)url updateFileData:(NSData*)data success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail
{
    NSURLRequest *request = [self httpPOSTRequestWithUrl:url requestParams:params fileData:data];
    return [self callHttpWithRequest:request success:success fail:fail];
}

#pragma mark - 起飞的最后一步，如果需要更换http第三方请求库，只需要在这里替换

- (AFHTTPRequestOperation *)callHttpWithRequest:(NSURLRequest*)request success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail
{
    AFHTTPRequestOperation *httpRequestOperation = [self.operationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        HttpResponse *response =[[HttpResponse alloc]initResponseWithRequest:operation.request responseData:operation.responseData error:nil];
        
        success?success(response):nil;
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        HttpResponse *response = [[HttpResponse alloc]initResponseWithRequest:operation.request responseData:operation.responseData error:operation.error];
        fail?fail(response):nil;
    }];
    
    [[self.operationManager operationQueue] addOperation:httpRequestOperation];
    
    return httpRequestOperation;
}

#pragma mark - 返回"GET"方式的NSURLRequest

- (NSURLRequest*)httpGetRequestWithUrl:(NSString*)url requestParams:(NSDictionary*)params
{
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:url parameters:params error:NULL];
    
    NSDictionary *header = [self makeRESTHeader];
    
    [header enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    request.requestParams = params;
    
    return request;
}

#pragma mark - 返回"POST"方式的NSURLRequest

- (NSURLRequest*)httpPOSTRequestWithUrl:(NSString*)url requestParams:(NSDictionary*)params
{
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"POST" URLString:url parameters:params error:NULL];
    
    NSDictionary *header = [self makeRESTHeader];
    
    [header enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    request.requestParams = params;
    
    return request;
}

#pragma mark - 返回"POST"方式的NSURLRequest,HTTP body带上传数据

- (NSURLRequest*)httpPOSTRequestWithUrl:(NSString*)url requestParams:(NSDictionary*)params fileData:(NSData*)data
{
    NSMutableURLRequest *request = [self.httpRequestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSString *name = @"userId";
        [formData appendPartWithFileData:data name:@"File" fileName:[name stringByAppendingString:@".jpg"] mimeType:@"image/jpg"];
    } error:NULL];
    
    NSDictionary *header = [self makeRESTHeader];
    
    [header enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    request.requestParams = params;
    
    return request;
}

#pragma mark - 创建REST头部

- (NSDictionary*)makeRESTHeader
{
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionary];
    NSString *cookie = @"";
    if (cookie) {
        [headerDic setObject:cookie forKey:@"Cookie"];
    }
    return headerDic;
}

#pragma mark - Cancel HttpOperation

- (void)cancelAllHttpOperation
{
    [self.operationManager.operationQueue cancelAllOperations];
}

#pragma mark - DomainIP Delegate

- (void)domainIpDidPrepared:(NSString *)domain {
    NSLog(@">>>%@ ready",domain);
    
    if ([domain isEqualToString:KDomainIPServerParamOwnerMainIP]) {
        [self.waitingPoolMain enumerateObjectsUsingBlock:^(BaseHttpServer* requestServer,BOOL *stop){
            NSLog(@"enumerate main waiting loop");
            [requestServer createOperation];
            [self.waitingPoolMain removeObject:requestServer];
        }];
    }
    else if ([domain isEqualToString:KDomainIPServerParamOwnerUploadIP]) {
        [self.waitingPoolUpload enumerateObjectsUsingBlock:^(BaseHttpServer* requestServer,BOOL *stop){
            NSLog(@"enumerate upload waiting loop");
            [requestServer createOperation];
            [self.waitingPoolUpload removeObject:requestServer];
        }];
    }
}

- (void)domainIpStillNotPrepared:(NSString *)domain {
    //do something or not
    NSLog(@">>>request %@ failed !",domain);
}

#pragma mark - Lazy

- (AFHTTPRequestOperationManager*)operationManager
{
    if (!_operationManager) {
        _operationManager = [AFHTTPRequestOperationManager manager];
        _operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    return _operationManager;
}

- (AFHTTPRequestSerializer*)httpRequestSerializer
{
    if (!_httpRequestSerializer) {
        // 设置超时时间
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        [_httpRequestSerializer willChangeValueForKey:@"timeoutInterval"];
        _httpRequestSerializer.timeoutInterval = 10.0f;
        [_httpRequestSerializer didChangeValueForKey:@"timeoutInterval"];
        _httpRequestSerializer.HTTPShouldHandleCookies = NO;
    }
    
    return _httpRequestSerializer;
}

- (NSMutableSet*)waitingPoolMain
{
    if (!_waitingPoolMain) {
        _waitingPoolMain = [[NSMutableSet alloc]init];
    }
    return _waitingPoolMain;
}

- (NSMutableSet*)waitingPoolUpload
{
    if (!_waitingPoolUpload) {
        _waitingPoolUpload = [[NSMutableSet alloc]init];
    }
    return _waitingPoolUpload;
}

@end
