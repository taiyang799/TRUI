//
//  NSURL+TRUI.h
//  TRUI
//
//  Created by Mac on 2020/4/28.
//  Copyright © 2020 Mac. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface NSURL (TRUI)

/// 获取当前query的参数列表
/// @return query 参数列表，以字典返回。如果 absoluteString 为nil 则返回nil
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *trui_queryItems;

@end

