//
//  UICollectionView+QLXWidget.m
//  UICollectionView+QLXWidgetDemo
//
//  Created by QLX on 16/9/10.
//  Copyright © 2016年 QLX. All rights reserved.
//

#import "UICollectionView+QLXWidget.h"
#import "objc/runtime.h"
#import "QLXWidget.h"
#import "QWMacros.h"





@interface UICollectionView()

@property (nonatomic, strong)  NSMutableArray * qw_widgets;

@property (nonatomic, strong)  NSMutableArray * qw_headerDataList;
@property (nonatomic, strong)  NSMutableArray * qw_cellDataList;
@property (nonatomic, strong)  NSMutableArray * qw_footerDataList;
@property (nonatomic , strong) NSMutableArray * qw_decorationViewClassList;



@end


@implementation UICollectionView(QLXWidget)


#pragma mark - QLXCollectionViewDataSource

- (NSArray *)qlx_headerDataListWithCollectionView:(UICollectionView *) collectionView{
    return self.qw_headerDataList;
}

- (NSArray *)qlx_cellDataListWithCollectionView:(UICollectionView *) collectionView{
    return self.qw_cellDataList;
}

- (NSArray *)qlx_footerDataListWithCollectionView:(UICollectionView *) collectionView{
    return self.qw_footerDataList;
}

- (NSArray<Class> *)qlx_decorationViewClassListWithCollectionView:(UICollectionView *)collectionView{
    return self.qw_decorationViewClassList;
}


#pragma mark - public

-(void) qw_reloadWidgets{
    if (self.qw_state != QLXWidgetStateRequestFail) {
        [self.qw_headerDataList removeAllObjects];
        [self.qw_cellDataList removeAllObjects];
        [self.qw_footerDataList removeAllObjects];
        [self.qw_decorationViewClassList removeAllObjects];
        for (QLXWidget * widget in self.qw_widgets) {
            [self.qw_headerDataList addObjectsFromArray:widget.headerDataList];
            [self.qw_cellDataList addObjectsFromArray:widget.multiCellDataList];
            [self.qw_footerDataList addObjectsFromArray:widget.footerDataList];
            [self.qw_decorationViewClassList addObjectsFromArray:widget.decorationViewClassList];
        }
        [self reloadData];
    }
}


-(void)qw_collectionViewHeaderRefresh{
    for (QLXWidget * widget in self.qw_widgets) {
        [widget setValue:@(true) forKey:@"needRequest"];
        [widget requestHeaderRefresh];
    }
}


-(void)qw_collectionViewFooterRefresh{
    for (QLXWidget * widget in self.qw_widgets) {
        [widget setValue:@(true) forKey:@"needRequest"];
        [widget requestFooterRefresh];
    }
}


-(void) qw_endRefreshingWithWidgetState:(QLXWidgetState)state{
    QWAssert(false, @"need overriding");
}


-(void) qw_reloadWidget:(QLXWidget *)widget{
    [self qw_reloadWidgets];
}


- (void)qw_addWidget:(QLXWidget *) widget{
    NSUInteger index = self.qw_widgets.count;
    [self qw_insertWidget:widget atIndex:index];
}

- (void)qw_insertWidget:(QLXWidget *) widget atIndex:(NSUInteger)index {
    if ([widget isKindOfClass:[QLXWidget class]] && self.qw_widgets.count <= index) {
        if ([self qw_containWidget:widget] == false) {
            [widget setValue:self forKey:@"collectionView"];
            [self.qw_widgets insertObject:widget atIndex:index];
            [self qw_delayReload];
        }
    }else {
        QWAssert([widget isKindOfClass:[QLXWidget class]], @"widget 类型 不符");
        QWAssert(self.qw_widgets.count <= index, @"index 超出范围");
    }
    if (self.qw_widgets.count) {
        self.qlx_dataSource = (id<QLXCollectionViewDataSource>)self;
    }
}

- (void)qw_removeWidget:(QLXWidget *) widget{
    if ([self.qw_widgets containsObject:widget]) {
        [self.qw_widgets removeObject:widget];
        [self qw_delayReload];
    }
}


- (void)qw_removeAllWidgets{
    if (self.qw_widgets.count) {
        [self.qw_widgets removeAllObjects];
        [self qw_delayReload];
    }
}

- (BOOL)qw_containWidget:(QLXWidget *)widget{
    return [self.qw_widgets containsObject:widget];
}


- (BOOL)qw_containWidgetClass:(Class) widgetClass{
    for (QLXWidget * sub in self.qw_widgets) {
        if ([sub isMemberOfClass:widgetClass]) {
            return true;
        }
    }
    return false;
}




- (QLXWidgetState) qw_state{
    QLXWidgetState state = QLXWidgetStateDefault;
    for (QLXWidget * widget in self.qw_widgets) {
        if (widget.state == QLXWidgetStateRequsting) {
            return QLXWidgetStateRequsting;
        }
    }
    for (QLXWidget * widget in self.qw_widgets) {
        if (widget.state == QLXWidgetStateRequestNoMoreData) {
            state = QLXWidgetStateRequestNoMoreData;
            break;
        }
        if (widget.state == QLXWidgetStateRequestSuccess) {
            state = QLXWidgetStateRequestSuccess;
        }
        if (widget.state == QLXWidgetStateRequestFail && state != QLXWidgetStateRequestSuccess) {
            state = QLXWidgetStateRequestFail;
        }
    }
    return state;
}


#pragma mark - private

-(void) qw_delayReload{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadData) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadAllWidgetsIfNeed) object:nil];
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0];
}




/**
 *  请求数据完毕时回调
 */
- (void)qw_requestFinish{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadAllWidgetsIfNeed) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadData) object:nil];
    [self performSelector:@selector(reloadAllWidgetsIfNeed) withObject:nil afterDelay:0];
}

-(void)reloadAllWidgetsIfNeed{
    BOOL need = true;
    for (QLXWidget * widget in self.qw_widgets) {
        if (widget.state == QLXWidgetStateRequsting) {
            need = false;
            break;
        }
    }
    if (need) {
        [self qw_reloadWidgets];
        [self qw_endRefreshingWithWidgetState:self.qw_state];
    }
}

#pragma mark - getter setter

- (NSMutableArray *)qw_headerDataList{
    NSMutableArray * list = objc_getAssociatedObject(self, @selector(qw_headerDataList));
    if (!list) {
        list = [NSMutableArray new];
        objc_setAssociatedObject(self, @selector(qw_headerDataList), list, OBJC_ASSOCIATION_RETAIN);
    }
    return list;
}


- (void)setQw_headerDataList:(NSMutableArray *)qw_headerDataList{
    objc_setAssociatedObject(self, @selector(qw_headerDataList), qw_headerDataList, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *)qw_footerDataList{
    NSMutableArray * list = objc_getAssociatedObject(self, @selector(qw_footerDataList));
    if (!list) {
        list = [NSMutableArray new];
        objc_setAssociatedObject(self, @selector(qw_footerDataList), list, OBJC_ASSOCIATION_RETAIN);
    }
    return list;
}

- (void)setQw_footerDataList:(NSMutableArray *)qw_footerDataList{
    objc_setAssociatedObject(self, @selector(qw_footerDataList), qw_footerDataList, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *)qw_cellDataList{
    NSMutableArray * list = objc_getAssociatedObject(self, @selector(qw_cellDataList));
    if (!list) {
        list = [NSMutableArray new];
        objc_setAssociatedObject(self, @selector(qw_cellDataList), list, OBJC_ASSOCIATION_RETAIN);
    }
    return list;
}

- (void)setQw_cellDataList:(NSMutableArray *)qw_cellDataList{
    objc_setAssociatedObject(self, @selector(qw_cellDataList), qw_cellDataList, OBJC_ASSOCIATION_RETAIN);
}


- (NSMutableArray *)qw_decorationViewClassList{
    NSMutableArray * list = objc_getAssociatedObject(self, @selector(qw_decorationViewClassList));
    if (!list) {
        list = [NSMutableArray new];
        objc_setAssociatedObject(self, @selector(qw_decorationViewClassList), list, OBJC_ASSOCIATION_RETAIN);
    }
    return list;
}

- (void)setQw_decorationViewClassList:(NSMutableArray *)qw_decorationViewClassList{
    objc_setAssociatedObject(self, @selector(qw_decorationViewClassList), qw_decorationViewClassList, OBJC_ASSOCIATION_RETAIN);
}


- (NSMutableArray *)qw_widgets{
    NSMutableArray * widgets = objc_getAssociatedObject(self, @selector(qw_widgets));
    if (!widgets) {
        widgets = [NSMutableArray new];
        objc_setAssociatedObject(self, @selector(qw_widgets), widgets, OBJC_ASSOCIATION_RETAIN);
    }
    return widgets;
}

- (void)setQw_widgets:(NSMutableArray *)qw_widgets{
    objc_setAssociatedObject(self, @selector(qw_widgets), qw_widgets, OBJC_ASSOCIATION_RETAIN);
}








@end
