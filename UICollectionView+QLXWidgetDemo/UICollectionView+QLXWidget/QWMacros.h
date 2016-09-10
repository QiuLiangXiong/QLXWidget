//
//  QWMacros.h
//  UICollectionView+QLXWidgetDemo
//
//  Created by QLX on 16/9/10.
//  Copyright © 2016年 QLX. All rights reserved.
//

#ifndef QWMacros_h
#define QWMacros_h


#ifdef DEBUG
#define QWAssert(condition , description)  if(!(condition)){ NSLog(@"%@",description); assert(0);}
#else
#define QWAssert(condition , description)
#endif

#define QWSuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


#endif /* QWMacros_h */
