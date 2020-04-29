//
//  NSMutableParagraphStyle+TRUI.m
//  TRUI
//
//  Created by Mac on 2020/4/27.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "NSMutableParagraphStyle+TRUI.h"

@implementation NSMutableParagraphStyle (TRUI)

+ (instancetype)trui_paragraphStyleWithLineHeight:(CGFloat)lineHeight
{
    return [self trui_paragraphStyleWithLineHeight:lineHeight lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft];
}

+ (instancetype)trui_paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    return [self trui_paragraphStyleWithLineHeight:lineHeight lineBreakMode:lineBreakMode textAlignment:NSTextAlignmentLeft];
}

+ (instancetype)trui_paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = lineHeight;
    style.maximumLineHeight = lineHeight;
    style.lineBreakMode = lineBreakMode;
    style.alignment = textAlignment;
    return style;
}

@end
