//
//  TRUILab.h
//  TRUI
//
//  Created by Mac on 2020/4/26.
//  Copyright © 2020 Mac. All rights reserved.
//

#ifndef TRUILab_h
#define TRUILab_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "TRUIWeakObjectContainer.h"
#import "NSNumber+TRUI.h"

/**
 以下系列宏用于在Category里添加property时，可以在@implementation里一句代码完成getter/setter的声明。暂不支持在getter/setter里添加自定义的逻辑，需要自定义逻辑的情况请继续使用 Code Snippet生成的代码。
 使用方式：
 @code
 @interface NSObject (CategoryName)
 @property (nonatomic, strong) type *strongObj;
 @property (nonatomic, weak) type *weakObj;
 @property (nonatomic, assign) CGRect rectValue;
 @end
 
 @implementation NSObject (CategoryName)
 //注意setter不需要带冒号
 TRUISynthesizeIdStrongProperty(strongObj, setStrongObj)
 TRUISynthesizeWeakProperty(weakObj, setWeakObj)
 TRUISynthesizeCGRectProperty(rectValue, setRectValue)
 @end
 @endcode
 */

#pragma mark - Meta Marcos

#define _TRUISynthesizeId(_getterName, _setterName, _policy) \
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(id)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, _getterName, OBJC_ASSOCIATION_##_policy##_NONATOMIC);\
}\
\
- (id)_getterName {\
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName);\
}\

#define _TRUISynthesizeWeakId(_getterName, _setterName) \
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(id)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, [[TRUIWeakObjectContainer alloc] initWithObject:_getterName], OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
\
- (id)_getterName {\
    return ((TRUIWeakObjectContainer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName)).object;\
}\

#define _TRUISynthesizeNonObject(_getterName, _setterName, _type, valueInitializer, valueGetter) \
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(_type)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, [NSNumber valueInitializer:_getterName], OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
\
- (_type)_getterName {\
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName)) valueGetter];\
}\


#pragma mark - Object Marcos

/// @property(nonatomic, strong) id xxx
#define TRUISynthesizeIdStrongProperty(_getterName, _setterName) _TRUISynthesizeId(_getterName, _setterName, RETAIN)

/// @property(nonatomic, weak) id xxx
#define TRUISynthesizeIdWeakProperty(_getterName, _setterName) _TRUISynthesizeWeakId(_getterName, _setterName)

/// @property(nonatomic, copy) id xxx
#define TRUISynthesizeIdCopyProperty(_getterName, _setterName) _TRUISynthesizeId(_getterName, _setterName, COPY)

#pragma mark - NonObject Marcos

/// @property(nonatomic, assign) Int xxx
#define TRUISynthesizeIntProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, int, numberWithInt, intValue)

/// @property(nonatomic, assign) unsigned int xxx
#define TRUISynthesizeUnsignedIntProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, unsigned int, numberWithUnsignedInt, unsignedIntValue)

/// @property(nonatomic, assign) float xxx
#define TRUISynthesizeFloatProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, float, numberWithFloat, floatValue)

/// @property(nonatomic, assign) double xxx
#define TRUISynthesizeDoubleProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, double, numberWithDouble, doubleValue)

/// @property(nonatomic, assign) BOOL xxx
#define TRUISynthesizeBOOLProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, BOOL, numberWithBool, boolValue)

/// @property(nonatomic, assign) NSInteger xxx
#define TRUISynthesizeNSIntegerProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, NSInteger, numberWithInteger, integerValue)

/// @property(nonatomic, assign) NSUInteger xxx
#define TRUISynthesizeNSUIntegerProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, NSUInteger, numberWithUnsignedInteger, unsignedIntegerValue)

/// @property(nonatomic, assign) CGFloat xxx
#define TRUISynthesizeCGFloatProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, CGFloat, numberWithDouble, trui_CGFloatValue)

/// @property(nonatomic, assign) CGPoint xxx
#define TRUISynthesizeCGPointProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, CGPoint, valueWithCGPoint, CGPointValue)

/// @property(nonatomic, assign) CGSize xxx
#define TRUISynthesizeCGSizeProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, CGSize, valueWithCGSize, CGSizeValue)

/// @property(nonatomic, assign) CGRect xxx
#define TRUISynthesizeCGRectProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, CGRect, valueWithCGRect, CGRectValue)

/// @property(nonatomic, assign) UIEdgeInsets xxx
#define TRUISynthesizeUIEdgeInsetsProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, UIEdgeInsets, valueWithUIEdgeInsets, UIEdgeInsetsValue)

/// @property(nonatomic, assign) CGVector xxx
#define TRUISynthesizeCGVectorProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, CGVector, valueWithCGVector, CGVectorValue)

/// @property(nonatomic, assign) CGAffineTransform xxx
#define TRUISynthesizeCGAffineTransformProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, CGAffineTransform, valueWithCGAffineTransform, CGAffineTransformValue)

/// @property(nonatomic, assign) NSDirectionalEdgeInsets xxx
#define TRUISynthesizeNSDirectionalEdgeInsetsProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, NSDirectionalEdgeInsets, valueWithDirectionalEdgeInsets, NSDirectionalEdgeInsetsValue)

/// @property(nonatomic, assign) UIOffset xxx
#define TRUISynthesizeUIOffsetProperty(_getterName, _setterName) _TRUISynthesizeNonObject(_getterName, _setterName, UIOffset, valueWithUIOffset, UIOffsetValue)

#endif /* TRUILab_h */
