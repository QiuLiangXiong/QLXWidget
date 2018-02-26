//
//  QLXWidget.m
//  UICollectionView+QLXWidgetDemo
//
//  Created by QLX on 16/9/10.
//  Copyright © 2016年 QLX. All rights reserved.
//

#import "QLXWidget.h"
#import "QWMacros.h"
#import "UICollectionView+QLX.h"

@interface QLXWidget()

@property (nonatomic , weak , readwrite)  UICollectionView * collectionView;
@property (nonatomic , assign ,readwrite)  QLXWidgetState state;

@property (nonatomic , strong)  NSNumber * needRequest;

@end

@implementation QLXWidget



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

- (QLXSectionData *)sectionData{
    if (!_sectionData) {
        _sectionData = [QLXSectionData new];
    }
    return _sectionData;
}

- (NSMutableArray<QLXSectionData *> *)multiSections{
    if (!_multiSections) {
        _multiSections = [NSMutableArray new];
    }
    return _multiSections;
    
}

@end
