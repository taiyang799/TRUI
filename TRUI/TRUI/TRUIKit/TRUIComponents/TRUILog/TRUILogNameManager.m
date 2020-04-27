//
//  TRUILogNameManager.m
//  TRUI
//
//  Created by Mac on 2020/4/22.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "TRUILogNameManager.h"
#import "TRUILogger.h"

NSString *const TRUILoggerAllNamesKeyInUserDefaults = @"TRUILoggerAllNamesKeyInUserDefaults";

@interface TRUILogNameManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *mutableAllNames;
@property (nonatomic, assign) BOOL didInitialize;

@end

@implementation TRUILogNameManager

- (instancetype)init
{
    if (self = [super init]) {
        self.mutableAllNames = [[NSMutableDictionary alloc] init];
        
        NSDictionary<NSString *, NSNumber *> *allTRUILogNames = [[NSUserDefaults standardUserDefaults] dictionaryForKey:TRUILoggerAllNamesKeyInUserDefaults];
        for (NSString *logName in allTRUILogNames) {
            [self setEnabled:allTRUILogNames[logName].boolValue forLogName:logName];
        }
        
        //初始化时从 NSUserDefauts里获取值的过程，不希望触发 delegate ，所以加这个标志位
        self.didInitialize = YES;
    }
    return self;
}

- (NSDictionary<NSString *,NSNumber *> *)allNames
{
    if (self.mutableAllNames.count) {
        return [self.mutableAllNames copy];
    }
    return nil;
}

- (BOOL)containsLogName:(NSString *)logName
{
    if (logName.length > 0) {
        return !!self.mutableAllNames[logName];
    }
    return NO;
}

- (void)setEnabled:(BOOL)enabled forLogName:(NSString *)logName
{
    if (logName.length > 0) {
        self.mutableAllNames[logName] = @(enabled);
        if (!self.didInitialize) {
            return;
        }
        [self synchronizeUserDefaults];
        
        if ([[TRUILogger sharedInstance].delegate respondsToSelector:@selector(TRUILogName:didChangeEnabled:)]) {
            [[TRUILogger sharedInstance].delegate TRUILogName:logName didChangeEnabled:enabled];
        }
    }
}

- (BOOL)enabledForLogName:(NSString *)logName
{
    if (logName.length > 0) {
        if ([self containsLogName:logName]) {
            return [self.mutableAllNames[logName] boolValue];
        }
    }
    return YES;
}

- (void)removeLogName:(NSString *)logName
{
    if (logName.length > 0) {
        [self.mutableAllNames removeObjectForKey:logName];
        if (!self.didInitialize) {
            return;
        }
        [self synchronizeUserDefaults];
        if ([[TRUILogger sharedInstance].delegate respondsToSelector:@selector(TRUILogNameDidRemove:)]) {
            [[TRUILogger sharedInstance].delegate TRUILogNameDidRemove:logName];
        }
    }
}

- (void)removeAllNames
{
    BOOL shouldCallDelegate = self.didInitialize && [[TRUILogger sharedInstance].delegate respondsToSelector:@selector(TRUILogNameDidRemove:)];
    NSDictionary<NSString *, NSNumber *> *allNames = nil;
    if (shouldCallDelegate) {
        allNames = self.allNames;
    }
    [self.mutableAllNames removeAllObjects];
    [self synchronizeUserDefaults];
    if (shouldCallDelegate) {
        for (NSString *logName in allNames.allKeys) {
            [[TRUILogger sharedInstance].delegate TRUILogNameDidRemove:logName];
        }
    }
}

- (void)synchronizeUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:self.allNames forKey:TRUILoggerAllNamesKeyInUserDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
