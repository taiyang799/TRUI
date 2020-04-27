//
//  NSNumber+TRUI.m
//  TRUI
//
//  Created by Mac on 2020/4/23.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "NSNumber+TRUI.h"

@implementation NSNumber (TRUI)

- (CGFloat)trui_CGFloatValue
{
#if CGFLOAT_IS_DOUBLE
    return self.doubleValue;
#else
    return self.floatValue;
#endif
}

@end
