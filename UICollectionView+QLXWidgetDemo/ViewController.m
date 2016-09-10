//
//  ViewController.m
//  UICollectionView+QLXWidgetDemo
//
//  Created by QLX on 16/9/9.
//  Copyright © 2016年 QLX. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    
    UICollectionView * cv = [UICollectionView createForFlowLayout];
    [cv qw_addWidget:nil];
    [cv qw_addWidget:nil];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
