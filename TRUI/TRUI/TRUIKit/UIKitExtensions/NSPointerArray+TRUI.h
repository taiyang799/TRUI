//
//  NSPointerArray+TRUI.h
//  TRUI
//
//  Created by Mac on 2020/4/23.
//  Copyright © 2020 Mac. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPointerArray (TRUI)

- (NSUInteger)trui_indexOfPointer:(nullable void *)pointer;
- (BOOL)trui_containsPointer:(nullable void *)pointer;

@end

NS_ASSUME_NONNULL_END
