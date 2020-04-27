//
//  TRUILogItem.h
//  TRUI
//
//  Created by Mac on 2020/4/22.
//  Copyright © 2020 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TRUILogLevel) {
    TRUILogLevelDefault,///当使用 TRUILog()时使用的等级
    TRUILogLevelInfo,///当使用 TRUILogInfo()时使用的等级,比TRUILogLevelDefault 要轻量，适用于一些无关紧要的信息
    TRUILogLevelWarn,///当使用 TRUILogWarn()时使用的等级,最重，适用于一些异常或者严重错误的场景
};

///每一条TRUILog 日志都以 TRIUILogItem 的形式包装起来
@interface TRUILogItem : NSObject

///日志的等级，可通过TRUIConfigurationTemplate 配置表控制全局每个level是否可用
@property (nonatomic, assign) TRUILogLevel level;
@property (nonatomic, copy, readonly) NSString *levelDisplayString;
///可利用name字段为日志分类，TRUILogNameManager可全局控制某一个name是否可用
@property (nullable, nonatomic, copy) NSString *name;
///日志内容
@property (nonatomic, copy) NSString *logString;
///当前logItem对应的name是否可用，可通过TRUILogNameManager控制，默认为YES
@property (nonatomic, assign) BOOL enabled;

+ (nonnull instancetype)logItemWithLevel:(TRUILogLevel)level name:(nullable NSString *)name logString:(nonnull NSString *)logString, ...NS_FORMAT_FUNCTION(3, 4);

@end

NS_ASSUME_NONNULL_END
