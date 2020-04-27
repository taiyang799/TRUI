//
//  CALayer+TRUI.m
//  TRUI
//
//  Created by Mac on 2020/4/26.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "CALayer+TRUI.h"
#import "TRUILab.h"
#import "TRUIRuntime.h"
#import "TRUICommonDefines.h"
#import "TRUIConfigurationMacros.h"

@interface CALayer ()

@property (nonatomic, assign) float trui_speedBeforePause;

@end

@implementation CALayer (TRUI)

TRUISynthesizeFloatProperty(trui_speedBeforePause, setTrui_speedBeforePause)
TRUISynthesizeCGFloatProperty(trui_originCornerRadius, setTrui_originCornerRadius)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //由于其他方法需要通过调用 truilayer_setCornerRadius: 来执行 swizzle 前的实现，所以这里暂时用ExchangeImplementations
        ExchangeImplementations([CALayer class], @selector(setCornerRadius:), @selector(truilayer_setCornerRadius:));
        ExtendImplementationOfNonVoidMethodWithoutArguments([CALayer class], @selector(init), CALayer *, ^CALayer *(CALayer *selfObject, CALayer *originReturnValue){
            selfObject.trui_speedBeforePause = selfObject.speed;
            selfObject.trui_maskedCorners = TRUILayerMinXMinYCorner|TRUILayerMaxXMinYCorner|TRUILayerMinXMaxYCorner|TRUILayerMaxXMaxYCorner;
            return originReturnValue;
        });
        
        OverrideImplementation([CALayer class], @selector(setBounds:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGRect bounds){
                //对非法的 bounds，Debug 下中 assert，Release 下会将其中的 NaN改为 0，避免 crash
                if (CGRectIsNaN(bounds)) {
                    TRUILogWarn(@"CALayer (TRUI)", @"%@ setBounds:%@，参数包含 NaN，已被拦截并处理为0。%@", selfObject, NSStringFromCGRect(bounds), [NSThread callStackSymbols]);
                    if (TRUICMIActivated && !ShouldPrintTRUIWarnLogToConsole) {
                        NSAssert(NO, @"CALayer setBounds: 出现 NaN");
                    }
                    if (!IS_DEBUG) {
                        bounds = CGRectSafeValue(bounds);
                    }
                }
                
                //call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void(*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, bounds);
            };
        });
        
        OverrideImplementation([CALayer class], @selector(setPosition:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGPoint position){
                // 对非法的 position，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
                if (isnan(position.x) || isnan(position.y)) {
                    TRUILogWarn(@"CALayer (TRUI)", @"%@ setPosition:%@，参数包含 NaN，已被拦截并处理为 0。%@", selfObject, NSStringFromCGPoint(position), [NSThread callStackSymbols]);
                    if (TTUICMIActivated && !ShouldPrintTRUIWarnLogToConsole) {
                        NSAssert(NO, @"CALayer setPosition: 出现 NaN");
                    }
                    if (!IS_DEBUG) {
                        position = CGPointMake(CGFloatSafeValue(position.x), CGFloatSafeValue(position.y));
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGPoint);
                originSelectorIMP = (void (*)(id, SEL, CGPoint))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, position);
            };
        });
    });
}

- (BOOL)trui_isRootLayerOfView
{
    return [self.delegate isKindOfClass:[UIView class]] && ((UIView *)self.delegate).layer == self;
}

- (void)truilayer_setCornerRadius:(CGFloat)cornerRadius
{
    BOOL cornerRadiusChanged = flat(self.trui_originCornerRadius) != flat(cornerRadius);//flat处理，避免浮点精度问题
    self.trui_originCornerRadius = cornerRadius;
    if (@available(iOS 11, *)) {
        [self truilayer_setCornerRadius:cornerRadius];
    } else {
        if (self.trui_maskedCorners && ![self hasFourCornerRadius]) {
            [self truilayer_setCornerRadius:0];
        } else {
            [self truilayer_setCornerRadius:cornerRadius];
        }
        
        if (cornerRadiusChanged) {
            //需要刷新mask
            [self setNeedsLayout];
        }
    }
    
    if (cornerRadiusChanged) {
        //需要刷新border
        if (self.delegate && [self.delegate respondsToSelector:@selector(layoutSublayersOfLayer:)]) {
            UIView *view = (UIView *)self.delegate;
            if (view.trui_borderPosition > 0 && view.trui_borderWidth > 0) {
                [view layoutSublayersOfLayer:self];
            }
        }
    }
}

static char kAssociatedObjectKey_pause;
- (void)setTrui_pause:(BOOL)trui_pause
{
    if (trui_pause == self.trui_pause) {
        return;
    }
    if (trui_pause) {
        self.trui_speedBeforePause = self.speed;
        CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
        self.speed = 0;
        self.timeOffset = pausedTime;
    } else {
        CFTimeInterval pausedTime = self.timeOffset;
        self.speed = self.trui_speedBeforePause;
        self.timeOffset = 0;
        self.beginTime = 0;
        CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.beginTime = timeSincePause;
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_pause, @(trui_pause), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)trui_pause
{
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_pause)) boolValue];
}

static char kAssociatedObjectKey_maskedCorners;
- (void)setTrui_maskedCorners:(TRUICornerMask)trui_maskedCorners
{
    BOOL maskedCornersChanged = trui_maskedCorners != self.trui_maskedCorners;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_maskedCorners, @(trui_maskedCorners), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (@available(iOS 11, *)) {
        self.maskedCorners = (CACornerMask)trui_maskedCorners;
    } else {
        if (trui_maskedCorners && ![self hasFourCornerRadius]) {
            [self truilayer_setCornerRadius:0];
        }
        if (maskedCornersChanged) {
            // 需要刷新mask
            if ([NSThread isMainThread]) {
                [self setNeedsLayout];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setNeedsLayout];
                });
            }
        }
    }
    if (maskedCornersChanged) {
        // 需要刷新border
        if ([self.delegate respondsToSelector:@selector(layoutSublayersOfLayer:)]) {
            UIView *view = (UIView *)self.delegate;
            if (view.trui_borderPosition > 0 && view.trui_borderWidth > 0) {
                [view layoutSublayersOfLayer:self];
            }
        }
    }
}

- (TRUICornerMask)trui_maskedCorners
{
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_maskedCorners) unsignedIntegerValue];
}

- (void)trui_sendSublayerToBack:(CALayer *)sublayer
{
    if (sublayer.superlayer == self) {
        [sublayer removeFromSuperlayer];
        [self insertSublayer:sublayer atIndex:0];
    }
}

- (void)trui_bringSublayerToFront:(CALayer *)sublayer
{
    if (sublayer.superlayer == self) {
        [sublayer removeFromSuperlayer];
        [self insertSublayer:sublayer atIndex:(unsigned)self.sublayers.count];
    }
}

- (void)trui_removeDefaultAnimations
{
    NSMutableDictionary<NSString *, id<CAAction>> *actions = @{NSStringFromSelector(@selector(bounds)): [NSNull null],
          NSStringFromSelector(@selector(position)): [NSNull null],
          NSStringFromSelector(@selector(zPosition)): [NSNull null],
          NSStringFromSelector(@selector(anchorPoint)): [NSNull null],
          NSStringFromSelector(@selector(anchorPointZ)): [NSNull null],
          NSStringFromSelector(@selector(transform)): [NSNull null],
          BeginIgnoreClangWarning(-Wundeclared-selector)
          NSStringFromSelector(@selector(hidden)): [NSNull null],
          NSStringFromSelector(@selector(doubleSided)): [NSNull null],
          EndIgnoreClangWarning
          NSStringFromSelector(@selector(sublayerTransform)): [NSNull null],
          NSStringFromSelector(@selector(masksToBounds)): [NSNull null],
          NSStringFromSelector(@selector(contents)): [NSNull null],
          NSStringFromSelector(@selector(contentsRect)): [NSNull null],
          NSStringFromSelector(@selector(contentsScale)): [NSNull null],
          NSStringFromSelector(@selector(contentsCenter)): [NSNull null],
          NSStringFromSelector(@selector(minificationFilterBias)): [NSNull null],
          NSStringFromSelector(@selector(backgroundColor)): [NSNull null],
          NSStringFromSelector(@selector(cornerRadius)): [NSNull null],
          NSStringFromSelector(@selector(borderWidth)): [NSNull null],
          NSStringFromSelector(@selector(borderColor)): [NSNull null],
          NSStringFromSelector(@selector(opacity)): [NSNull null],
          NSStringFromSelector(@selector(compositingFilter)): [NSNull null],
          NSStringFromSelector(@selector(filters)): [NSNull null],
          NSStringFromSelector(@selector(backgroundFilters)): [NSNull null],
          NSStringFromSelector(@selector(shouldRasterize)): [NSNull null],
          NSStringFromSelector(@selector(rasterizationScale)): [NSNull null],
          NSStringFromSelector(@selector(shadowColor)): [NSNull null],
          NSStringFromSelector(@selector(shadowOpacity)): [NSNull null],
          NSStringFromSelector(@selector(shadowOffset)): [NSNull null],
          NSStringFromSelector(@selector(shadowRadius)): [NSNull null],
          NSStringFromSelector(@selector(shadowPath)): [NSNull null]}.mutableCopy;
    
    if ([self isKindOfClass:[CAShapeLayer class]]) {
        [actions addEntriesFromDictionary:@{
            NSStringFromSelector(@selector(path)): [NSNull null],
            NSStringFromSelector(@selector(fillColor)): [NSNull null],
            NSStringFromSelector(@selector(strokeColor)): [NSNull null],
            NSStringFromSelector(@selector(strokeStart)): [NSNull null],
            NSStringFromSelector(@selector(strokeEnd)): [NSNull null],
            NSStringFromSelector(@selector(lineWidth)): [NSNull null],
            NSStringFromSelector(@selector(miterLimit)): [NSNull null],
            NSStringFromSelector(@selector(lineDashPhase)): [NSNull null]}];
    }
    
    if ([self isKindOfClass:[CAGradientLayer class]]) {
        [actions addEntriesFromDictionary:@{
            NSStringFromSelector(@selector(colors)): [NSNull null],
            NSStringFromSelector(@selector(locations)): [NSNull null],
            NSStringFromSelector(@selector(startPoint)): [NSNull null],
            NSStringFromSelector(@selector(endPoint)): [NSNull null]}];
    }
    
    self.actions = actions;
}

+ (void)trui_performWithoutAnimation:(void (NS_NOESCAPE ^)(void))actionsWithoutAnimation
{
    if (!actionsWithoutAnimation) return;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    actionsWithoutAnimation();
    [CATransaction commit];
}

+ (CAShapeLayer *)trui_separatorDashLayerWithLineLength:(NSInteger)lineLength
                                            lineSpacing:(NSInteger)lineSpacing
                                              lineWidth:(CGFloat)lineWidth
                                              lineColor:(CGColorRef)lineColor
                                           isHorizontal:(BOOL)isHorizontal
{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = UIColorClear.CGColor;
    layer.strokeColor = lineColor;
    layer.lineWidth = lineWidth;
    layer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:lineLength], [NSNumber numberWithInteger:lineSpacing], nil];
    layer.masksToBounds = YES;
    
    CGMutablePathRef path = CGPathCreateMutable();
    if (isHorizontal) {
        CGPathMoveToPoint(path, NULL, 0, lineWidth / 2);
        CGPathAddLineToPoint(path, NULL, SCREEN_WIDTH, lineWidth / 2);
    } else {
        CGPathMoveToPoint(path, NULL, lineWidth / 2, 0);
        CGPathAddLineToPoint(path, NULL, lineWidth / 2, SCREEN_HEIGHT);
    }
    layer.path = path;
    CGPathRelease(path);
    
    return layer;
}

+ (CAShapeLayer *)trui_separatorDashLayerInHorizontal
{
    CAShapeLayer *layer = [CAShapeLayer trui_separatorDashLayerWithLineLength:2 lineSpacing:2 lineWidth:PixelOne lineColor:UIColorSeparatorDashed.CGColor isHorizontal:YES];
    return layer;
}

+ (CAShapeLayer *)trui_separatorDashLayerInVertical
{
    CAShapeLayer *layer = [CAShapeLayer trui_separatorDashLayerWithLineLength:2 lineSpacing:2 lineWidth:PixelOne lineColor:UIColorSeparatorDashed.CGColor isHorizontal:NO];
    return layer;
}

+ (CALayer *)trui_separatorLayer
{
    CALayer *layer = [CALayer layer];
    [layer trui_removeDefaultAnimations];
    layer.backgroundColor = UIColorSeparator.CGColor;
    layer.frame = CGRectMake(0, 0, 0, PixelOne);
    return layer;
}

+ (CALayer *)trui_separatorLayerForTableView
{
    CALayer *layer = [self trui_separatorLayer];
    layer.backgroundColor = TableViewSeparatorColor.CGColor;
    return layer;
}

- (BOOL)hasFourCornerRadius
{
    return (self.trui_maskedCorners & TRUILayerMinXMinYCorner) == TRUILayerMinXMinYCorner &&
           (self.trui_maskedCorners & TRUILayerMaxXMinYCorner) == TRUILayerMaxXMinYCorner &&
           (self.trui_maskedCorners & TRUILayerMinXMaxYCorner) == TRUILayerMinXMaxYCorner &&
           (self.trui_maskedCorners & TRUILayerMaxXMaxYCorner) == TRUILayerMaxXMaxYCorner;
}

@end

@implementation UIView (TRUI_CornerRadius)

static NSString *kMaskName = @"TRUI_CornerRadius_Mask";
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(layoutSublayersOfLayer:), CALayer *, ^(UIView *selfObject, CALayer *layer){
            if (@available(iOS 11, *)) {
            } else {
                if (selfObject.layer.mask && ![selfObject.layer.mask.name isEqualToString:kMaskName]) {
                    return ;
                }
                if (selfObject.layer.trui_maskedCorners) {
                    if (selfObject.layer.trui_originCornerRadius <= 0 || [selfObject hasFourCornerRadius]) {
                        if (selfObject.layer.mask) {
                            selfObject.layer.mask = nil;
                        }
                    } else {
                        CAShapeLayer *cornerMaskLayer = [CAShapeLayer layer];
                        cornerMaskLayer.name = kMaskName;
                        UIRectCorner rectCorner = 0;
                        if ((selfObject.layer.trui_maskedCorners & TRUILayerMinXMinYCorner) == TRUILayerMinXMinYCorner) {
                            rectCorner |= UIRectCornerTopLeft;
                        }
                        if ((selfObject.layer.trui_maskedCorners & TRUILayerMaxXMinYCorner) == TRUILayerMaxXMinYCorner) {
                            rectCorner |= UIRectCornerTopRight;
                        }
                        if ((selfObject.layer.trui_maskedCorners & TRUILayerMinXMaxYCorner) == TRUILayerMinXMaxYCorner) {
                            rectCorner |= UIRectCornerBottomLeft;
                        }
                        if ((selfObject.layer.trui_maskedCorners & TRUILayerMaxXMaxYCorner) == TRUILayerMaxXMaxYCorner) {
                            rectCorner |= UIRectCornerBottomRight;
                        }
                        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:selfObject.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(selfObject.layer.trui_originCornerRadius, selfObject.layer.trui_originCornerRadius)];
                        cornerMaskLayer.frame = CGRectMakeWithSize(selfObject.bounds.size);
                        cornerMaskLayer.path = path.CGPath;
                        selfObject.layer.mask = cornerMaskLayer;
                    }
                }
            }
        });
    });
}

- (BOOL)hasFourCornerRadius
{
    return (self.layer.trui_maskedCorners & TRUILayerMinXMinYCorner) == TRUILayerMinXMinYCorner &&
           (self.layer.trui_maskedCorners & TRUILayerMaxXMinYCorner) == TRUILayerMaxXMinYCorner &&
           (self.layer.trui_maskedCorners & TRUILayerMinXMaxYCorner) == TRUILayerMinXMaxYCorner &&
           (self.layer.trui_maskedCorners & TRUILayerMaxXMaxYCorner) == TRUILayerMaxXMaxYCorner;
}

@end

@interface CAShapeLayer (TRUI_DynamicColor)

@property (nonatomic, strong) UIColor *qcl_originalFillColor;
@property (nonatomic, strong) UIColor *qcl_originalStrokeColor;

@end

@implementation CAShapeLayer (TRUI_DynamicColor)

TRUISynthesizeIdStrongProperty(qcl_originalFillColor, setQcl_originalFillColor);
TRUISynthesizeIdStrongProperty(qcl_originalStrokeColor, setQcl_originalStrokeColor);

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([CAShapeLayer class], @selector(setFillColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CAShapeLayer *selfObject, CGColorRef color) {
                UIColor *originalColor = [(__bridge id)(color) trui_getBoundObjectForKey:TRUICGColorOriginalColorBindKey];
                selfObject.qcl_originalFillColor = originalColor;
                
                //call super
                void(*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });
        
        OverrideImplementation([CAShapeLayer class], @selector(setStrokeColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CAShapeLayer *selfObject, CGColorRef color) {
                UIColor *originalColor = [(__bridge id)(color) trui_getBoundObjectForKey:TRUICGColorOriginalColorBindKey];
                selfObject.qcl_originalStrokeColor = originalColor;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });
    });
}

- (void)trui_setNeedsUpdateDynamicStyle
{
    [super trui_setNeedsUpdateDynamicStyle];
    
    if (self.qcl_originalFillColor) {
        self.fillColor = self.qcl_originalFillColor.CGColor;
    }
    
    if (self.qcl_originalStrokeColor) {
        self.strokeColor = self.qcl_originalStrokeColor.CGColor;
    }
}

@end

@interface CAGradientLayer (TRUI_DynamicColor)

@property(nonatomic, strong) NSArray <UIColor *>* qcl_originalColors;

@end

@implementation CAGradientLayer (TRUI_DynamicColor)

TRUISynthesizeIdStrongProperty(qcl_originalColors, setQcl_originalColors)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([CAGradientLayer class], @selector(setColors:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CAGradientLayer *selfObject, NSArray *colors) {
                void (*originSelectorIMP)(id, SEL, NSArray *);
                originSelectorIMP = (void (*)(id, SEL, NSArray *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, colors);
                
                __block BOOL hasDynamicColor = NO;
                NSMutableArray *originalColors = [NSMutableArray array];
                [colors enumerateObjectsUsingBlock:^(id color, NSUInteger idx, BOOL * _Nonnull stop) {
                    UIColor *originalColor = [color trui_getBoundObjectForKey:TRUICGColorOriginalColorBindKey];
                    if (originalColor) {
                        hasDynamicColor = YES;
                        [originalColors addObject:originalColor];
                    } else {
                        [originalColors addObject:[UIColor colorWithCGColor:(__bridge CGColorRef _Nonnull)(color)]];
                    }
                }];
                
                if (hasDynamicColor) {
                    selfObject.qcl_originalColors = originalColors;
                } else {
                    selfObject.qcl_originalColors = nil;
                }
                
            };
        });
    });
}

- (void)trui_setNeedsUpdateDynamicStyle {
    [super trui_setNeedsUpdateDynamicStyle];
    
    if (self.qcl_originalColors) {
        NSMutableArray *colors = [NSMutableArray array];
        [self.qcl_originalColors enumerateObjectsUsingBlock:^(UIColor * _Nonnull color, NSUInteger idx, BOOL * _Nonnull stop) {
            [colors addObject:(__bridge id _Nonnull)(color.CGColor)];
        }];
        self.colors = colors;
    }
}

@end
