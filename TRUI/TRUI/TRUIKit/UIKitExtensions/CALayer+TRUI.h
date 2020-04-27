//
//  CALayer+TRUI.h
//  TRUI
//
//  Created by Mac on 2020/4/26.
//  Copyright © 2020 Mac. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_OPTIONS(NSUInteger, TRUICornerMask) {
    TRUILayerMinXMinYCorner = 1U << 0,
    TRUILayerMaxXMinYCorner = 1U << 1,
    TRUILayerMinXMaxYCorner = 1U << 2,
    TRUILayerMaxXMaxYCorner = 1U << 3,
};

@interface CALayer (TRUI)

/// 是否为某个UIView自带的layer
@property (nonatomic, assign, readonly) BOOL trui_isRootLayerOfView;

/// 暂停/恢复当前layer上的所有动画
@property (nonatomic, assign) BOOL trui_pause;

/// 设置四个角是否支持圆角的，iOS11及以上会调用系统的接口，否则TRUI额外实现
/// @warning 如果对应的layer有圆角，则请使用TRUI_Border，否则系统的border会被clip掉
/// @warning 使用trui方法，则超出layer范围内的内容都会被clip掉，系统的则不会
/// @warning 如果使用这个接口设置圆角，那么需要获取圆角的值需要用trui_originCornerRadius,否则iOS11以下获取到的都是0
@property (nonatomic, assign) TRUICornerMask trui_maskedCorners;

/// iOS11以下layer自身的cornerRadius一直都是0，圆角的是通过mask做的，trui_originCornerRadius保存了当前的圆角
@property (nonatomic, assign, readonly) CGFloat trui_originCornerRadius;

/// 把某个sublayer移动到当前所有sublayers的最后边
/// @param sublayer 要被移动的layer
/// @warning 要被移动的sublayer必须已经添加到当前layer上
- (void)trui_sendSublayerToBack:(CALayer *)sublayer;

/// 把某个 sublayer 移动到当前所有 sublayers 的最前面
/// @param sublayer 要被移动的layer
/// @warning 要被移动的 sublayer 必须已经添加到当前 layer 上
- (void)trui_bringSublayerToFront:(CALayer *)sublayer;

/// 移除 CALayer（包括 CAShapeLayer 和 CAGradientLayer）所有支持动画的属性的默认动画，方便需要一个不带动画的 layer 时使用。
- (void)trui_removeDefaultAnimations;

/// 对 CALayer 执行一些操作，不以动画的形式展示过程（默认情况下修改 CALayer 的属性都会以动画形式展示出来）。
/// @param actionsWithoutAnimation 要执行的操作，可以在里面修改 layer 的属性，例如 frame、backgroundColor 等。
/// @note 如果该 layer 的任何属性修改都不需要动画，也可使用 trui_removeDefaultAnimations。
+ (void)trui_performWithoutAnimation:(void (NS_NOESCAPE ^)(void))actionsWithoutAnimation;

/// 生成虚线的方法，注意返回的是CAShapeLayer
/// @param lineLength 每一段的线宽
/// @param lineSpacing 线之间的间隔
/// @param lineWidth 线的宽度
/// @param lineColor 线的颜色
/// @param isHorizontal 是否横向，因为画虚线的缘故，需要指定横向或纵向，横向是YES，纵向是NO。
/// @note 注意：暂不支持dashPhase和dashPattens数组设置，因为这些都定制性太强，如果用到则自己调用系统方法即可。
+ (CAShapeLayer *)qmui_separatorDashLayerWithLineLength:(NSInteger)lineLength
                                            lineSpacing:(NSInteger)lineSpacing
                                              lineWidth:(CGFloat)lineWidth
                                              lineColor:(CGColorRef)lineColor
                                           isHorizontal:(BOOL)isHorizontal;

/// 产生一个通用分隔虚线的 layer，高度为 PixelOne，线宽为 2，线距为 2，默认会移除动画，并且背景色用UIColorSeparator，注意返回的是 CAShapeLayer。其中，InHorizon 是横向；InVertical 是纵向。
+ (CAShapeLayer *)trui_separatorDashLayerInHorizontal;
+ (CAShapeLayer *)trui_separatorDashLayerInVertical;

/// 产生一个适用于做通用分隔线的 layer，高度为 PixelOne，默认会移除动画，并且背景色用 UIColorSeparator
+ (CALayer *)trui_separatorLayer;

/// 产生一个适用于做列表分隔线的 layer，高度为 PixelOne，默认会移除动画，并且背景色用 TableViewSeparatorColor
+ (CALayer *)trui_separatorLayerForTableView;

@end

@interface CALayer (TRUI_DynamicColor)

/// 如果 layer 的 backgroundColor、borderColor、shadowColor 是使用 dynamic color（UIDynamicProviderColor、TRUIThemeColor 等）生成的，则调用这个方法可以重新设置一遍这些属性，从而更新颜色
/// iOS 13 系统设置里的界面样式变化（Dark Mode），以及 TRUIThemeManager 触发的主题变化，都会自动调用 layer 的这个方法，业务无需关心。
- (void)trui_setNeedsUpdateDynamicStyle NS_REQUIRES_SUPER;

@end

