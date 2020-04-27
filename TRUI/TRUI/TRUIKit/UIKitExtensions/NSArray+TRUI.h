//
//  NSArray+TRUI.h
//  TRUI
//
//  Created by Mac on 2020/4/23.
//  Copyright © 2020 Mac. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (TRUI)

/// 将多个对象合并成一个数组，如果参数类型是数组则会将数组内的元素解析出来加到return内（只会拆解一层，所以多维数组不处理）
/// @param object 要合并的多个数组
/// @return 合并完的结果
+ (instancetype)trui_arrayWithObjects:(id)object, ...;

/// 将多维数组打平成一维数组再遍历所有子元素
- (void)trui_enumerateNestedArrayWithBlock:(void(^)(id obj, BOOL *stop))block;

/// 将多维数组递归转换成mutable多维数组
- (NSMutableArray *)trui_mutableCopyNestedArray;

/// 过滤数组元素，将block返回YES的item重新组装成一个数组返回
- (NSArray<ObjectType> *)trui_filterWithBlock:(BOOL(^)(ObjectType item))block;

/// 转换数组元素，将每个 item 都经过block转换成一遍，返回转换后的新数组
- (NSArray *)trui_mapWithBlock:(id(^)(ObjectType item))block;

@end

