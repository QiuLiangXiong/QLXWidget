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




@interface UICollectionView()<QLXCollectionViewDataSource>

@property (nonatomic, strong)  NSMutableArray<QLXWidget *> * qw_widgets;

@property(nullable, nonatomic, strong) NSMutableArray<QLXSectionData *> * qw_sourceDataList;



@end


@implementation UICollectionView(QLXWidget)


#pragma mark - QLXCollectionViewDataSource
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSArray<QLXSectionData *> *)qlx_sectionDataListWithCollectionView:(UICollectionView *)collectionView{
    return self.qw_sourceDataList;
}
#pragma clang diagnostic pop


#pragma mark - public

-(void) qw_reloadWidgets{
    [self qw_syncToDataSource];
    [self reloadData];
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
//    [self qw_reloadWidgets];
    
    if ([widget isKindOfClass:[QLXWidget class]]) {
        [self qw_syncToDataSource];
        NSArray * widgetSections = widget.multiSections.count ? widget.multiSections : @[widget.sectionData];
        
        if (self.qw_sourceDataList.count) {
            NSInteger index = [self.qw_sourceDataList indexOfObject:widgetSections.firstObject];
            if (index >= 0 && index < self.qw_sourceDataList.count) {
                [self reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, widgetSections.count)]];
            }
        }else {
            [self reloadData];
        }
        
    }
    
    
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

- (void)qw_delayReload{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(qw_reloadWidgets) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadAllWidgetsIfNeed) object:nil];
    [self performSelector:@selector(qw_reloadWidgets) withObject:nil afterDelay:0];
}

- (void)qw_syncToDataSource{
    NSMutableArray * list = [NSMutableArray new];
    for (QLXWidget * widget in self.qw_widgets) {
        if (widget.multiSections && widget.multiSections.count > 0) {
            [list addObjectsFromArray:widget.multiSections];
        }else if(widget.sectionData){
            [list addObject:widget.sectionData];
        }
    }
    self.qw_sourceDataList = list;
}


/**
 *  请求数据完毕时回调
 */
- (void)qw_requestFinish{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadAllWidgetsIfNeed) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(qw_reloadWidgets) object:nil];
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


- (NSMutableArray<QLXWidget *> *)qw_widgets{
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
