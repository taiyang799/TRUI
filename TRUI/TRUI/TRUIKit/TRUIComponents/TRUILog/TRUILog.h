//
//  TRUILog.h
//  TRUI
//
//  Created by Mac on 2020/4/23.
//  Copyright © 2020 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TRUILogItem.h"
#import "TRUILogNameManager.h"
#import "TRUILogger.h"

///以下是TRUI提供的用于代替NSLog()的打 log 的方法，可根据 logName、logLevel 两个维度来控制某些 log 是否要被打印，以便在调试时去掉不关注的 log
#define TRUILog(_name, ...) [[TRUILogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[TRUILogItem logItemWithLevel:TRUILogLevelDefault name:_name logString:__VA_ARGS__]]
#define TRUILogInfo(_name, ...) [[TRUILogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[TRUILogItem logItemWithLevel:TRUILogLevelInfo name:_name logString:__VA_ARGS__]]
#define TRUILogWarn(_name, ...) [[TRUILogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[TRUILogItem logItemWithLevel:TRUILogLevelWarn name:_name logString:__VA_ARGS__]]
