//
//  UIColor+TRUI.h
//  TRUI
//
//  Created by Mac on 2020/4/28.
//  Copyright © 2020 Mac. All rights reserved.
//
#import <UIKit/UIKit.h>

#define UIColorMakeWithHex(hex) [UIColor trui_colorWithHexString:hex]

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (TRUI)

/**
 *  使用HEX命名方式的颜色字符串生成一个UIColor对象
 *
 *  @param hexString 支持以 # 开头和不以 # 开头的 hex 字符串
 *      #RGB        例如#f0f，等同于#ffff00ff，RGBA(255, 0, 255, 1)
 *      #ARGB       例如#0f0f，等同于#00ff00ff，RGBA(255, 0, 255, 0)
 *      #RRGGBB     例如#ff00ff，等同于#ffff00ff，RGBA(255, 0, 255, 1)
 *      #AARRGGBB   例如#00ff00ff，等同于RGBA(255, 0, 255, 0)
 *
 * @return UIColor对象
 */
+ (nullable UIColor *)trui_colorWithHexString:(nullable NSString *)hexString;

/**
 *  将当前色值转换为hex字符串，通道排序是AARRGGBB（与Android保持一致）
 *  @return 色值对应的 hex 字符串，以 # 开头，例如 #00ff00ff
 */
- (NSString *)trui_hexString;

/**
 *  获取当前 UIColor 对象里的红色色值
 *
 *  @return 红色通道的色值，值范围为0.0-1.0
 */
- (CGFloat)trui_red;

/**
 *  获取当前 UIColor 对象里的绿色色值
 *
 *  @return 绿色通道的色值，值范围为0.0-1.0
 */
- (CGFloat)trui_green;

/**
 *  获取当前 UIColor 对象里的蓝色色值
 *
 *  @return 蓝色通道的色值，值范围为0.0-1.0
 */
- (CGFloat)trui_blue;

/**
 *  获取当前 UIColor 对象里的透明色值
 *
 *  @return 透明通道的色值，值范围为0.0-1.0
 */
- (CGFloat)trui_alpha;

/**
 *  获取当前 UIColor 对象里的 hue（色相），注意 hue 的值是一个角度，所以0和1（0°和360°）是等价的，用 return 值去做判断时要特别注意。
 */
- (CGFloat)trui_hue;

/**
 *  获取当前 UIColor 对象里的 saturation（饱和度）
 */
- (CGFloat)trui_saturation;

/**
 *  获取当前 UIColor 对象里的 brightness（亮度）
 */
- (CGFloat)trui_brightness;

/**
 *  将当前UIColor对象剥离掉alpha通道后得到的色值。相当于把当前颜色的半透明值强制设为1.0后返回
 *
 *  @return alpha通道为1.0，其他rgb通道与原UIColor对象一致的新UIColor对象
 */
- (nullable UIColor *)trui_colorWithoutAlpha;

/**
 *  计算当前color叠加了alpha之后放在指定颜色的背景上的色值
 */
- (UIColor *)trui_colorWithAlpha:(CGFloat)alpha backgroundColor:(nullable UIColor *)backgroundColor;

/**
 *  计算当前color叠加了alpha之后放在白色背景上的色值
 */
- (UIColor *)trui_colorWithAlphaAddedToWhite:(CGFloat)alpha;

/**
 *  将自身变化到某个目标颜色，可通过参数progress控制变化的程度，最终得到一个纯色
 *  @param toColor 目标颜色
 *  @param progress 变化程度，取值范围0.0f~1.0f
 */
- (UIColor *)trui_transitionToColor:(nullable UIColor *)toColor progress:(CGFloat)progress;

/**
 *  判断当前颜色是否为深色，可用于根据不同色调动态设置不同文字颜色的场景。
 *
 *  @return 若为深色则返回“YES”，浅色则返回“NO”
 */
- (BOOL)trui_colorIsDark;

/**
 *  @return 当前颜色的反色，不管传入的颜色属于什么 colorSpace，最终返回的反色都是 RGB
 */
- (UIColor *)trui_inverseColor;

/**
 *  判断当前颜色是否等于系统默认的 tintColor 颜色。
 *  背景：如果将一个 UIView.tintColor 设置为 nil，表示这个 view 的 tintColor 希望跟随 superview.tintColor 变化而变化，所以设置完再获取 view.tintColor，得到的并非 nil，而是 superview.tintColor 的值，而如果整棵 view 层级树里的 view 都没有设置自己的 tintColor，则会返回系统默认的 tintColor（也即 [UIColor trui_systemTintColor]），所以才提供这个方法用于代替判断 tintColor == nil 的作用。
 */
- (BOOL)trui_isSystemTintColor;

/**
 *  获取当前系统的默认 tintColor 色值
 */
+ (UIColor *)trui_systemTintColor;

/**
 *  计算两个颜色叠加之后的最终色（注意区分前景色后景色的顺序）<br/>
 */
+ (UIColor *)trui_colorWithBackendColor:(UIColor *)backendColor frontColor:(UIColor *)frontColor;

/**
 *  将颜色A变化到颜色B，可通过progress控制变化的程度
 *  @param fromColor 起始颜色
 *  @param toColor 目标颜色
 *  @param progress 变化程度，取值范围0.0f~1.0f
 */
+ (UIColor *)trui_colorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress;

/**
 *  产生一个随机色，大部分情况下用于测试
 */
+ (UIColor *)trui_randomColor;

@end

/// 将原本的 dynamic color 绑定到 CGColorRef 上的 key
extern NSString *const TRUICGColorOriginalColorBindKey;

@protocol TRUIDynamicColorProtocol <NSObject>

@required

/// 获取当前 color 的实际颜色（返回的颜色必定不是 dynamic color）
@property(nonatomic, strong, readonly) UIColor *trui_rawColor;

/// 标志当前 UIColor 对象是否为动态颜色（由 [UIColor trui_colorWithThemeProvider:] 创建的颜色，或者 iOS 13 下由 [UIColor colorWithDynamicProvider:]、[UIColor initWithDynamicProvider:] 创建的颜色）
@property(nonatomic, assign, readonly) BOOL trui_isDynamicColor;

/// 标志当前 UIColor 对象是否为 trUIThemeColor
@property(nonatomic, assign, readonly) BOOL trui_isTRUIDynamicColor;

@optional
/// 这方法其实是 iOS 13 新增的 UIDynamicColor 里的私有方法，只要任意 UIColor 的类实现这个方法并返回 YES，就能自动响应 iOS 13 下的 UIUserInterfaceStyle 的切换，这里在 protocol 里声明是为了方便 .m 里调用（否则会因为不存在的 selector 而无法编译）
@property(nonatomic, assign, readonly) BOOL _isDynamic;

@end

@interface UIColor (TRUI_DynamicColor) <TRUIDynamicColorProtocol>

@end

NS_ASSUME_NONNULL_END
