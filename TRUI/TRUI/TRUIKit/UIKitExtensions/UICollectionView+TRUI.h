//
//  UICollectionView+TRUI.h
//  TRUI
//
//  Created by Mac on 2020/4/28.
//  Copyright © 2020 Mac. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UICollectionView (TRUI)

/**
 *  清除所有已选中的item的选中状态
 */
- (void)trui_clearsSelection;

/**
 *  重新`reloadData`，同时保持`reloadData`前item的选中状态
 */
- (void)trui_reloadDataKeepingSelection;

/**
 *  获取某个view在collectionView内对应的indexPath
 *
 *  例如某个view是某个cell里的subview，在这个view的点击事件回调方法里，就能通过`trui_indexPathForItemAtView:`获取被点击的view所处的cell的indexPath
 *
 *  @warning 注意返回的indexPath有可能为nil，要做保护。
 */
- (NSIndexPath *)trui_indexPathForItemAtView:(id)sender;

/**
 *  判断当前 indexPath 的 item 是否为可视的 item
 */
- (BOOL)trui_itemVisibleAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  对系统的 indexPathsForVisibleItems 进行了排序后的结果
 */
- (NSArray<NSIndexPath *> *)trui_indexPathsForVisibleItems;

/**
 *  获取可视区域内第一个cell的indexPath。
 *
 *  为什么需要这个方法是因为系统的indexPathsForVisibleItems方法返回的数组成员是无序排列的，所以不能直接通过firstObject拿到第一个cell。
 *
 *  @warning 若可视区域为CGRectZero，则返回nil
 */
- (NSIndexPath *)trui_indexPathForFirstVisibleCell;

@end

