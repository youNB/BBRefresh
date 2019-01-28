//
//  UIScrollView+refreshAndLoad.m
//  BBRefresh
//
//  Created by 程肖斌 on 2019/1/28.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import "UIScrollView+refreshAndLoad.h"
#import <objc/runtime.h>

@implementation UIScrollView (refreshAndLoad)

+ (void)load{
    static dispatch_once_t once_t = 0;
    dispatch_once(&once_t, ^{
        SEL sel = NSSelectorFromString(@"dealloc");
        Method pre = class_getInstanceMethod([self class], sel);
        Method now = class_getInstanceMethod([self class], @selector(nowDealloc));
        method_exchangeImplementations(pre, now);
    });
}

- (void)setRl_refresh_view:(BBRefreshView *)rl_refresh_view{
    objc_setAssociatedObject(self, "rl_refresh_view", rl_refresh_view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BBRefreshView *)rl_refresh_view{
    return objc_getAssociatedObject(self, "rl_refresh_view");
}

- (void)setRl_load_view:(BBLoadView *)rl_load_view{
    objc_setAssociatedObject(self, "rl_load_view", rl_load_view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BBLoadView *)rl_load_view{
    return objc_getAssociatedObject(self, "rl_load_view");
}

//加刷新视图(只需要刷新)
- (void)rl_addRefreshView{
    if(self.rl_refresh_view){return;}
    self.rl_refresh_view = [[BBRefreshView alloc]init];
    [self.rl_refresh_view configure:self loadView:nil];
}

//加加载视图(只需要加载)
- (void)rl_addLoadView{
    if(self.rl_load_view){return;}
    self.rl_load_view = [[BBLoadView alloc]init];
    [self.rl_load_view configure:self refreshView:nil];
}

//刷新/加载(既需要下拉刷新，有需要上拉加载)
- (void)rl_refreshAndLoadView{
    if(self.rl_refresh_view && self.rl_load_view){return;}
    self.rl_refresh_view = [[BBRefreshView alloc]init];
    self.rl_load_view    = [[BBLoadView alloc]init];
    [self.rl_refresh_view configure:self loadView:self.rl_load_view];
    [self.rl_load_view configure:self refreshView:self.rl_refresh_view];
}

- (void)nowDealloc{
    @try {
        if(self.rl_refresh_view){
            [self removeObserver:self.rl_refresh_view forKeyPath:@"contentOffset"];
            [self.panGestureRecognizer removeObserver:self.rl_refresh_view forKeyPath:@"state"];
        }
        if(self.rl_load_view){
            [self removeObserver:self.rl_load_view forKeyPath:@"contentOffset"];
            [self removeObserver:self.rl_load_view forKeyPath:@"contentSize"];
        }
    } @catch (NSException *exception) {} @finally {}
    [self nowDealloc];
}

@end
