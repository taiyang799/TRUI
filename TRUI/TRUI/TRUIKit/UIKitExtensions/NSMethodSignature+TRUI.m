//
//  NSMethodSignature+TRUI.m
//  TRUI
//
//  Created by Mac on 2020/4/27.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "NSMethodSignature+TRUI.h"
#import "TRUICommonDefines.h"

@implementation NSMethodSignature (TRUI)

+ (NSMethodSignature *)trui_avoidExceptionSignature
{
    return [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
}

- (NSString *)trui_typeString
{
    BeginIgnorePerformSelectorLeaksWarning
    NSString *typeString = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"_%@String", @"type"])];
    EndIgnorePerformSelectorLeaksWarning
    return typeString;
}

- (const char *)trui_typeEncoding
{
    return self.trui_typeString.UTF8String;
}

@end
