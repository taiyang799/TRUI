//
//  TRUIConfiguration.m
//  TRUI
//
//  Created by Mac on 2020/4/26.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "TRUIConfiguration.h"
#import "TRUICommonDefines.h"
#import <objc/runtime.h>
#import "TRUIRuntime.h"
#import "NSString+TRUI.h"
#import "TRUIKit.h"

// 在 iOS 8 - 11 上实际测量得到
const CGSize kUINavigationBarBackIndicatorImageSize = {13, 21};

@interface TRUIConfiguration ()

#ifdef IOS13_SDK_ALLOWED
@property (nonatomic, strong) UITabBarAppearance *tabBarAppearance API_AVAILABLE(ios(13.0));
@property (nonatomic, strong) UINavigationBarAppearance *navigationBarAppearance API_AVAILABLE(ios(13));
#endif

@end

@implementation UIViewController (TRUIConfiguration)

- (NSArray<UIViewController *> *)trui_existingViewControllersOfClass:(Class)class
{
    NSMutableSet *viewControllers = [NSMutableSet set];
    if (self.presentedViewController) {
        [viewControllers addObjectsFromArray:[self.presentedViewController trui_existingViewControllersOfClass:class]];
    }
    if ([self isKindOfClass:UINavigationController.class]) {
        [viewControllers addObjectsFromArray:[((UINavigationController *)self).visibleViewController trui_existingViewControllersOfClass:class]];
    }
    if ([self isKindOfClass:UITabBarController.class]) {
        [viewControllers addObjectsFromArray:[((UITabBarController *)self).selectedViewController trui_existingViewControllersOfClass:class]];
    }
    if ([self isKindOfClass:class]) {
        [viewControllers addObject:self];
    }
    return viewControllers.allObjects;
}

@end

@implementation TRUIConfiguration

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static TRUIConfiguration *sharedInstance;
    dispatch_once(&pred, ^{
        sharedInstance = [[TRUIConfiguration alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initDefaultConfiguration];
    }
    return self;
}

static BOOL TRUI_hasAppliedInitialTemplate;
- (void)applyInitialTemplate
{
    if (TRUI_hasAppliedInitialTemplate) {
        return;
    }
    // 自动寻找并应用模板
    Protocol *protocol = @protocol(TRUIConfigurationTemplateProtocol);
    classref_t *classesref = nil;
    Class *classes = nil;
    int numberOfClasses = trui_getProjectClassList(&classesref);
    if (numberOfClasses <= 0) {
        numberOfClasses = objc_getClassList(NULL, 0);
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numberOfClasses);
        objc_getClassList(classes, numberOfClasses);
    }
    for (NSInteger i = 0; i <numberOfClasses; i++) {
        Class class = classesref ? (__bridge Class)classesref[i] : classes[i];
        //这里containsString是考虑到Swift里的className由“项目前缀+class 名”组成，如果用 hasPrefix就无法判断了
        if ([NSStringFromClass(class) containsString:@"TRUIConfigurationTemplate"] && [class conformsToProtocol:protocol]) {
            if ([class instancesRespondToSelector:@selector(shouldApplyTemplateAutomatically)]) {
                id<TRUIConfigurationTemplateProtocol> template = [[class alloc] init];
                if ([template shouldApplyTemplateAutomatically]) {
                    TRUI_hasAppliedInitialTemplate = YES;
                    [template applyConfigurationTemplate];
                    _active = YES;//标志配置表已生效
                    // 只应用第一个 shouldApplyTemplateAutomatically 的主题
                    break;
                }
            }
        }
    }
    
    if (IS_DEBUG && self.sendAnalyticsToTRUITeam) {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue new] usingBlock:^(NSNotification * _Nonnull note) {
            //这里根据是否能成功获取到 classesref 来统计信息，以供后续确认对 classesref 为 nil的保护是否真的必要
            [self setSendAnalyticsWithQuery:classes?@"findByObjc=true" : nil];
        }];
    }
    
    if (classes) {
        free(classes);
    }
    TRUI_hasAppliedInitialTemplate = YES;
}

- (void)setSendAnalyticsWithQuery:(NSString *)query
{
    NSString *identifier = [NSBundle mainBundle].bundleIdentifier.trui_stringByEncodingUserInputQuery;
    NSString *displayName = ((NSString *)([NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"] ?:[NSBundle mainBundle].infoDictionary[@"CFBundleName"])).trui_stringByEncodingUserInputQuery;
    NSString *TRUIVersion = TRUI_VERSION.trui_stringByEncodingUserInputQuery;//如果不以 framework 方式引入 TRUI 的话，是无法通过 CFBundleShortVersionString 获取到TRUI 所在的 bundle的版本号的，所以这里改为用脚本生成的变量来获取
    NSString *queryString = [NSString stringWithFormat:@"appId=%@&appName=%@&version=%@&platform=iOS", identifier, displayName, TRUIVersion];
    if (query.length > 0) {
        queryString = [NSString stringWithFormat:@"%@&%@", queryString, query];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://truiteam.com/analytics/usageReport"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request] resume];
}

#pragma mark - Initialize default values
- (void)initDefaultConfiguration
{
    #pragma mark - Global Color
    
    self.clearColor = UIColorMakeWithRGBA(255, 255, 255, 0);
    self.whiteColor = UIColorMake(255, 255, 255);
    self.blackColor = UIColorMake(0, 0, 0);
    self.grayColor = UIColorMake(179, 179, 179);
    self.grayDarkenColor = UIColorMake(163, 163, 163);
    self.grayLightenColor = UIColorMake(198, 198, 198);
    self.redColor = UIColorMake(250, 58, 58);
    self.greenColor = UIColorMake(159, 214, 97);
    self.blueColor = UIColorMake(49, 189, 243);
    self.yellowColor = UIColorMake(255, 207, 71);

    self.linkColor = UIColorMake(56, 116, 171);
    self.disabledColor = self.grayColor;
    self.maskDarkColor = UIColorMakeWithRGBA(0, 0, 0, .35f);
    self.maskLightColor = UIColorMakeWithRGBA(255, 255, 255, .5f);
    self.separatorColor = UIColorMake(222, 224, 226);
    self.separatorDashedColor = UIColorMake(17, 17, 17);
    self.placeholderColor = UIColorMake(196, 200, 208);
    
    self.testColorRed = UIColorMakeWithRGBA(255, 0, 0, .3);
    self.testColorGreen = UIColorMakeWithRGBA(0, 255, 0, .3);
    self.testColorBlue = UIColorMakeWithRGBA(0, 0, 255, .3);
    
    #pragma mark - UIControl
    
    self.controlHighlightedAlpha = 0.5f;
    self.controlDisabledAlpha = 0.5f;
    
    #pragma mark - UIButton
    
    self.buttonHighlightedAlpha = self.controlHighlightedAlpha;
    self.buttonDisabledAlpha = self.controlDisabledAlpha;
    self.buttonTintColor = self.blueColor;
    
    self.ghostButtonColorBlue = self.blueColor;
    self.ghostButtonColorRed = self.redColor;
    self.ghostButtonColorGreen = self.greenColor;
    self.ghostButtonColorGray = self.grayColor;
    self.ghostButtonColorWhite = self.whiteColor;
    
    self.fillButtonColorBlue = self.blueColor;
    self.fillButtonColorRed = self.redColor;
    self.fillButtonColorGreen = self.greenColor;
    self.fillButtonColorGray = self.grayColor;
    self.fillButtonColorWhite = self.whiteColor;
    
    #pragma mark - UITextField & UITextView
    
    self.textFieldTextInsets = UIEdgeInsetsMake(0, 7, 0, 7);
    
    #pragma mark - NavigationBar
    
    self.navBarHighlightedAlpha = 0.2f;
    self.navBarDisabledAlpha = 0.2f;
    self.sizeNavBarBackIndicatorImageAutomatically = YES;
    self.navBarCloseButtonImage = [UIImage trui_imageWithShape:TRUIImageShapeNavClose size:CGSizeMake(16, 16) tintColor:self.navBarTintColor];
    
    self.navBarLoadingMarginRight = 3;
    self.navBarAccessoryViewMarginLeft = 5;
    self.navBarActivityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.navBarAccessoryViewTypeDisclosureIndicatorImage = [[UIImage trui_imageWithShape:TRUIImageShapeTriangle size:CGSizeMake(8, 5) tintColor:self.navBarTitleColor] trui_imageWithOrientation:UIImageOrientationDown];
    
    
    #pragma mark - Toolbar
    
    self.toolBarHighlightedAlpha = 0.4f;
    self.toolBarDisabledAlpha = 0.4f;
    
    #pragma mark - SearchBar
    
    self.searchBarPlaceholderColor = self.placeholderColor;
    self.searchBarTextFieldCornerRadius = 2.0;
    
    #pragma mark - TableView / TableViewCell
    
    self.tableViewEstimatedHeightEnabled = YES;
    
    self.tableViewSeparatorColor = self.separatorColor;
    
    self.tableViewCellNormalHeight = UITableViewAutomaticDimension;
    self.tableViewCellSelectedBackgroundColor = UIColorMake(238, 239, 241);
    self.tableViewCellWarningBackgroundColor = self.yellowColor;
    self.tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator = 12;
    
    self.tableViewSectionHeaderBackgroundColor = UIColorMake(244, 244, 244);
    self.tableViewSectionFooterBackgroundColor = UIColorMake(244, 244, 244);
    self.tableViewSectionHeaderFont = UIFontBoldMake(12);
    self.tableViewSectionFooterFont = UIFontBoldMake(12);
    self.tableViewSectionHeaderTextColor = self.grayDarkenColor;
    self.tableViewSectionFooterTextColor = self.grayColor;
    self.tableViewSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableViewSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
    self.tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
    
    self.tableViewGroupedSectionHeaderFont = UIFontMake(12);
    self.tableViewGroupedSectionFooterFont = UIFontMake(12);
    self.tableViewGroupedSectionHeaderTextColor = self.grayDarkenColor;
    self.tableViewGroupedSectionFooterTextColor = self.grayColor;
    self.tableViewGroupedSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableViewGroupedSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableViewGroupedSectionHeaderDefaultHeight = UITableViewAutomaticDimension;
    self.tableViewGroupedSectionFooterDefaultHeight = UITableViewAutomaticDimension;
    self.tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, 15, 8, 15);
    self.tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15);
    
    #pragma mark - UIWindowLevel
    self.windowLevelTRUIAlertView = UIWindowLevelAlert - 4.0;
    
    #pragma mark - TRUILog
    self.shouldPrintDefaultLog = YES;
    self.shouldPrintInfoLog = YES;
    self.shouldPrintWarnLog = YES;
    
    #pragma mark - Others
    
    self.supportedOrientationMask = UIInterfaceOrientationMaskAll;
    self.preventConcurrentNavigationControllerTransitions = YES;
    self.shouldPrintTRUIWarnLogToConsole = IS_DEBUG;
    self.sendAnalyticsToTRUITeam = YES;
}

- (void)setSwitchOnTintColor:(UIColor *)switchOnTintColor
{
    _switchOnTintColor = switchOnTintColor;
    [UISwitch appearance].onTintColor = switchOnTintColor;
}

- (void)setSwitchThumbTintColor:(UIColor *)switchThumbTintColor
{
    _switchThumbTintColor = switchThumbTintColor;
    [UISwitch appearance].thumbTintColor = switchThumbTintColor;
}

- (void)setNavBarButtonFont:(UIFont *)navBarButtonFont
{
    _navBarButtonFont = navBarButtonFont;
    UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]];
    NSDictionary<NSAttributedStringKey,id> *attributes = navBarButtonFont ? @{NSFontAttributeName: navBarButtonFont} : nil;
    [barButtonItemAppearance setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [barButtonItemAppearance setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    [barButtonItemAppearance setTitleTextAttributes:attributes forState:UIControlStateDisabled];
}

- (void)setNavBarTintColor:(UIColor *)navBarTintColor
{
    _navBarTintColor = navBarTintColor;
    // tintColor 并没有声明 UI_APPEARANCE_SELECTOR，所以暂不使用 appearance 的方式去修改（虽然 appearance 方式实测是生效的）
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.navigationBar.tintColor = _navBarTintColor;
    }];
}

- (void)setNavBarBarTintColor:(UIColor *)navBarBarTintColor
{
    _navBarBarTintColor = navBarBarTintColor;
    [UINavigationBar appearance].barTintColor = _navBarBarTintColor;
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.navigationBar.barTintColor = _navBarBarTintColor;
    }];
}

- (void)setNavBarShadowImage:(UIImage *)navBarShadowImage
{
    _navBarShadowImage = navBarShadowImage;
    [self configureNavBarShadowImage];
}

- (void)setNavBarShadowImageColor:(UIColor *)navBarShadowImageColor
{
    _navBarShadowImageColor = navBarShadowImageColor;
    [self configureNavBarShadowImage];
}

- (void)configureNavBarShadowImage
{
    UIImage *shadowImage = self.navBarShadowImage;
    if (shadowImage || self.navBarShadowImageColor) {
        if (shadowImage) {
            if (self.navBarShadowImageColor && shadowImage.renderingMode != UIImageRenderingModeAlwaysOriginal) {
                shadowImage = [shadowImage trui_imageWithTintColor:self.navBarShadowImageColor];
            }
        } else {
            shadowImage = [UIImage trui_imageWithColor:self.navBarShadowImageColor size:CGSizeMake(4, PixelOne) cornerRadius:0];
        }
        
        // 反向更新 NavBarShadowImage，以保证业务代码直接使用 NavBarShadowImage 宏能得到正确的图片
        _navBarShadowImage = shadowImage;
    }
    
    UINavigationBar.appearance.shadowImage = shadowImage;
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.navigationBar.shadowImage = shadowImage;
    }];
}

- (void)setNavBarStyle:(UIBarStyle)navBarStyle
{
    _navBarStyle = navBarStyle;
    [UINavigationBar appearance].barStyle = navBarStyle;
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.navigationBar.barStyle = navBarStyle;
    }];
}

- (void)setNavBarBackgroundImage:(UIImage *)navBarBackgroundImage
{
    _navBarBackgroundImage = navBarBackgroundImage;
    [[UINavigationBar appearance] setBackgroundImage:_navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        [navigationController.navigationBar setBackgroundImage:_navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    }];
}

- (void)setNavBarTitleFont:(UIFont *)navBarTitleFont
{
    _navBarTitleFont = navBarTitleFont;
    [self updateNavigationBarTitleAttributesIfNeeded];
}

- (void)setNavBarTitleColor:(UIColor *)navBarTitleColor
{
    _navBarTitleColor = navBarTitleColor;
    [self updateNavigationBarTitleAttributesIfNeeded];
}

- (void)updateNavigationBarTitleAttributesIfNeeded
{
    NSMutableDictionary<NSAttributedStringKey, id> *titleTextAttributes = [UINavigationBar appearance].titleTextAttributes.mutableCopy;
    if (!titleTextAttributes) {
        titleTextAttributes = [[NSMutableDictionary alloc] init];
    }
    if (self.navBarTitleFont) {
        titleTextAttributes[NSFontAttributeName] = self.navBarTitleFont;
    }
    if (self.navBarTitleColor) {
        titleTextAttributes[NSForegroundColorAttributeName] = self.navBarTitleColor;
    }
    [UINavigationBar appearance].titleTextAttributes = titleTextAttributes;
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.navigationBar.titleTextAttributes = titleTextAttributes;
    }];
}

- (void)setNavBarLargeTitleFont:(UIFont *)navBarLargeTitleFont
{
    _navBarLargeTitleFont = navBarLargeTitleFont;
    [self updateNavigationBarLargeTitleTextAttributesIfNeeded];
}

- (void)setNavBarLargeTitleColor:(UIColor *)navBarLargeTitleColor
{
    _navBarLargeTitleColor = navBarLargeTitleColor;
    [self updateNavigationBarLargeTitleTextAttributesIfNeeded];
}

- (void)updateNavigationBarLargeTitleTextAttributesIfNeeded
{
    if (@available(iOS 11, *)) {
        NSMutableDictionary<NSString *, id> *largeTitleTextAttributes = [[NSMutableDictionary alloc] init];
        if (self.navBarLargeTitleFont) {
            largeTitleTextAttributes[NSFontAttributeName] = self.navBarLargeTitleFont;
        }
        if (self.navBarLargeTitleColor) {
            largeTitleTextAttributes[NSForegroundColorAttributeName] = self.navBarLargeTitleColor;
        }
        [UINavigationBar appearance].largeTitleTextAttributes = largeTitleTextAttributes;
        [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
            navigationController.navigationBar.largeTitleTextAttributes = largeTitleTextAttributes;
        }];
    }
}

- (void)setSizeNavBarBackIndicatorImageAutomatically:(BOOL)sizeNavBarBackIndicatorImageAutomatically
{
    _sizeNavBarBackIndicatorImageAutomatically = sizeNavBarBackIndicatorImageAutomatically;
    if (sizeNavBarBackIndicatorImageAutomatically && self.navBarBackIndicatorImage && !CGSizeEqualToSize(self.navBarBackIndicatorImage.size, kUINavigationBarBackIndicatorImageSize)) {
        self.navBarBackIndicatorImage = self.navBarBackIndicatorImage;// 重新设置一次，以触发自动调整大小
    }
}

- (void)setNavBarBackIndicatorImage:(UIImage *)navBarBackIndicatorImage
{
    _navBarBackIndicatorImage = navBarBackIndicatorImage;
    
    // 返回按钮的图片frame是和系统默认的返回图片的大小一致的（13, 21），所以用自定义返回箭头时要保证图片大小与系统的箭头大小一样，否则无法对齐
    // Make sure custom back button image is the same size as the system's back button image, i.e. (13, 21), due to the same frame size they share.
    if (navBarBackIndicatorImage && self.sizeNavBarBackIndicatorImageAutomatically) {
        CGSize systemBackIndicatorImageSize = kUINavigationBarBackIndicatorImageSize;
        CGSize customBackIndicatorImageSize = _navBarBackIndicatorImage.size;
        if (!CGSizeEqualToSize(customBackIndicatorImageSize, systemBackIndicatorImageSize)) {
            CGFloat imageExtensionVerticalFloat = CGFloatGetCenter(systemBackIndicatorImageSize.height, customBackIndicatorImageSize.height);
            _navBarBackIndicatorImage = [[_navBarBackIndicatorImage trui_imageWithSpacingExtensionInsets:UIEdgeInsetsMake(imageExtensionVerticalFloat,
                                                                                                                          0,
                                                                                                                          imageExtensionVerticalFloat,
                                                                                                                          systemBackIndicatorImageSize.width - customBackIndicatorImageSize.width)] imageWithRenderingMode:_navBarBackIndicatorImage.renderingMode];
        }
    }
    
    UINavigationBar *navBarAppearance = [UINavigationBar appearance];
    navBarAppearance.backIndicatorImage = _navBarBackIndicatorImage;
    navBarAppearance.backIndicatorTransitionMaskImage = _navBarBackIndicatorImage;
    
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.navigationBar.backIndicatorImage = _navBarBackIndicatorImage;
        navigationController.navigationBar.backIndicatorTransitionMaskImage = _navBarBackIndicatorImage;
    }];
}

- (void)setNavBarBackButtonTitlePositionAdjustment:(UIOffset)navBarBackButtonTitlePositionAdjustment
{
    _navBarBackButtonTitlePositionAdjustment = navBarBackButtonTitlePositionAdjustment;
    
    UIBarButtonItem *backBarButtonItem = [UIBarButtonItem appearance];
    [backBarButtonItem setBackButtonTitlePositionAdjustment:_navBarBackButtonTitlePositionAdjustment forBarMetrics:UIBarMetricsDefault];
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
        [navigationController.navigationItem.backBarButtonItem setBackButtonTitlePositionAdjustment:_navBarBackButtonTitlePositionAdjustment forBarMetrics:UIBarMetricsDefault];
    }];
}

- (void)setToolBarTintColor:(UIColor *)toolBarTintColor
{
    _toolBarTintColor = toolBarTintColor;
    // tintColor 并没有声明 UI_APPEARANCE_SELECTOR，所以暂不使用 appearance 的方式去修改（虽然 appearance 方式实测是生效的）
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.toolbar.tintColor = _toolBarTintColor;
    }];
}

- (void)setToolBarStyle:(UIBarStyle)toolBarStyle
{
    _toolBarStyle = toolBarStyle;
    [UIToolbar appearance].barStyle = toolBarStyle;
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.toolbar.barStyle = toolBarStyle;
    }];
}

- (void)setToolBarBarTintColor:(UIColor *)toolBarBarTintColor
{
    _toolBarBarTintColor = toolBarBarTintColor;
    [UIToolbar appearance].barTintColor = _toolBarBarTintColor;
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.toolbar.barTintColor = _toolBarBarTintColor;
    }];
}

- (void)setToolBarBackgroundImage:(UIImage *)toolBarBackgroundImage
{
    _toolBarBackgroundImage = toolBarBackgroundImage;
    [[UIToolbar appearance] setBackgroundImage:_toolBarBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
        [navigationController.toolbar setBackgroundImage:_toolBarBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }];
}

- (void)setToolBarShadowImageColor:(UIColor *)toolBarShadowImageColor
{
    _toolBarShadowImageColor = toolBarShadowImageColor;
    UIImage *shadowImage = toolBarShadowImageColor ? [UIImage trui_imageWithColor:_toolBarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0] : nil;
    [[UIToolbar appearance] setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
        [navigationController.toolbar setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
    }];
}

#ifdef IOS13_SDK_ALLOWED
- (UITabBarAppearance *)tabBarAppearance
{
    if (!_tabBarAppearance) {
        _tabBarAppearance = [[UITabBarAppearance alloc] init];
        [_tabBarAppearance configureWithDefaultBackground];
    }
    return _tabBarAppearance;
}

- (void)updateTabBarAppearance
{
    if (@available(iOS 13.0, *)) {
        UITabBar.appearance.standardAppearance = self.tabBarAppearance;
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.standardAppearance = self.tabBarAppearance;
        }];
    }
}

- (UINavigationBarAppearance *)navigationBarAppearance
{
    if (!_navigationBarAppearance) {
        _navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
    }
    return _navigationBarAppearance;
}

- (void)updateNavigationBarAppearance
{
    if (@available(iOS 13.0, *)) {
        UINavigationBar.appearance.standardAppearance = self.navigationBarAppearance;
        [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
            navigationController.navigationBar.standardAppearance = self.navigationBarAppearance;
        }];
    }
}

#endif

- (void)setTabBarBarTintColor:(UIColor *)tabBarBarTintColor
{
    _tabBarBarTintColor = tabBarBarTintColor;
    
#ifdef IOS13_SDK_ALLOWED
    if (@available(iOS 13.0, *)) {
        self.tabBarAppearance.backgroundColor = tabBarBarTintColor;
        [self updateTabBarAppearance];
    } else {
#endif
        [UITabBar appearance].barTintColor = _tabBarBarTintColor;
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.barTintColor = _tabBarBarTintColor;
        }];
#ifdef IOS13_SDK_ALLOWED
    }
#endif
}

- (void)setTabBarStyle:(UIBarStyle)tabBarStyle
{
    _tabBarStyle = tabBarStyle;
#ifdef IOS13_SDK_ALLOWED
    if (@available(iOS 13.0, *)) {
        self.tabBarAppearance.backgroundEffect = [UIBlurEffect effectWithStyle:tabBarStyle == UIBarStyleDefault ? UIBlurEffectStyleSystemChromeMaterialLight : UIBlurEffectStyleSystemChromeMaterialDark];
        [self updateTabBarAppearance];
    } else {
#endif
        [UITabBar appearance].barStyle = tabBarStyle;
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.barStyle = tabBarStyle;
        }];
#ifdef IOS13_SDK_ALLOWED
    }
#endif
}

- (void)setTabBarBackgroundImage:(UIImage *)tabBarBackgroundImage
{
    _tabBarBackgroundImage = tabBarBackgroundImage;
    
#ifdef IOS13_SDK_ALLOWED
    if (@available(iOS 13.0, *)) {
        self.tabBarAppearance.backgroundImage = tabBarBackgroundImage;
        [self updateTabBarAppearance];
    } else {
#endif
        [UITabBar appearance].backgroundImage = tabBarBackgroundImage;
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.backgroundImage = tabBarBackgroundImage;
        }];
#ifdef IOS13_SDK_ALLOWED
    }
#endif
}

- (void)setTabBarShadowImageColor:(UIColor *)tabBarShadowImageColor
{
    _tabBarShadowImageColor = tabBarShadowImageColor;
    
#ifdef IOS13_SDK_ALLOWED
    if (@available(iOS 13.0, *)) {
        self.tabBarAppearance.shadowColor = tabBarShadowImageColor;
        [self updateTabBarAppearance];
    } else {
#endif
        UIImage *shadowImage = [UIImage trui_imageWithColor:_tabBarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0];
        [[UITabBar appearance] setShadowImage:shadowImage];
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.shadowImage = shadowImage;
        }];
#ifdef IOS13_SDK_ALLOWED
    }
#endif
}

- (void)setTabBarItemTitleFont:(UIFont *)tabBarItemTitleFont
{
    _tabBarItemTitleFont = tabBarItemTitleFont;
    
#ifdef IOS13_SDK_ALLOWED
    if (@available(iOS 13.0, *)) {
        [self.tabBarAppearance trui_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
            NSMutableDictionary<NSAttributedStringKey, id> *attributes = itemAppearance.normal.titleTextAttributes.mutableCopy;
            attributes[NSFontAttributeName] = tabBarItemTitleFont;
            itemAppearance.normal.titleTextAttributes = attributes.copy;
        }];
        [self updateTabBarAppearance];
    } else {
#endif
        NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[[UITabBarItem appearance] titleTextAttributesForState:UIControlStateNormal]];
        if (_tabBarItemTitleFont) {
            textAttributes[NSFontAttributeName] = _tabBarItemTitleFont;
        }
        [[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            [tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
            }];
        }];
#ifdef IOS13_SDK_ALLOWED
    }
#endif
}

- (void)setTabBarItemTitleColor:(UIColor *)tabBarItemTitleColor
{
    _tabBarItemTitleColor = tabBarItemTitleColor;
    
#ifdef IOS13_SDK_ALLOWED
    if (@available(iOS 13.0, *)) {
        [self.tabBarAppearance trui_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
            NSMutableDictionary<NSAttributedStringKey, id> *attributes = itemAppearance.normal.titleTextAttributes.mutableCopy;
            attributes[NSForegroundColorAttributeName] = tabBarItemTitleColor;
            itemAppearance.normal.titleTextAttributes = attributes.copy;
        }];
        [self updateTabBarAppearance];
    } else {
#endif
        NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[[UITabBarItem appearance] titleTextAttributesForState:UIControlStateNormal]];
        textAttributes[NSForegroundColorAttributeName] = _tabBarItemTitleColor;
        [[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            [tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
            }];
        }];
#ifdef IOS13_SDK_ALLOWED
    }
#endif
}

- (void)setTabBarItemTitleColorSelected:(UIColor *)tabBarItemTitleColorSelected
{
    _tabBarItemTitleColorSelected = tabBarItemTitleColorSelected;
    
#ifdef IOS13_SDK_ALLOWED
    if (@available(iOS 13.0, *)) {
        [self.tabBarAppearance trui_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
            NSMutableDictionary<NSAttributedStringKey, id> *attributes = itemAppearance.selected.titleTextAttributes.mutableCopy;
            attributes[NSForegroundColorAttributeName] = tabBarItemTitleColorSelected;
            itemAppearance.selected.titleTextAttributes = attributes.copy;
        }];
        [self updateTabBarAppearance];
    } else {
#endif
        NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[[UITabBarItem appearance] titleTextAttributesForState:UIControlStateSelected]];
        textAttributes[NSForegroundColorAttributeName] = _tabBarItemTitleColorSelected;
        [[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            [tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
            }];
        }];
#ifdef IOS13_SDK_ALLOWED
    }
#endif
}

- (void)setTabBarItemImageColor:(UIColor *)tabBarItemImageColor
{
    _tabBarItemImageColor = tabBarItemImageColor;
    
#ifdef IOS13_SDK_ALLOWED
    if (@available(iOS 13.0, *)) {
        [self.tabBarAppearance trui_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
            itemAppearance.normal.iconColor = tabBarItemImageColor;
        }];
        [self updateTabBarAppearance];
    } else {
#endif
    [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
        [tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            // 不需要过滤，否则选中时的那个 item 未选中时的图片无法被更新
//            if (item == tabBarController.tabBar.selectedItem) return;
            [item trui_updateTintColorForiOS12AndEarlier:tabBarItemImageColor];
        }];
    }];
#ifdef IOS13_SDK_ALLOWED
    }
#endif
}

- (void)setTabBarItemImageColorSelected:(UIColor *)tabBarItemImageColorSelected
{
    _tabBarItemImageColorSelected = tabBarItemImageColorSelected;
    
#ifdef IOS13_SDK_ALLOWED
    if (@available(iOS 13.0, *)) {
        [self.tabBarAppearance trui_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
            itemAppearance.selected.iconColor = tabBarItemImageColorSelected;
        }];
        [self updateTabBarAppearance];
    } else {
#endif
        // iOS 12 及以下使用 tintColor 实现，tintColor 并没有声明 UI_APPEARANCE_SELECTOR，所以暂不使用 appearance 的方式去修改（虽然 appearance 方式实测是生效的）
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.tintColor = tabBarItemImageColorSelected;
        }];
#ifdef IOS13_SDK_ALLOWED
    }
#endif
}

- (void)setStatusbarStyleLightInitially:(BOOL)statusbarStyleLightInitially {
    _statusbarStyleLightInitially = statusbarStyleLightInitially;
    [[trUIHelper visibleViewController] setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - Appearance Updating Views

// 解决某些场景下更新配置表无法覆盖样式的问题

- (NSArray <UITabBarController *>*)appearanceUpdatingTabBarControllers {
    return (NSArray <UITabBarController *>*)[self appearanceUpdatingViewControllersOfClass:UITabBarController.class];
}

- (NSArray <UINavigationController *>*)appearanceUpdatingNavigationControllers {
    return (NSArray <UINavigationController *>*)[self appearanceUpdatingViewControllersOfClass:UINavigationController.class];
}

- (NSArray <UIViewController *>*)appearanceUpdatingViewControllersOfClass:(Class)class {
    NSMutableArray *viewControllers = [NSMutableArray array];
    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        if (window.rootViewController) {
            [viewControllers addObjectsFromArray:[window.rootViewController trui_existingViewControllersOfClass:class]];
        }
    }];
    return viewControllers;
}

@end

const NSInteger TRUIImageOriginalRenderingModeDefault = -1;

@interface UIImage (TRUIConfiguration)

@property(nonatomic, assign) UIImageRenderingMode trui_originalRenderingMode;
@property(nonatomic, assign) BOOL qimgconf_hasSetOriginalRenderingMode;
@end

@implementation UITabBarItem (TRUIConfiguration)

// iOS 12 及以下的 UITabBarItem.image 有个问题是，如果不强制指定 original，系统总是会以 template 的方式渲染未选中时的图片，并且颜色也是系统默认的灰色，无法改变
// 为了让未选中时的图片颜色能跟随配置表变化，这里对 renderingMode 为非 Original 的图片会强制转换成配置表的颜色，并将 renderMode 修改为 AlwaysOriginal 以保证图片颜色不会被系统覆盖
- (void)trui_updateTintColorForiOS12AndEarlier:(UIColor *)tintColor {
    if (@available(iOS 13.0, *)) return;
    if (!tintColor) return;
    
    UIImage *image = self.image;
    UIImageRenderingMode renderingMode = image.renderingMode;
    UIImageRenderingMode originalRenderingMode = image.trui_originalRenderingMode;
    if (originalRenderingMode == TRUIImageOriginalRenderingModeDefault) {
        if (renderingMode != UIImageRenderingModeAlwaysOriginal) {
            image = [[image trui_imageWithTintColor:TabBarItemImageColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            image.trui_originalRenderingMode = renderingMode;
            self.image = image;
        }
    } else if (originalRenderingMode != UIImageRenderingModeAlwaysOriginal && renderingMode == UIImageRenderingModeAlwaysOriginal) {
        image = [[image trui_imageWithTintColor:TabBarItemImageColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image.trui_originalRenderingMode = originalRenderingMode;
        self.image = image;
    }
}

@end

@implementation UIImage (TRUIConfiguration)

TRUISynthesizeBOOLProperty(qimgconf_hasSetOriginalRenderingMode, setQimgconf_hasSetOriginalRenderingMode)

static char kAssociatedObjectKey_originalRenderingMode;
- (void)setTrui_originalRenderingMode:(UIImageRenderingMode)trui_originalRenderingMode {
    self.qimgconf_hasSetOriginalRenderingMode = YES;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_originalRenderingMode, @(trui_originalRenderingMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageRenderingMode)trui_originalRenderingMode {
    if (!self.qimgconf_hasSetOriginalRenderingMode) return TRUIImageOriginalRenderingModeDefault;
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_originalRenderingMode)) integerValue];
}

@end
