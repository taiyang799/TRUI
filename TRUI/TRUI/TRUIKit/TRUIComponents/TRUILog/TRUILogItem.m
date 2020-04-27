//
//  TRUILogItem.m
//  TRUI
//
//  Created by Mac on 2020/4/22.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "TRUILogItem.h"
#import "TRUILogNameManager.h"
#import "TRUILogger.h"

@implementation TRUILogItem

+ (instancetype)logItemWithLevel:(TRUILogLevel)level name:(NSString *)name logString:(NSString *)logString, ...
{
    TRUILogItem *logItem = [[TRUILogItem alloc] init];
    logItem.level = level;
    logItem.name = name;
    
    TRUILogNameManager *logNameManager = [TRUILogger sharedInstance].logNameManager;
    if ([logNameManager containsLogName:name]) {
        logItem.enabled = [logNameManager enabledForLogName:name];
    } else {
        [logNameManager setEnabled:YES forLogName:name];
        logItem.enabled = YES;
    }
    
    va_list args;
    va_start(args, logString);
    logItem.logString = [[NSString alloc] initWithFormat:logString arguments:args];
    va_end(args);
    
    return logItem;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.enabled = YES;
    }
    return self;
}

- (NSString *)levelDisplayString
{
    switch (self.level) {
        case TRUILogLevelInfo:
            return @"TRUILogLevelInfo";
            break;
        case TRUILogLevelWarn:
            return @"TRUILogLevelWarn";
            break;
        default:
            return @"TRUILogLevelDefault";
            break;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ | %@ | %@",self.levelDisplayString, self.name.length > 0 ? self.name : @"Default", self.logString];
}

@end
