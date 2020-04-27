//
//  NSAttributedString+TRUI.m
//  TRUI
//
//  Created by Mac on 2020/4/27.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "NSAttributedString+TRUI.h"
#import "TRUIRuntime.h"
#import "NSString+TRUI.h"

@implementation NSAttributedString (TRUI)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //类簇对不同的init方法对应不同的私有class，所以要用实例来得到真正的class
        OverrideImplementation([[[NSAttributedString alloc] initWithString:@""] class], @selector(initWithString:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSAttributedString *(NSAttributedString *selfObject, NSString *str){
                str = str?:@"";
                
                //call super
                NSAttributedString *(*originSelectorIMP)(id, SEL, NSString *);
                originSelectorIMP = (NSAttributedString *(*)(id, SEL, NSString *))originalIMPProvider();
                NSAttributedString *reslt = originSelectorIMP(selfObject, originCMD, str);
                
                return reslt;
            };
        });
        
        OverrideImplementation([[[NSAttributedString alloc] initWithString:@"" attributes:nil] class], @selector(initWithString:attributes:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSAttributedString *(NSAttributedString *selfObject, NSString *str, NSDictionary<NSString *,id> *attrs) {
                str = str ?: @"";
                
                // call super
                NSAttributedString *(*originSelectorIMP)(id, SEL, NSString *, NSDictionary<NSString *,id> *);
                originSelectorIMP = (NSAttributedString *(*)(id, SEL, NSString *, NSDictionary<NSString *,id> *))originalIMPProvider();
                NSAttributedString *result = originSelectorIMP(selfObject, originCMD, str, attrs);
                
                return result;
            };
        });
    });
}

- (NSUInteger)trui_lengthWhenCountingNonASCIICharacterAsTwo
{
    return self.string.trui_lengthWhenCountingNonASCIICharacterAsTwo;
}

+ (instancetype)trui_attributedStringWithImage:(UIImage *)image
{
    return [self trui_attributedStringWithImage:image baselineOffset:0 leftMargin:0 rightMargin:0];
}

+ (instancetype)trui_attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)offset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin
{
    if (!image) {
        return nil;
    }
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    NSMutableAttributedString *string = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    [string addAttribute:NSBaselineOffsetAttributeName value:@(offset) range:NSMakeRange(0, string.length)];
    if (leftMargin > 0) {
        [string insertAttributedString:[self trui_attributedStringWithFixedSpace:leftMargin] atIndex:0];
    }
    if (rightMargin > 0) {
        [string appendAttributedString:[self trui_attributedStringWithFixedSpace:rightMargin]];
    }
    return string;
}

+ (instancetype)trui_attributedStringWithFixedSpace:(CGFloat)width
{
    UIGraphicsBeginImageContext(CGSizeMake(width, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [self trui_attributedStringWithImage:image];
}

@end

@implementation NSMutableAttributedString (TRUI)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 类簇对不同的init方法对应不同的私有class，所以要用实例来得到真正的class
        OverrideImplementation([[[NSMutableAttributedString alloc] initWithString:@""] class], @selector(initWithString:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSMutableAttributedString *(NSMutableAttributedString *selfObject, NSString *str) {
                
                str = str ?: @"";
                
                // call super
                NSMutableAttributedString *(*originSelectorIMP)(id, SEL, NSString *);
                originSelectorIMP = (NSMutableAttributedString *(*)(id, SEL, NSString *))originalIMPProvider();
                NSMutableAttributedString *result = originSelectorIMP(selfObject, originCMD, str);
                
                return result;
            };
        });
        
        OverrideImplementation([[[NSMutableAttributedString alloc] initWithString:@"" attributes:nil] class], @selector(initWithString:attributes:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSMutableAttributedString *(NSMutableAttributedString *selfObject, NSString *str, NSDictionary<NSString *,id> *attrs) {
                str = str ?: @"";
                
                // call super
                NSMutableAttributedString *(*originSelectorIMP)(id, SEL, NSString *, NSDictionary<NSString *,id> *);
                originSelectorIMP = (NSMutableAttributedString *(*)(id, SEL, NSString *, NSDictionary<NSString *,id> *))originalIMPProvider();
                NSMutableAttributedString *result = originSelectorIMP(selfObject, originCMD, str, attrs);
                
                return result;
            };
        });
    });
}

@end
