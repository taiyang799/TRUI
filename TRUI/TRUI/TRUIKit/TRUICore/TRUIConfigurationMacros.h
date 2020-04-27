//
//  TRUIConfigurationMacros.h
//  TRUI
//
//  Created by Mac on 2020/4/26.
//  Copyright © 2020 Mac. All rights reserved.
//

#ifndef TRUIConfigurationMacros_h
#define TRUIConfigurationMacros_h

/**
 提供一系列方便书写的宏，以便在代码里读取配置表的各种属性。
 @warning 请不要在+load方法里调用TRUIConfigurationTemplate 或 TRUIConfigurationMacros提供的宏，那个时机太早，可能导致crash
 @warning 维护时，如果需要增加一个宏，则需要定义一个新的TRUIConfiguration属性
 */

///单例的宏
#define TRUICMI ({[[TRUIConfiguration sharedInstance] applyInitialTemplate];[TRUIConfiguration sharedInstance];})

/// 标志当前项目是否正使用配置表功能
#define TRUICMIActivated            [TRUICMI active]

#pragma mark - Global Color

// 基础颜色
#define UIColorClear                [TRUICMI clearColor]
#define UIColorWhite                [TRUICMI whiteColor]
#define UIColorBlack                [TRUICMI blackColor]
#define UIColorGray                 [TRUICMI grayColor]
#define UIColorGrayDarken           [TRUICMI grayDarkenColor]
#define UIColorGrayLighten          [TRUICMI grayLightenColor]
#define UIColorRed                  [TRUICMI redColor]
#define UIColorGreen                [TRUICMI greenColor]
#define UIColorBlue                 [TRUICMI blueColor]
#define UIColorYellow               [TRUICMI yellowColor]

// 功能颜色
#define UIColorLink                 [TRUICMI linkColor]                       // 全局统一文字链接颜色
#define UIColorDisabled             [TRUICMI disabledColor]                   // 全局统一文字disabled颜色
#define UIColorForBackground        [TRUICMI backgroundColor]                 // 全局统一的背景色
#define UIColorMask                 [TRUICMI maskDarkColor]                   // 全局统一的mask背景色
#define UIColorMaskWhite            [TRUICMI maskLightColor]                  // 全局统一的mask背景色，白色
#define UIColorSeparator            [TRUICMI separatorColor]                  // 全局分隔线颜色
#define UIColorSeparatorDashed      [TRUICMI separatorDashedColor]            // 全局分隔线颜色（虚线）
#define UIColorPlaceholder          [TRUICMI placeholderColor]                // 全局的输入框的placeholder颜色

// 测试用的颜色
#define UIColorTestRed              [TRUICMI testColorRed]
#define UIColorTestGreen            [TRUICMI testColorGreen]
#define UIColorTestBlue             [TRUICMI testColorBlue]

// 可操作的控件
#pragma mark - UIControl

#define UIControlHighlightedAlpha  [TRUICMI controlHighlightedAlpha]          // 一般control的Highlighted透明值
#define UIControlDisabledAlpha     [TRUICMI controlDisabledAlpha]             // 一般control的Disable透明值

// 按钮
#pragma mark - UIButton
#define ButtonHighlightedAlpha          [TRUICMI buttonHighlightedAlpha]           // 按钮Highlighted状态的透明度
#define ButtonDisabledAlpha             [TRUICMI buttonDisabledAlpha]              // 按钮Disabled状态的透明度
#define ButtonTintColor                 [TRUICMI buttonTintColor]                  // 普通按钮的颜色

#define GhostButtonColorBlue            [TRUICMI ghostButtonColorBlue]              // TRUIGhostButtonColorBlue的颜色
#define GhostButtonColorRed             [TRUICMI ghostButtonColorRed]               // TRUIGhostButtonColorRed的颜色
#define GhostButtonColorGreen           [TRUICMI ghostButtonColorGreen]             // TRUIGhostButtonColorGreen的颜色
#define GhostButtonColorGray            [TRUICMI ghostButtonColorGray]              // TRUIGhostButtonColorGray的颜色
#define GhostButtonColorWhite           [TRUICMI ghostButtonColorWhite]             // TRUIGhostButtonColorWhite的颜色

#define FillButtonColorBlue             [TRUICMI fillButtonColorBlue]              // TRUIFillButtonColorBlue的颜色
#define FillButtonColorRed              [TRUICMI fillButtonColorRed]               // TRUIFillButtonColorRed的颜色
#define FillButtonColorGreen            [TRUICMI fillButtonColorGreen]             // TRUIFillButtonColorGreen的颜色
#define FillButtonColorGray             [TRUICMI fillButtonColorGray]              // TRUIFillButtonColorGray的颜色
#define FillButtonColorWhite            [TRUICMI fillButtonColorWhite]             // TRUIFillButtonColorWhite的颜色

#pragma mark - TextInput
#define TextFieldTextColor              [TRUICMI textFieldTextColor]               // TRUITextField、TRUITextView 的文字颜色
#define TextFieldTintColor              [TRUICMI textFieldTintColor]               // TRUITextField、TRUITextView 的tintColor
#define TextFieldTextInsets             [TRUICMI textFieldTextInsets]              // TRUITextField 的内边距
#define KeyboardAppearance              [TRUICMI keyboardAppearance]

#pragma mark - UISwitch
#define SwitchOnTintColor               [TRUICMI switchOnTintColor]                 // UISwitch 打开时的背景色（除了圆点外的其他颜色）
#define SwitchOffTintColor              [TRUICMI switchOffTintColor]                // UISwitch 关闭时的背景色（除了圆点外的其他颜色）
#define SwitchTintColor                 [TRUICMI switchTintColor]                   // UISwitch 关闭时的周围边框颜色
#define SwitchThumbTintColor            [TRUICMI switchThumbTintColor]              // UISwitch 中间的操控圆点的颜色

#pragma mark - NavigationBar

#define NavBarHighlightedAlpha                          [TRUICMI navBarHighlightedAlpha]
#define NavBarDisabledAlpha                             [TRUICMI navBarDisabledAlpha]
#define NavBarButtonFont                                [TRUICMI navBarButtonFont]
#define NavBarButtonFontBold                            [TRUICMI navBarButtonFontBold]
#define NavBarBackgroundImage                           [TRUICMI navBarBackgroundImage]
#define NavBarShadowImage                               [TRUICMI navBarShadowImage]
#define NavBarShadowImageColor                          [TRUICMI navBarShadowImageColor]
#define NavBarBarTintColor                              [TRUICMI navBarBarTintColor]
#define NavBarStyle                                     [TRUICMI navBarStyle]
#define NavBarTintColor                                 [TRUICMI navBarTintColor]
#define NavBarTitleColor                                [TRUICMI navBarTitleColor]
#define NavBarTitleFont                                 [TRUICMI navBarTitleFont]
#define NavBarLargeTitleColor                           [TRUICMI navBarLargeTitleColor]
#define NavBarLargeTitleFont                            [TRUICMI navBarLargeTitleFont]
#define NavBarBarBackButtonTitlePositionAdjustment      [TRUICMI navBarBackButtonTitlePositionAdjustment]
#define NavBarBackIndicatorImage                        [TRUICMI navBarBackIndicatorImage]
#define SizeNavBarBackIndicatorImageAutomatically       [TRUICMI sizeNavBarBackIndicatorImageAutomatically]
#define NavBarCloseButtonImage                          [TRUICMI navBarCloseButtonImage]

#define NavBarLoadingMarginRight                        [TRUICMI navBarLoadingMarginRight]                          // titleView里左边的loading的右边距
#define NavBarAccessoryViewMarginLeft                   [TRUICMI navBarAccessoryViewMarginLeft]                     // titleView里的accessoryView的左边距
#define NavBarActivityIndicatorViewStyle                [TRUICMI navBarActivityIndicatorViewStyle]                  // titleView loading 的style
#define NavBarAccessoryViewTypeDisclosureIndicatorImage [TRUICMI navBarAccessoryViewTypeDisclosureIndicatorImage]   // titleView上倒三角的默认图片

#pragma mark - TabBar

#define TabBarBackgroundImage                           [TRUICMI tabBarBackgroundImage]
#define TabBarBarTintColor                              [TRUICMI tabBarBarTintColor]
#define TabBarShadowImageColor                          [TRUICMI tabBarShadowImageColor]
#define TabBarStyle                                     [TRUICMI tabBarStyle]
#define TabBarItemTitleFont                             [TRUICMI tabBarItemTitleFont]
#define TabBarItemTitleColor                            [TRUICMI tabBarItemTitleColor]
#define TabBarItemTitleColorSelected                    [TRUICMI tabBarItemTitleColorSelected]
#define TabBarItemImageColor                            [TRUICMI tabBarItemImageColor]
#define TabBarItemImageColorSelected                    [TRUICMI tabBarItemImageColorSelected]

#pragma mark - Toolbar

#define ToolBarHighlightedAlpha                         [TRUICMI toolBarHighlightedAlpha]
#define ToolBarDisabledAlpha                            [TRUICMI toolBarDisabledAlpha]
#define ToolBarTintColor                                [TRUICMI toolBarTintColor]
#define ToolBarTintColorHighlighted                     [TRUICMI toolBarTintColorHighlighted]
#define ToolBarTintColorDisabled                        [TRUICMI toolBarTintColorDisabled]
#define ToolBarBackgroundImage                          [TRUICMI toolBarBackgroundImage]
#define ToolBarBarTintColor                             [TRUICMI toolBarBarTintColor]
#define ToolBarShadowImageColor                         [TRUICMI toolBarShadowImageColor]
#define ToolBarStyle                                    [TRUICMI toolBarStyle]
#define ToolBarButtonFont                               [TRUICMI toolBarButtonFont]


#pragma mark - SearchBar

#define SearchBarTextFieldBorderColor                   [TRUICMI searchBarTextFieldBorderColor]
#define SearchBarTextFieldBackgroundImage               [TRUICMI searchBarTextFieldBackgroundImage]
#define SearchBarBackgroundImage                        [TRUICMI searchBarBackgroundImage]
#define SearchBarTintColor                              [TRUICMI searchBarTintColor]
#define SearchBarTextColor                              [TRUICMI searchBarTextColor]
#define SearchBarPlaceholderColor                       [TRUICMI searchBarPlaceholderColor]
#define SearchBarFont                                   [TRUICMI searchBarFont]
#define SearchBarSearchIconImage                        [TRUICMI searchBarSearchIconImage]
#define SearchBarClearIconImage                         [TRUICMI searchBarClearIconImage]
#define SearchBarTextFieldCornerRadius                  [TRUICMI searchBarTextFieldCornerRadius]

#pragma mark - TableView / TableViewCell

#define TableViewEstimatedHeightEnabled                 [TRUICMI tableViewEstimatedHeightEnabled]            // 是否要开启全局 UITableView 的 estimatedRow(Section/Footer)Height

#define TableViewBackgroundColor                        [TRUICMI tableViewBackgroundColor]                   // 普通列表的背景色
#define TableSectionIndexColor                          [TRUICMI tableSectionIndexColor]                     // 列表右边索引条的文字颜色
#define TableSectionIndexBackgroundColor                [TRUICMI tableSectionIndexBackgroundColor]           // 列表右边索引条的背景色
#define TableSectionIndexTrackingBackgroundColor        [TRUICMI tableSectionIndexTrackingBackgroundColor]   // 列表右边索引条按下时的背景色
#define TableViewSeparatorColor                         [TRUICMI tableViewSeparatorColor]                    // 列表分隔线颜色
#define TableViewCellBackgroundColor                    [TRUICMI tableViewCellBackgroundColor]               // 列表 cell 的背景色
#define TableViewCellSelectedBackgroundColor            [TRUICMI tableViewCellSelectedBackgroundColor]       // 列表 cell 按下时的背景色
#define TableViewCellWarningBackgroundColor             [TRUICMI tableViewCellWarningBackgroundColor]        // 列表 cell 在提醒状态下的背景色
#define TableViewCellNormalHeight                       [TRUICMI tableViewCellNormalHeight]                  // TRUITableView 的默认 cell 高度

#define TableViewCellDisclosureIndicatorImage           [TRUICMI tableViewCellDisclosureIndicatorImage]      // 列表 cell 右边的箭头图片
#define TableViewCellCheckmarkImage                     [TRUICMI tableViewCellCheckmarkImage]                // 列表 cell 右边的打钩checkmark
#define TableViewCellDetailButtonImage                  [TRUICMI tableViewCellDetailButtonImage]             // 列表 cell 右边的 i 按钮
#define TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator [TRUICMI tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator]   // 列表 cell 右边的 i 按钮和向右箭头之间的间距（仅当两者都使用了自定义图片并且同时显示时才生效）

#define TableViewSectionHeaderBackgroundColor           [TRUICMI tableViewSectionHeaderBackgroundColor]
#define TableViewSectionFooterBackgroundColor           [TRUICMI tableViewSectionFooterBackgroundColor]
#define TableViewSectionHeaderFont                      [TRUICMI tableViewSectionHeaderFont]
#define TableViewSectionFooterFont                      [TRUICMI tableViewSectionFooterFont]
#define TableViewSectionHeaderTextColor                 [TRUICMI tableViewSectionHeaderTextColor]
#define TableViewSectionFooterTextColor                 [TRUICMI tableViewSectionFooterTextColor]
#define TableViewSectionHeaderAccessoryMargins          [TRUICMI tableViewSectionHeaderAccessoryMargins]
#define TableViewSectionFooterAccessoryMargins          [TRUICMI tableViewSectionFooterAccessoryMargins]
#define TableViewSectionHeaderContentInset              [TRUICMI tableViewSectionHeaderContentInset]
#define TableViewSectionFooterContentInset              [TRUICMI tableViewSectionFooterContentInset]

#define TableViewGroupedBackgroundColor                 [TRUICMI tableViewGroupedBackgroundColor]               // Grouped 类型的 TRUITableView 的背景色
#define TableViewGroupedCellTitleLabelColor             [TRUICMI tableViewGroupedCellTitleLabelColor]           // Grouped 类型的列表的 TRUITableViewCell 的标题颜色
#define TableViewGroupedCellDetailLabelColor            [TRUICMI tableViewGroupedCellDetailLabelColor]          // Grouped 类型的列表的 TRUITableViewCell 的副标题颜色
#define TableViewGroupedCellBackgroundColor             [TRUICMI tableViewGroupedCellBackgroundColor]           // Grouped 类型的列表的 TRUITableViewCell 的背景色
#define TableViewGroupedCellSelectedBackgroundColor     [TRUICMI tableViewGroupedCellSelectedBackgroundColor]   // Grouped 类型的列表的 TRUITableViewCell 点击时的背景色
#define TableViewGroupedCellWarningBackgroundColor      [TRUICMI tableViewGroupedCellWarningBackgroundColor]    // Grouped 类型的列表的 TRUITableViewCell 在提醒状态下的背景色
#define TableViewGroupedSectionHeaderFont               [TRUICMI tableViewGroupedSectionHeaderFont]
#define TableViewGroupedSectionFooterFont               [TRUICMI tableViewGroupedSectionFooterFont]
#define TableViewGroupedSectionHeaderTextColor          [TRUICMI tableViewGroupedSectionHeaderTextColor]
#define TableViewGroupedSectionFooterTextColor          [TRUICMI tableViewGroupedSectionFooterTextColor]
#define TableViewGroupedSectionHeaderAccessoryMargins   [TRUICMI tableViewGroupedSectionHeaderAccessoryMargins]
#define TableViewGroupedSectionFooterAccessoryMargins   [TRUICMI tableViewGroupedSectionFooterAccessoryMargins]
#define TableViewGroupedSectionHeaderDefaultHeight      [TRUICMI tableViewGroupedSectionHeaderDefaultHeight]
#define TableViewGroupedSectionFooterDefaultHeight      [TRUICMI tableViewGroupedSectionFooterDefaultHeight]
#define TableViewGroupedSectionHeaderContentInset       [TRUICMI tableViewGroupedSectionHeaderContentInset]
#define TableViewGroupedSectionFooterContentInset       [TRUICMI tableViewGroupedSectionFooterContentInset]

#define TableViewCellTitleLabelColor                    [TRUICMI tableViewCellTitleLabelColor]               // cell的title颜色
#define TableViewCellDetailLabelColor                   [TRUICMI tableViewCellDetailLabelColor]              // cell的detailTitle颜色

#pragma mark - UIWindowLevel
#define UIWindowLevelTRUIAlertView                      [TRUICMI windowLevelTRUIAlertView]

#pragma mark - TRUILog
#define ShouldPrintDefaultLog                           [TRUICMI shouldPrintDefaultLog]
#define ShouldPrintInfoLog                              [TRUICMI shouldPrintInfoLog]
#define ShouldPrintWarnLog                              [TRUICMI shouldPrintWarnLog]

#pragma mark - TRUIBadge
#define BadgeBackgroundColor                            [TRUICMI badgeBackgroundColor]
#define BadgeTextColor                                  [TRUICMI badgeTextColor]
#define BadgeFont                                       [TRUICMI badgeFont]
#define BadgeContentEdgeInsets                          [TRUICMI badgeContentEdgeInsets]
#define BadgeCenterOffset                               [TRUICMI badgeCenterOffset]
#define BadgeCenterOffsetLandscape                      [TRUICMI badgeCenterOffsetLandscape]

#define UpdatesIndicatorColor                           [TRUICMI updatesIndicatorColor]
#define UpdatesIndicatorSize                            [TRUICMI updatesIndicatorSize]
#define UpdatesIndicatorCenterOffset                    [TRUICMI updatesIndicatorCenterOffset]
#define UpdatesIndicatorCenterOffsetLandscape           [TRUICMI updatesIndicatorCenterOffsetLandscape]

#pragma mark - Others

#define AutomaticCustomNavigationBarTransitionStyle [TRUICMI automaticCustomNavigationBarTransitionStyle] // 界面 push/pop 时是否要自动根据两个界面的 barTintColor/backgroundImage/shadowImage 的样式差异来决定是否使用自定义的导航栏效果
#define SupportedOrientationMask                        [TRUICMI supportedOrientationMask]          // 默认支持的横竖屏方向
#define AutomaticallyRotateDeviceOrientation            [TRUICMI automaticallyRotateDeviceOrientation]  // 是否在界面切换或 viewController.supportedOrientationMask 发生变化时自动旋转屏幕，默认为 NO
#define StatusbarStyleLightInitially                    [TRUICMI statusbarStyleLightInitially]      // 默认的状态栏内容是否使用白色，默认为 NO，在 iOS 13 下会自动根据是否 Dark Mode 而切换样式，iOS 12 及以前则为黑色
#define NeedsBackBarButtonItemTitle                     [TRUICMI needsBackBarButtonItemTitle]       // 全局是否需要返回按钮的title，不需要则只显示一个返回image
#define HidesBottomBarWhenPushedInitially               [TRUICMI hidesBottomBarWhenPushedInitially] // TRUICommonViewController.hidesBottomBarWhenPushed 的初始值，默认为 NO，以保持与系统默认值一致，但通常建议改为 YES，因为一般只有 tabBar 首页那几个界面要求为 NO
#define PreventConcurrentNavigationControllerTransitions [TRUICMI preventConcurrentNavigationControllerTransitions] // PreventConcurrentNavigationControllerTransitions : 自动保护 TRUINavigationController 在上一次 push/pop 尚未结束的时候就进行下一次 push/pop 的行为，避免产生 crash
#define NavigationBarHiddenInitially                    [TRUICMI navigationBarHiddenInitially]      // preferredNavigationBarHidden 的初始值，默认为NO
#define ShouldFixTabBarTransitionBugInIPhoneX           [TRUICMI shouldFixTabBarTransitionBugInIPhoneX] // 是否需要自动修复 iOS 11 下，iPhone X 的设备在 push 界面时，tabBar 会瞬间往上跳的 bug
#define ShouldFixTabBarButtonBugForAll                  [TRUICMI shouldFixTabBarButtonBugForAll] // 是否要对 iOS 12.1.2 及以后的版本也修复手势返回时 tabBarButton 布局错误的 bug(issue #410)，默认为 NO
#define ShouldFixTabBarSafeAreaInsetsBugForNotchedScreen [TRUICMI shouldFixTabBarSafeAreaInsetsBugForNotchedScreen] // 是否要对 iOS 11 及以后的版本修复全面屏设备下 pop 界面时 UIScrollView 的 inset 会跳动导致滚动位置受影响的 bug（issue #934），默认为 NO
#define ShouldPrintTRUIWarnLogToConsole                 [TRUICMI shouldPrintTRUIWarnLogToConsole] // 是否在出现 TRUILogWarn 时自动把这些 log 以 TRUIConsole 的方式显示到设备屏幕上
#define SendAnalyticsToTRUITeam                         [TRUICMI sendAnalyticsToTRUITeam] // 是否允许在 DEBUG 模式下上报 Bundle Identifier 和 Display Name 给 TRUI 统计用
#define DynamicPreferredValueForIPad                    [TRUICMI dynamicPreferredValueForIPad] // 当 iPad 处于 Slide Over 或 Split View 分屏模式下，宏 `PreferredValueForXXX` 是否把 iPad 视为某种屏幕宽度近似的 iPhone 来取值。
#define IgnoreKVCAccessProhibited                       [TRUICMI ignoreKVCAccessProhibited] // 是否全局忽略 iOS 13 对 KVC 访问 UIKit 私有属性的限制
#define AdjustScrollIndicatorInsetsByContentInsetAdjustment [TRUICMI adjustScrollIndicatorInsetsByContentInsetAdjustment] // 当将 UIScrollView.contentInsetAdjustmentBehavior 设为 UIScrollViewContentInsetAdjustmentNever 时，是否自动将 UIScrollView.automaticallyAdjustsScrollIndicatorInsets 设为 NO，以保证原本在 iOS 12 下的代码不用修改就能在 iOS 13 下正常控制滚动条的位置。

#endif /* TRUIConfigurationMacros_h */
