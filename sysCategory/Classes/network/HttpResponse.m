//
//  HttpResponse.m
//
//  Created by mutouren on 12/24/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import "HttpResponse.h"

@implementation HttpResponse

- (instancetype)initResponseWithRequest:(NSURLRequest*)request responseData:(NSData*)responseData error:(NSError*)error;
{
    self = [super init];
    if (self) {
        if (responseData) {
            _encryptContent = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            _content = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        }
        _status = [self responseStatusWithError:error];
        _request = request;
        _responseData = responseData;
    }
    
    return self;
}

- (HttpResponseStatus)responseStatusWithError:(NSError*)error
{
    if (error) {
        if (error.code == NSURLErrorTimedOut) {
            return HttpResponseStatusErrorTimeout;
        }
        else {
            return HttpResponseStatusErrorNoNetwork;
        }
    }
    
    return HttpResponseStatusSuccess;
}

@end
