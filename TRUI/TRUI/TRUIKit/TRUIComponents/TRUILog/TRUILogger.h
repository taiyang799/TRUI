//
//  TRUILogger.h
//  TRUI
//
//  Created by Mac on 2020/4/22.
//  Copyright © 2020 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TRUILogNameManager;
@class TRUILogItem;
@protocol TRUILoggerDelegate <NSObject>
@optional

/// 当每一个 enabled 的TRUILog被使用时都会走到这里，可以由业务自行决定要如何处理这些log，如果没有实现这个方法，默认使用NSLog()打印内容
/// @param file 当前的文件的本地完整路径，可通过file.lastPathComponent 获取文件名
/// @param line 当前log命令在该文件里的代码行数
/// @param func 当前log命令所在方法名
/// @param logItem 当前log命令对应的TRUILogItem，可得知该log的level
/// @param defaultString TRUI默认拼好的log内容
- (void)printTRUILogWithFile:(nonnull NSString *)file line:(int)line func:(nullable NSString *)func logItem:(nullable TRUILogItem *)logItem defaultString:(nullable NSString *)defaultString;

/// 当某个logName的 enabled 发生变化时，通知到delegate。注意如果是新创建某个logName 也会走这里
/// @param logName 变化的logName
/// @param enabled 变化后的值
- (void)TRUILogName:(nonnull NSString *)logName didChangeEnabled:(BOOL)enabled;

/// 某个logName被删除时通知到delegate
/// @param logName logName被删除的logName
- (void)TRUILogNameDidRemove:(nonnull NSString *)logName;

@end

@interface TRUILogger : NSObject

@property (nullable, nonatomic, weak) id<TRUILoggerDelegate> delegate;
@property (nullable, nonatomic, strong) TRUILogNameManager *logNameManager;

+ (nonnull instancetype)sharedInstance;

- (void)printLogWithFile:(nullable const char *)file line:(int)line func:(nonnull const char *)func logItem:(nullable TRUILogItem *)logItem;

@end


