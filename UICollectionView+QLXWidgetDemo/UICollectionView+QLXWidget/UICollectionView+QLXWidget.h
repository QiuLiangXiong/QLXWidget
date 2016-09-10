//
//  UICollectionView+QLXWidget.h
//  UICollectionView+QLXWidgetDemo
//
//  Created by QLX on 16/9/10.
//  Copyright © 2016年 QLX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QLXWidget.h"


@interface UICollectionView(QLXWidget)

@property (nonatomic , assign , readonly) QLXWidgetState  qw_state;

/**
 *  头部刷新时 调用此方法
 */
-(void)qw_collectionViewHeaderRefresh;
/**
 *  尾部刷新时 调用此方法
 */
-(void)qw_collectionViewFooterRefresh;

/**
 *  结束刷新  务必重写
 */
-(void) qw_endRefreshingWithWidgetState:(QLXWidgetState)state;

/**
 *  刷新所有部件
 */
-(void) qw_reloadWidgets;

/**
 *  刷新部件
 */
-(void) qw_reloadWidget:(QLXWidget *)widget;

/**
 *  添加一个部件
 */
- (void)qw_addWidget:(QLXWidget *) widget;

/**
 *  插入一个部件
 */
- (void)qw_insertWidget:(QLXWidget *) widget atIndex:(NSUInteger)index ;

/**
 *  删除一个部件
 */
- (void)qw_removeWidget:(QLXWidget *) widget;

/**
 *  删除所有部件
 */
- (void)qw_removeAllWidgets;

/**
 *  判断是否已经包含该部件
 */
- (BOOL)qw_containWidget:(QLXWidget *)widget;

/**
 *  判断是否已经有该类部件
 */
- (BOOL)qw_containWidgetClass:(Class) widgetClass;


@end
