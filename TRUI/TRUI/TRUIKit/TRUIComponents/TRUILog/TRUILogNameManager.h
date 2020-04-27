//
//  TRUILogNameManager.h
//  TRUI
//
//  Created by Mac on 2020/4/22.
//  Copyright © 2020 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

///所有TRUILog的 name 都会以这个 key 存储到NSUserDefaults里（类型为NSDictionary<NSString *, NSNumber *> *）,可通过dictionaryForKey：获取到所有的 name 及对应的 enabled 状态
extern NSString *_Nonnull const TRUILoggerAllNamesKeyInUserDefaults;

///log.name的管理器，由它来管理每一个 name 是否可用、以及清理不需要的name
@interface TRUILogNameManager : NSObject

///获取当前所有logName，key为logName名，value为name的enabled状态，可通过value.boolValue读取它的值
@property (nullable, nonatomic, copy, readonly) NSDictionary<NSString *, NSNumber *> *allNames;

- (BOOL)containsLogName:(nullable NSString *)logName;
- (void)setEnabled:(BOOL)enabled forLogName:(nullable NSString *)logName;
- (BOOL)enabledForLogName:(nullable NSString *)logName;
- (void)removeLogName:(nullable NSString *)logName;
- (void)removeAllNames;

@end

