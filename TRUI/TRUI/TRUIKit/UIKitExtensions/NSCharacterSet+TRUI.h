//
//  NSCharacterSet+TRUI.h
//  TRUI
//
//  Created by Mac on 2020/4/23.
//  Copyright © 2020 Mac. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSCharacterSet (TRUI)

/// 也即在系统的 URLQueryAllowedCharacterSet 基础上去掉”#&=“这3个字符，专用于 URL query 里来源于用户输入的value，避免服务器解析出现异常
@property (class, readonly, copy) NSCharacterSet *trui_URLUserInputQueryAllowedCharacterSet;

@end

