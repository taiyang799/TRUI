//
//  NSMutableParagraphStyle+TRUI.h
//  TRUI
//
//  Created by Mac on 2020/4/27.
//  Copyright © 2020 Mac. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>

@interface NSMutableParagraphStyle (TRUI)

/// 快速构建一个 NSMutableParagraphStyle，等同于`trui_paragraphStyleWithLineHeight:lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft`
/// @param lineHeight 行高
/// @return 一个NSMutableParagraphStyle对象
+ (instancetype)trui_paragraphStyleWithLineHeight:(CGFloat)lineHeight;

/// 快速构建一个 NSMutableParagraphStyle，等同于`trui_paragraphStyleWithLineHeight:lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft`
/// @param lineHeight 行高
/// @param lineBreakMode 换行模式
/// @return 一个NSMutableParagraphStyle对象
+ (instancetype)trui_paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode;

/// 快速创建一个NSMutableParagraphStyle
/// @param lineHeight 行高
/// @param lineBreakMode 换行模式
/// @param textAlignment 文本对齐方式
+ (instancetype)trui_paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment;

@end


