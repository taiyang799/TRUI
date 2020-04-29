//
//  UIButton+TRUI.m
//  TRUI
//
//  Created by Mac on 2020/4/28.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "UIButton+TRUI.h"
#import "TRUILab.h"
#import "TRUIRuntime.h"
#import "TRUICommonDefines.h"

@interface UIButton ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary<NSAttributedStringKey, id> *> *trui_titleAttributes;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableDictionary<NSNumber *, NSNumber *> *> *trui_customizeButtonPropDict;

@end

@implementation UIButton (TRUI)

TRUISynthesizeIdStrongProperty(trui_titleAttributes, setTrui_titleAttributes)
TRUISynthesizeIdStrongProperty(trui_customizeButtonPropDict, setTrui_customizeButtonPropDict)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithTwoArguments([UIButton class], @selector(setTitle:forState:), NSString *, UIControlState, ^(UIButton *selfObject, NSString *title, UIControlState state){
            [selfObject _markTRUICustomizeType:TRUICustomizeButtonPropTypeTitle forState:state value:title];
            if (!title || !selfObject.trui_titleAttributes.count) {
                return ;
            }
            if (state == UIControlStateNormal) {
                [selfObject.trui_titleAttributes enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSDictionary<NSAttributedStringKey,id> * _Nonnull obj, BOOL * _Nonnull stop) {
                    UIControlState state = [key unsignedIntegerValue];
                    NSString *titleForState = [selfObject titleForState:state];
                    NSAttributedString *string = [[NSAttributedString alloc] initWithString:titleForState attributes:obj];
                    [selfObject setAttributedTitle:[selfObject attributedStringWithEndKernRemoved:string] forState:state];
                }];
                return;
            }
            
            if ([selfObject.trui_titleAttributes objectForKey:@(state)]) {
                NSAttributedString *string = [[NSAttributedString alloc] initWithString:title attributes:selfObject.trui_titleAttributes[@(state)]];
                [selfObject setAttributedTitle:[selfObject attributedStringWithEndKernRemoved:string] forState:state];
                return;
            }
        });
        
        // 如果之前已经设置了此 state 下的文字颜色，则覆盖掉之前的颜色
        ExtendImplementationOfVoidMethodWithTwoArguments([UIButton class], @selector(setTitleColor:forState:), UIColor *, UIControlState, ^(UIButton *selfObject, UIColor *color, UIControlState state){
            [selfObject _markTRUICustomizeType:TRUICustomizeButtonPropTypeTitleColor forState:state value:color];
            NSDictionary *attributes = selfObject.trui_titleAttributes[@(state)];
            if (attributes) {
                NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
                newAttributes[NSForegroundColorAttributeName] = color;
                [selfObject trui_setTitleAttributes:[NSDictionary dictionaryWithDictionary:newAttributes] forState:state];
            }
        });
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UIButton class], @selector(setTitleShadowColor:forState:), UIColor *, UIControlState, ^(UIButton *selfObject, UIColor *color, UIControlState state) {
            [selfObject _markTRUICustomizeType:TRUICustomizeButtonPropTypeTitleShadowColor forState:state value:color];
        });
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UIButton class], @selector(setImage:forState:), UIImage *, UIControlState, ^(UIButton *selfObject, UIImage *image, UIControlState state) {
            [selfObject _markTRUICustomizeType:TRUICustomizeButtonPropTypeImage forState:state value:image];
        });
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UIButton class], @selector(setBackgroundImage:forState:), UIImage *, UIControlState, ^(UIButton *selfObject, UIImage *image, UIControlState state) {
            [selfObject _markTRUICustomizeType:TRUICustomizeButtonPropTypeBackgroundImage forState:state value:image];
        });
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UIButton class], @selector(setAttributedTitle:forState:), NSAttributedString *, UIControlState, ^(UIButton *selfObject, NSAttributedString *title, UIControlState state) {
            [selfObject _markTRUICustomizeType:TRUICustomizeButtonPropTypeAttributedTitle forState:state value:title];
        });
        
        if (@available(iOS 13, *)) {
            ExtendImplementationOfVoidMethodWithoutArguments([UIButton class], @selector(layoutSubviews), ^(UIButton *selfObject) {
                // 临时解决 iOS 13 开启了粗体文本（Bold Text）导致 UIButton Title 显示不完整
                if (UIAccessibilityIsBoldTextEnabled()) {
                    [selfObject.titleLabel sizeToFit];
                }
            });
        }
        
    });
}

- (instancetype)trui_initWithImage:(UIImage *)image title:(NSString *)title
{
    BeginIgnoreClangWarning(-Wunused-value)
    [self init];
    EndIgnoreClangWarning
    [self setImage:image forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateNormal];
    return self;
}

- (void)trui_calculateHeightAfterSetAppearance
{
    [self setTitle:@"测" forState:UIControlStateNormal];
    [self sizeToFit];
    [self setTitle:nil forState:UIControlStateNormal];
}

- (BOOL)trui_hasCustomizedButtonPropForState:(UIControlState)state
{
    if (self.trui_customizeButtonPropDict) {
        return self.trui_customizeButtonPropDict[@(state)].count > 0;
    }
    return NO;
}

- (BOOL)trui_hasCustomizedButtonPropWithType:(TRUICustomizeButtonPropType)type forState:(UIControlState)state
{
    if (self.trui_customizeButtonPropDict && self.trui_customizeButtonPropDict[@(state)]) {
        return [self.trui_customizeButtonPropDict[@(state)][@(type)] boolValue];
    }
    return NO;
}

#pragma mark - Title Attributes
- (void)trui_setTitleAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state
{
    if (!attributes) {
        [self.trui_titleAttributes removeObjectForKey:@(state)];
        [self setAttributedTitle:nil forState:state];
        return;
    }
    if (!self.trui_titleAttributes) {
        self.trui_titleAttributes = [NSMutableDictionary dictionary];
    }
    
    //如果传入的 attributes 没有包含文字颜色，则使用用户之前通过 setTitleColor:forState:方法设置的颜色
    if (![attributes objectForKey:NSForegroundColorAttributeName]) {
        NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        newAttributes[NSForegroundColorAttributeName] = [self titleColorForState:state];
        attributes = [NSDictionary dictionaryWithDictionary:newAttributes];
    }
    self.trui_titleAttributes[@(state)] = attributes;
    
    // 确保调用此方法设置 attributes 之前已经通过 setTitle:forState: 设置的文字也能应用上新的 attributes
    NSString *originalText = [self titleForState:state];
    [self setTitle:originalText forState:state];
    
    // 一个系统的不好的特性（bug?）：如果你给 UIControlStateHighlighted（或者 normal 之外的任何 state）设置了包含 NSFont/NSKern/NSUnderlineAttributeName 之类的 attributedString ，但又仅用 setTitle:forState: 给 UIControlStateNormal 设置了普通的 string ，则按钮从 highlighted 切换回 normal 状态时，font 之类的属性依然会停留在 highlighted 时的状态
    // 为了解决这个问题，我们要确保一旦有 normal 之外的 state 通过设置 trui_titleAttributes 属性而导致使用了 attributedString，则 normal 也必须使用 attributedString
    if (self.trui_titleAttributes.count && !self.trui_titleAttributes[@(UIControlStateNormal)]) {
        [self trui_setTitleAttributes:@{} forState:UIControlStateNormal];
    }
}

/// 去除最后一个字的 kern 效果
- (NSAttributedString *)attributedStringWithEndKernRemoved:(NSAttributedString *)string
{
    if (!string || !string.length) {
        return string;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    [attributedString removeAttribute:NSKernAttributeName range:NSMakeRange(string.length - 1, 1)];
    return [[NSAttributedString alloc] initWithAttributedString:attributedString];
}

#pragma mark - customize state
- (void)_markTRUICustomizeType:(TRUICustomizeButtonPropType)type forState:(UIControlState)state value:(id)value
{
    if (value) {
        [self _setTRUICustomizeType:type forState:state];
    } else {
        [self _removeTRUICustomizeType:type forState:state];
    }
}

- (void)_setTRUICustomizeType:(TRUICustomizeButtonPropType)type forState:(UIControlState)state
{
    if (!self.trui_customizeButtonPropDict) {
        self.trui_customizeButtonPropDict = [NSMutableDictionary dictionary];
    }
    if (!self.trui_customizeButtonPropDict[@(state)]) {
        self.trui_customizeButtonPropDict[@(state)] = [NSMutableDictionary dictionary];
    }
    self.trui_customizeButtonPropDict[@(state)][@(type)] = @(YES);
}

- (void)_removeTRUICustomizeType:(TRUICustomizeButtonPropType)type forState:(UIControlState)state
{
    if (!self.trui_customizeButtonPropDict || !self.trui_customizeButtonPropDict[@(state)]) {
        return;
    }
    
    [self.trui_customizeButtonPropDict[@(state)] removeObjectForKey:@(type)];
}

@end
