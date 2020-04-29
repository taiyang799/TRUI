//
//  UICollectionView+TRUI.m
//  TRUI
//
//  Created by Mac on 2020/4/28.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "UICollectionView+TRUI.h"
#import "TRUIRuntime.h"
#import "TRUIConfigurationMacros.h"

@implementation UICollectionView (TRUI)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 防止 release 版本滚动到不合法的 indexPath 会 crash
        OverrideImplementation([UICollectionView class], @selector(scrollToItemAtIndexPath:atScrollPosition:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UICollectionView *selfObject, NSIndexPath *indexPath, UICollectionViewScrollPosition scrollPosition, BOOL animated){
                BOOL isIndexPathLegal = YES;
                NSInteger numberOfSections = [selfObject numberOfSections];
                if (indexPath.section >= numberOfSections) {
                    isIndexPathLegal = NO;
                } else {
                    NSInteger items = [selfObject numberOfItemsInSection:indexPath.section];
                    if (indexPath.item >= items) {
                        isIndexPathLegal = NO;
                    }
                }
                if (!isIndexPathLegal) {
                    TRUILogWarn(@"UICollectionView (TRUI)", @"%@ - target indexPath : %@ ，不合法的indexPath。\n%@", selfObject, indexPath, [NSThread callStackSymbols]);
                    if (TRUICMIActivated && !ShouldPrintTRUIWarnLogToConsole) {
                        NSAssert(NO, @"出现不合法的indexPath");
                    }
                    return ;
                }
                
                //call super
                void(*originSelectorIMP)(id, SEL, NSIndexPath *, UICollectionViewScrollPosition, BOOL);
                originSelectorIMP = (void(*)(id, SEL, NSIndexPath *, UICollectionViewScrollPosition, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, indexPath, scrollPosition, animated);
            };
        });
    });
}

- (void)trui_clearsSelection
{
    NSArray *selectedItemIndexPaths = [self indexPathsForSelectedItems];
    for (NSIndexPath *indexPath in selectedItemIndexPaths) {
        [self selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

///递归找到view在哪个cell里，不存在则返回nil
- (UICollectionViewCell *)parentCellForView:(UIView *)view
{
    if (!view.superview) {
        return nil;
    }
    if ([view.superview isKindOfClass:[UICollectionViewCell class]]) {
        return (UICollectionViewCell *)view.superview;
    }
    return [self parentCellForView:view.superview];
}

- (NSIndexPath *)trui_indexPathForItemAtView:(id)sender
{
    if (sender && [sender isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)sender;
        UICollectionViewCell *parentCell = [self parentCellForView:view];
        if (parentCell) {
            return [self indexPathForCell:parentCell];
        }
    }
    return nil;
}

- (BOOL)trui_itemVisibleAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *visibleItemIndexPaths = self.indexPathsForVisibleItems;
    for (NSIndexPath *visibleIndexPath in visibleItemIndexPaths) {
        if ([indexPath isEqual:visibleIndexPath]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray<NSIndexPath *> *)trui_indexPathsForVisibleItems
{
    NSArray<NSIndexPath *> *visibleItems = self.indexPathsForVisibleItems;
    NSSortDescriptor *sectionSorter = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
    NSSortDescriptor *rowSorter = [[NSSortDescriptor alloc] initWithKey:@"item" ascending:YES];
    visibleItems = [visibleItems sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sectionSorter, rowSorter, nil]];
    return visibleItems;
}

- (NSIndexPath *)trui_indexPathForFirstVisibleCell
{
    NSArray *visibleIndexPaths = [self trui_indexPathsForVisibleItems];
    if (!visibleIndexPaths || visibleIndexPaths.count <= 0) {
        return nil;
    }
    return visibleIndexPaths.firstObject;
}

@end
