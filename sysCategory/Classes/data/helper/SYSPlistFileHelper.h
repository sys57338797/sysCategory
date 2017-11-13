//
//  SYSPlistFileHelper.h
//  Pods-sysCategory_Example
//
//  Created by mutouren on 2017/11/13.
//

#import <Foundation/Foundation.h>

NSString const *SYSPlistFilePathName = @"SYS";


@interface SYSPlistFileHelper : NSObject

+ (BOOL)saveDataWithDirectory:(NSDictionary *)params fileName:(NSString *)fileName;

+ (BOOL)saveDataWithArray:(NSArray *)params fileName:(NSString *)fileName;

@end
