//
//  NSAttributedString+TRUI.h
//  TRUI
//
//  Created by Mac on 2020/4/27.
//  Copyright © 2020 Mac. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString (TRUI)

/// 按照中文2个字符、英文1个字符的方式来计算文本长度
- (NSUInteger)trui_lengthWhenCountingNonASCIICharacterAsTwo;

/// 创建一个包含图片的 attributedString
/// @param image 要用的图片
+ (instancetype)trui_attributedStringWithImage:(UIImage *)image;

/// 创建一个包含图片的 attributedString
/// @param image 要用的图片
/// @param offset 图片相对基线的垂直偏移（当offset>0时，图片会向上偏移）
/// @param leftMargin 图片距离左侧内容的间距
/// @param rightMargin 图片距离右侧内容的间距
/// @note leftMargin和rightMargin 必须大于或等于0
+ (instancetype)trui_attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)offset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;

/// 创建一个用来占位的空白 attributeString
/// @param width 空白占位符的宽度
+ (instancetype)trui_attributedStringWithFixedSpace:(CGFloat)width;

@end

@interface NSMutableAttributedString (TRUI)

@end

