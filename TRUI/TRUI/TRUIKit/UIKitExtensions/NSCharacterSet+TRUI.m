//
//  NSCharacterSet+TRUI.m
//  TRUI
//
//  Created by Mac on 2020/4/23.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "NSCharacterSet+TRUI.h"

@implementation NSCharacterSet (TRUI)

+ (NSCharacterSet *)trui_URLUserInputQueryAllowedCharacterSet
{
    NSMutableCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet].mutableCopy;
    [set removeCharactersInString:@"#&="];
    return set.copy;
}

@end
