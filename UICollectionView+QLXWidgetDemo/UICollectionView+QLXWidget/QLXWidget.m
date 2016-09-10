//
//  QLXWidget.m
//  UICollectionView+QLXWidgetDemo
//
//  Created by QLX on 16/9/10.
//  Copyright © 2016年 QLX. All rights reserved.
//

#import "QLXWidget.h"
#import "QWMacros.h"

@interface QLXWidget()

@property (nonatomic , weak , readwrite)  UICollectionView * collectionView;
@property(nonatomic , assign ,readwrite)  QLXWidgetState state;

@property(nonatomic , strong)  NSNumber * needRequest;

@end

@implementation QLXWidget

@synthesize headerData = _headerData;
@synthesize footerData = _footerData;
@synthesize cellDataList = _cellDataList;
@synthesize decorationViewClass = _decorationViewClass;

#pragma mark - public


- (void)requestHeaderRefresh{
    [self requestSuccess];
}

- (void)requestFooterRefresh{
    [self requestSuccess];
}

-(void)requestSuccess{
    [self requestFinishWithState:QLXWidgetStateRequestSuccess];
}

-(void)requestFail{
    [self requestFinishWithState:QLXWidgetStateRequestFail];
}

-(void)requestNoMoreData{
    [self requestFinishWithState:QLXWidgetStateRequestNoMoreData];
}

-(void)requestFinishWithState:(QLXWidgetState)state{
    self.needRequest = @(false);
    self.state = state;
    
    QWSuppressPerformSelectorLeakWarning(
      [self.collectionView performSelector:NSSelectorFromString(@"qw_requestFinish")];
    );
}

#pragma mark - getter

-(NSNumber *)needRequest{
    if (!_needRequest) {
        _needRequest = @(false);
    }
    return _needRequest;
}

-(QLXWidgetState)state{
    if ([self.needRequest boolValue]) {
        return QLXWidgetStateRequsting;
    }
    return _state;
}

-(NSObject *)headerData{
    if (!_headerData) {
        NSObject * defaultData = [NSObject new];
        defaultData.qlx_reuseIdentifierClass = [UICollectionReusableView class];
        defaultData.qlx_viewWidth = 0.001;
        defaultData.qlx_viewHeight = 0.001;
        _headerData = defaultData;
    }
    return _headerData;
}

-(void)setHeaderData:(NSObject *)headerData{
    if (( _headerData != headerData)) {
        _headerData = headerData;
        self.headerDataList = nil;
    }
}


-(NSObject *)footerData{
    if (!_footerData) {
        NSObject * defaultData = [NSObject new];
        defaultData.qlx_reuseIdentifierClass = [UICollectionReusableView class];
        defaultData.qlx_viewWidth = 0.001;
        defaultData.qlx_viewHeight = 0.001;
        _footerData = defaultData;
    }
    return _footerData;
}


-(void)setFooterData:(NSObject *)footerData{
    if ((_footerData != footerData)) {
        _footerData = footerData;
        self.footerDataList = nil;
    }
}

-(NSMutableArray *)cellDataList{
    if (!_cellDataList) {
        _cellDataList = [NSMutableArray new];
    }
    return _cellDataList;
}

-(void)setCellDataList:(NSMutableArray *)cellDataList{
    if (_cellDataList != cellDataList) {
        _cellDataList = cellDataList;
        self.multiCellDataList = nil;
    }
}

-(Class)decorationViewClass{
    if (!_decorationViewClass) {
        _decorationViewClass = [UICollectionReusableView class];
    }
    return _decorationViewClass;
}

-(NSMutableArray *)headerDataList{
    if (!_headerDataList) {
        _headerDataList = [[NSMutableArray alloc] initWithObjects:self.headerData, nil];
    }

    if (_headerDataList.count < self.multiCellDataList.count) {
        while (_headerDataList.count < self.multiCellDataList.count) {
            [_headerDataList addObject:self.headerData];
        }
    }
    return _headerDataList;
}

-(NSMutableArray *)footerDataList{
    if (!_footerDataList) {
        _footerDataList = [[NSMutableArray alloc] initWithObjects:self.footerData, nil];
    }
    if (_footerDataList.count < self.headerDataList.count) {
        while (_footerDataList.count < self.headerDataList.count) {
            [_footerDataList addObject:self.footerData];
        }
    }else if(_footerDataList.count > self.headerDataList.count){
        while (_footerDataList.count > self.headerDataList.count) {
            [_footerDataList removeLastObject];
        }
    }
    return _footerDataList;
}


-(NSMutableArray<NSMutableArray *> *)multiCellDataList{
    if (!_multiCellDataList) {
        _multiCellDataList = [[NSMutableArray alloc] initWithObjects:self.cellDataList, nil];
    }
    return _multiCellDataList ;
}



-(NSMutableArray<Class> *)decorationViewClassList{
    if (!_decorationViewClassList) {
        _decorationViewClassList = [[NSMutableArray alloc] initWithObjects:self.decorationViewClass, nil];
    }
    if (_decorationViewClassList.count < self.headerDataList.count) {
        while (_decorationViewClassList.count < self.headerDataList.count) {
            [_decorationViewClassList addObject:self.decorationViewClass];
        }
    }else if(_decorationViewClassList.count > self.headerDataList.count){
        while (_decorationViewClassList.count > self.headerDataList.count) {
            [_decorationViewClassList removeLastObject];
        }
    }
    return _decorationViewClassList;
}

-(void)setDecorationViewClass:(Class)decorationViewClass{
    if (_decorationViewClass != decorationViewClass) {
        _decorationViewClass = decorationViewClass;
        if (self.decorationViewClassList.count == 1) {
            [self.decorationViewClassList replaceObjectAtIndex:0 withObject:_decorationViewClass];
        }
    }
}



@end
