//
//  NSPointerArray+TRUI.m
//  TRUI
//
//  Created by Mac on 2020/4/23.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "NSPointerArray+TRUI.h"
#import <objc/runtime.h>
#import "TRUIRuntime.h"

@implementation NSPointerArray (TRUI)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithoutArguments([NSPointerArray class], @selector(description), NSString *, ^NSString *(NSPointerArray *selfObject, NSString *originReturnValue) {
            NSMutableString *result = [[NSMutableString alloc] initWithString:originReturnValue];
            NSPointerArray *arr = [selfObject copy];
            for (NSInteger i = 0; i < arr.count; i++) {
                ([result appendFormat:@"\npointer[%@] is %@", @(i), [arr pointerAtIndex:i]]);
            }
            return result;
        });
    });
}

- (NSUInteger)trui_indexOfPointer:(void *)pointer
{
    if (!pointer) {
        return NSNotFound;
    }
    NSPointerArray *array = [self copy];
    for (NSUInteger i = 0; i < array.count; i++) {
        if ([array pointerAtIndex:i] == ((void *)pointer)) {
            return i;
        }
    }
    return NSNotFound;
}

- (BOOL)trui_containsPointer:(void *)pointer
{
    if (!pointer) {
        return NO;
    }
    if ([self trui_indexOfPointer:pointer] != NSNotFound) {
        return YES;
    }
    return NO;
}

@end
