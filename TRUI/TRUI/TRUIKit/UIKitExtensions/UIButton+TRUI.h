//
//  UIButton+TRUI.h
//  TRUI
//
//  Created by Mac on 2020/4/28.
//  Copyright © 2020 Mac. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIButton (TRUI)

typedef NS_ENUM(NSUInteger, TRUICustomizeButtonPropType) {
    TRUICustomizeButtonPropTypeTitle,
    TRUICustomizeButtonPropTypeTitleColor,
    TRUICustomizeButtonPropTypeTitleShadowColor,
    TRUICustomizeButtonPropTypeImage,
    TRUICustomizeButtonPropTypeBackgroundImage,
    TRUICustomizeButtonPropTypeAttributedTitle
};

- (instancetype)trui_initWithImage:(UIImage *)image title:(NSString *)title;

/// 判断该button在特定 UIControlState 下是否设置了属性
/// @note 该方法会对设置了任何 TRUICustomizeButtonPropType 都返回YES
- (BOOL)trui_hasCustomizedButtonPropForState:(UIControlState)state;

/// 判断该 button 在特定 UIControlState 下是否设置了某个TRUICustomizeButtonPropType 属性
/// @param type 对应于 UIButton 的 setXXX:forState 办法
- (BOOL)trui_hasCustomizedButtonPropWithType:(TRUICustomizeButtonPropType)type forState:(UIControlState)state;

/// 在UIButton的样式（如字体）设置完成后，将button的text设置为一个测试字符，在调用sizeToFit，从而令button的高度适应字体
/// @warning 会调用<i>setText:forState:</i>,因此请确保在设置完按钮的样式之后、设置text之前调用
- (void)trui_calculateHeightAfterSetAppearance;

/// 通过这个方法设置了 attributes 之后，setTitle:forState:会自动把文字转成 attributedString 再添加上去，无需每次都自己构造 attributedString
/// @note 即使先调用 setTitle:forState: 然后再调用这个方法，之前的 title 仍然会被应用上这些 attributes
/// @note 该方法和 setTitleColor:forState: 均可设置字体颜色，如果二者冲突，则代码顺序较后的方法定义的颜色会最终生效
/// @note 如果包含了 NSKernAttributeName ，则此方法会自动帮你去掉最后一个字的 kern 效果，否则容易导致文字整体在视觉上不居中
- (void)trui_setTitleAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes forState:(UIControlState)state;

@end

