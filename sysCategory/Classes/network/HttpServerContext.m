//
//  httpServerContext.m
//  test
//
//  Created by mutouren on 12/23/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import "httpServerContext.h"
#import "NSNotificationCenter+Extra.h"
#import "COCLLocationCoordinateManager.h"

@implementation httpServerContext


#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static httpServerContext *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[httpServerContext alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [NSNotificationCenter addObserverExt:self selector:@selector(receiveDidUpdateUserLocation:) msgName:kDidReceiveDidUpdateUserLocation object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter removeObserverExt:self msgName:kDidReceiveDidUpdateUserLocation object:nil];
}

- (void)receiveDidUpdateUserLocation:(NSNotification*)notification
{
    self.cityName = [COCLLocationCoordinateManager sharedInstance].city;
    if ([[COCLLocationCoordinateManager sharedInstance] userLocation].latitude > 0) {
        self.lat = [[NSNumber numberWithDouble:[[COCLLocationCoordinateManager sharedInstance] userLocation].latitude] stringValue];
    }
    if ([[COCLLocationCoordinateManager sharedInstance] userLocation].longitude > 0) {
        self.lon = [[NSNumber numberWithDouble:[[COCLLocationCoordinateManager sharedInstance] userLocation].longitude] stringValue];
    }
}

- (NSString*)appType
{
    if (!_appType) {
        _appType = @"2";
    }
    
    return _appType;
}

- (NSString*)verName
{
    if (!_verName) {
        NSDictionary * info = [[NSBundle mainBundle] infoDictionary];
        _verName = info[@"CFBundleShortVersionString"];
    }
    
    return _verName;
}

@end
