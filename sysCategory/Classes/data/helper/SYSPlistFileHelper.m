//
//  SYSPlistFileHelper.m
//  Pods-sysCategory_Example
//
//  Created by mutouren on 2017/11/13.
//

#import "SYSPlistFileHelper.h"

@implementation SYSPlistFileHelper


+ (BOOL)saveDataWithDirectory:(NSDictionary *)params fileName:(NSString *)fileName {
    if (fileName && fileName.length) {
        return [NSKeyedArchiver archiveRootObject:params toFile:fileName];
    }
    
    return NO;
}

+ (BOOL)saveDataWithArray:(NSArray *)params fileName:(NSString *)fileName {
    if (fileName && fileName.length) {
        return [NSKeyedArchiver archiveRootObject:params toFile:fileName];
    }
    
    return NO;
}

+ (NSString *)tweakDirectory {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *file = SYSPlistFilePathName;
    path = [path stringByAppendingPathComponent:file];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return path;
}

@end
