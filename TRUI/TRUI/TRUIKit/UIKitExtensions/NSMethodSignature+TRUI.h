//
//  NSMethodSignature+TRUI.h
//  TRUI
//
//  Created by Mac on 2020/4/27.
//  Copyright © 2020 Mac. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMethodSignature (TRUI)

/// 返回一个避免crash的方法签名，用于重写 methodSignatureForSelector:时作为垫底的 return 方案
@property (nonatomic, nullable, class, readonly) NSMethodSignature *trui_avoidExceptionSignature;

/// 以NSString格式返回当前 NSMethodSignature的 typeEncoding，例如v@:
@property (nonatomic, nullable, copy, readonly) NSString *trui_typeString;

/// 以const char 格式返回当前 NSMethodSignature 的typeEncoding，例如 v@:
@property (nonatomic, nullable, readonly) const char *trui_typeEncoding;

@end

NS_ASSUME_NONNULL_END
