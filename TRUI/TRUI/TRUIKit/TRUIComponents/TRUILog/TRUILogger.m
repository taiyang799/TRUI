//
//  TRUILogger.m
//  TRUI
//
//  Created by Mac on 2020/4/22.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "TRUILogger.h"
#import "TRUILogNameManager.h"
#import "TRUILogItem.h"

@implementation TRUILogger

+ (instancetype)sharedInstance
{
    static TRUILogger *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (instancetype)init
{
    if (self = [super init]) {
        self.logNameManager = [[TRUILogNameManager alloc] init];
    }
    return self;
}

- (void)printLogWithFile:(const char *)file line:(int)line func:(const char *)func logItem:(TRUILogItem *)logItem
{
    //禁用了某个 name 则直接退出
    if (!logItem.enabled) {
        return;
    }
    
    NSString *fileString = [NSString stringWithFormat:@"%s", file];
    NSString *funcString = [NSString stringWithFormat:@"%s", func];
    NSString *defaultString = [NSString stringWithFormat:@"%@:%@ | %@", funcString, @(line), logItem];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(printTRUILogWithFile:line:func:logItem:defaultString:)]) {
        [self.delegate printTRUILogWithFile:fileString line:line func:funcString logItem:logItem defaultString:defaultString];
    } else {
        NSLog(@"%@",defaultString);
    }
}

@end
