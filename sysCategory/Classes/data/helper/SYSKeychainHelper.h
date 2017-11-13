//
//  OMTKeychainHelper.h
//
//
//  Created by mutouren on 15/7/14.
//  Copyright (c) 2015年 onemt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMTKeychainHelper : NSObject

AS_SINGLETON(OMTKeychainItemWrapper)

//Creating an item in the keychain
- (void)save:(NSString *)service data:(id)data;

//Searching the keychain
- (id)load:(NSString *)service;

//Deleting an item from the keychain
- (void)delete:(NSString *)service;

@end
