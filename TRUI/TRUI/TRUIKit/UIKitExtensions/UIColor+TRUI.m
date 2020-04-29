//
//  UIColor+TRUI.m
//  TRUI
//
//  Created by Mac on 2020/4/28.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "UIColor+TRUI.h"
#import "TRUIRuntime.h"
#import "TRUIConfigurationMacros.h"
#import "TRUICommonDefines.h"
#import "NSObject+TRUI.h"

@implementation UIColor (TRUI)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 使用 [UIColor colorWithRed:green:blue:alpha:] 或 [UIColor colorWithHue:saturation:brightness:alpha:] 方法创建的颜色是 UIDeviceRGBColor 类型的而不是 UIColor 类型的
        ExtendImplementationOfNonVoidMethodWithoutArguments([[UIColor colorWithRed:1 green:1 blue:1 alpha:1] class], @selector(description), NSString *, ^NSString *(UIColor *selfObject, NSString *originReturnValue){
            NSInteger red = selfObject.trui_red * 255;
            NSInteger green = selfObject.trui_green * 255;
            NSInteger blue = selfObject.trui_blue * 255;
            CGFloat alpha = selfObject.trui_alpha;
            NSString *description = ([NSString stringWithFormat:@"%@, RGBA(%@, %@, %@, %.2f), %@", originReturnValue, @(red), @(green), @(blue), alpha, [selfObject trui_hexString]]);
            return description;
        });
    });
}

+ (UIColor *)trui_colorWithHexString:(NSString *)hexString
{
    if (hexString.length <= 0) return nil;
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default: {
            NSAssert(NO, @"Color value %@ is invalid. It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString);
            return nil;
        }
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (NSString *)trui_hexString
{
    NSInteger alpha = self.trui_alpha * 255;
    NSInteger red = self.trui_red * 255;
    NSInteger green = self.trui_green * 255;
    NSInteger blue = self.trui_blue * 255;
    return [[NSString stringWithFormat:@"#%@%@%@%@",
             [self alignColorHexStringLength:[NSString trui_hexStringWithInteger:alpha]],
             [self alignColorHexStringLength:[NSString trui_hexStringWithInteger:red]],
             [self alignColorHexStringLength:[NSString trui_hexStringWithInteger:green]],
             [self alignColorHexStringLength:[NSString trui_hexStringWithInteger:blue]]] lowercaseString];
}

///对于色值只有单位数的，在前面补一个0，例如"F"会补齐为"0F"
- (NSString *)alignColorHexStringLength:(NSString *)hexString
{
    return hexString.length < 2 ? [@"0" stringByAppendingString:hexString] : hexString;
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length
{
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

- (CGFloat)trui_red
{
    CGFloat r;
    if ([self getRed:&r green:0 blue:0 alpha:0]) {
        return r;
    }
    return 0;
}

- (CGFloat)trui_green
{
    CGFloat g;
    if ([self getRed:0 green:&g blue:0 alpha:0]) {
        return g;
    }
    return 0;
}

- (CGFloat)trui_blue
{
    CGFloat b;
    if ([self getRed:0 green:0 blue:&b alpha:0]) {
        return b;
    }
    return 0;
}

- (CGFloat)trui_alpha
{
    CGFloat a;
    if ([self getRed:0 green:0 blue:0 alpha:&a]) {
        return a;
    }
    return 0;
}

- (CGFloat)trui_hue
{
    CGFloat h;
    if ([self getHue:&h saturation:0 brightness:0 alpha:0]) {
        return h;
    }
    return h;
}

- (CGFloat)trui_saturation
{
    CGFloat s;
    if ([self getHue:0 saturation:&s brightness:0 alpha:0]) {
        return s;
    }
    return 0;
}

- (CGFloat)trui_brightness
{
    CGFloat b;
    if ([self getHue:0 saturation:0 brightness:&b alpha:0]) {
        return b;
    }
    return 0;
}

- (UIColor *)trui_colorWithoutAlpha
{
    CGFloat r, g, b;
    if ([self getRed:&r green:&g blue:&b alpha:0]) {
        return [UIColor colorWithRed:r green:g blue:b alpha:1];
    } else {
        return nil;
    }
}

- (UIColor *)trui_colorWithAlpha:(CGFloat)alpha backgroundColor:(UIColor *)backgroundColor
{
    return [UIColor trui_colorWithBackendColor:backgroundColor frontColor:[self colorWithAlphaComponent:alpha]];
}

- (UIColor *)trui_colorWithAlphaAddedToWhite:(CGFloat)alpha
{
    return [self trui_colorWithAlpha:alpha backgroundColor:UIColorWhite];
}

- (UIColor *)trui_transitionToColor:(UIColor *)toColor progress:(CGFloat)progress
{
    return [UIColor trui_colorFromColor:self toColor:toColor progress:progress];
}

- (BOOL)trui_colorIsDark
{
    CGFloat red = 0.0, green = 0.0, blue = 0.0;
    if ([self getRed:&red green:&green blue:&blue alpha:0]) {
        float referenceValue = 0.411;
        float colorDelta = (red * 0.299) + (green * 0.587) + (blue * 0.114);
        
        return 1.0 - colorDelta > referenceValue;
    }
    return YES;
}

- (UIColor *)trui_inverseColor
{
    const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
    UIColor *newColor = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
                                               green:(1.0 - componentColors[1])
                                                blue:(1.0 - componentColors[2])
                                               alpha:componentColors[3]];
    return newColor;
}

- (BOOL)trui_isSystemTintColor
{
    return [self isEqual:[UIColor trui_systemTintColor]];
}

+ (UIColor *)trui_systemTintColor
{
    static UIColor *systemTintColor = nil;
    if (!systemTintColor) {
        UIView *view = [[UIView alloc] init];
        systemTintColor = view.tintColor;
    }
    return systemTintColor;
}

+ (UIColor *)trui_colorWithBackendColor:(UIColor *)backendColor frontColor:(UIColor *)frontColor
{
    CGFloat bgAlpha = [backendColor trui_alpha];
    CGFloat bgRed =   [backendColor trui_red];
    CGFloat bgGreen = [backendColor trui_green];
    CGFloat bgBlue =  [backendColor trui_blue];
    
    CGFloat frAlpha = [frontColor trui_alpha];
    CGFloat frRed =   [frontColor trui_red];
    CGFloat frGreen = [frontColor trui_green];
    CGFloat frBlue =  [frontColor trui_blue];
    
    CGFloat resultAlpha = frAlpha + bgAlpha * (1 - frAlpha);
    CGFloat resultRed = (frRed * frAlpha + bgRed * bgAlpha * (1 - frAlpha)) / resultAlpha;
    CGFloat resultGreen = (frGreen * frAlpha + bgGreen * bgAlpha * (1 - frAlpha)) / resultAlpha;
    CGFloat resultBlue = (frBlue * frAlpha + bgBlue * bgAlpha * (1 - frAlpha)) / resultAlpha;
    return [UIColor colorWithRed:resultRed green:resultGreen blue:resultBlue alpha:resultAlpha];
}

+ (UIColor *)trui_colorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress
{
    progress = MIN(progress, 1.0f);
    CGFloat fromRed = fromColor.trui_red;
    CGFloat fromGreen = fromColor.trui_green;
    CGFloat fromBlue = fromColor.trui_blue;
    CGFloat fromAlpha = fromColor.trui_alpha;
    
    CGFloat toRed = toColor.trui_red;
    CGFloat toGreen = toColor.trui_green;
    CGFloat toBlue = toColor.trui_blue;
    CGFloat toAlpha = toColor.trui_alpha;
    
    CGFloat finalRed = fromRed + (toRed - fromRed) * progress;
    CGFloat finalGreen = fromGreen + (toGreen - fromGreen) * progress;
    CGFloat finalBlue = fromBlue + (toBlue - fromBlue) * progress;
    CGFloat finalAlpha = fromAlpha + (toAlpha - fromAlpha) * progress;
    
    return [UIColor colorWithRed:finalRed green:finalGreen blue:finalBlue alpha:finalAlpha];
}

+ (UIColor *)trui_randomColor
{
    CGFloat red = ( arc4random() % 255 / 255.0 );
    CGFloat green = ( arc4random() % 255 / 255.0 );
    CGFloat blue = ( arc4random() % 255 / 255.0 );
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end

NSString *const TRUICGColorOriginalColorBindKey = @"TRUICGColorOriginalColorBindKey";
@implementation UIColor (TRUI_DynamicColor)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifdef IOS13_SDK_ALLOWED
        if (@available(iOS 13.0, *)) {
            ExtendImplementationOfNonVoidMethodWithoutArguments([UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                return [UIColor clearColor];
            }].class, @selector(CGColor), CGColorRef, ^CGColorRef(UIColor *selfObject, CGColorRef originReturnValue){
                if (selfObject.trui_isDynamicColor) {
                    UIColor *color = [UIColor colorWithCGColor:originReturnValue];
                    originReturnValue = color.CGColor;
                    [(__bridge id)(originReturnValue) trui_bindObject:selfObject forKey:TRUICGColorOriginalColorBindKey];
                }
                return originReturnValue;
            });
        }
#endif
    });
}

- (BOOL)trui_isDynamicColor
{
    if ([self respondsToSelector:@selector(_isDynamic)]) {
        return self._isDynamic;
    }
    return NO;
}

- (BOOL)trui_isTRUIDynamicColor
{
    return NO;
}

- (UIColor *)trui_rawColor
{
    if (self.trui_isDynamicColor) {
#ifdef IOS13_SDK_ALLOWED
        if (@available(iOS 13.0, *)) {
            if ([self respondsToSelector:@selector(resolvedColorWithTraitCollection:)]) {
                UIColor *color = [self resolvedColorWithTraitCollection:UITraitCollection.currentTraitCollection];
                return color.trui_rawColor;
            }
        }
#endif
    }
    return self;
}

@end
