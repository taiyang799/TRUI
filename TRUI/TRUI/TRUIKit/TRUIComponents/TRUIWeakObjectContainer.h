//
//  TRUIWeakObjectContainer.h
//  TRUI
//
//  Created by Mac on 2020/4/23.
//  Copyright © 2020 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 一个常见的场景：当通过objc_setAssociatedObject 以弱引用的方式（OBJC_ASSOCIATION_ASSIGN）绑定对象A时，假如对象A稍后被释放了，则通过objc_getAssociatedObject 再次试图访问对象A时会导致野指针。
 这时你可以将对象A包装为一个TRUIWeakObjectContainer，并改为通过强引用方式（OBJC_ASSOCIATION_RETAIN_NONATOMIC/OBJC_ASSOCIATION_RETAIN）绑定这个 TRUIWeakObjectContainer，进而安全的获取原始对象A。
 */
@interface TRUIWeakObjectContainer : NSProxy

/// 获取原始对象object，如果 object 已被释放则该属性返回nil
@property (nonatomic, nullable, weak) id object;

///将一个 object 包装奥一个TRUIWeakObjectContainer 里
+ (instancetype)containerWithObject:(id)object;
- (instancetype)init;
- (instancetype)initWithObject:(id)object;

@end

NS_ASSUME_NONNULL_END
