//
//  UIScrollView+refreshAndLoad.h
//  BBRefresh
//
//  Created by 程肖斌 on 2019/1/28.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBLoadView.h"
#import "BBRefreshView.h"

@interface UIScrollView (refreshAndLoad)
@property(nonatomic, strong) BBRefreshView *rl_refresh_view;
@property(nonatomic, strong) BBLoadView    *rl_load_view;

//加刷新视图(只需要刷新)
- (void)rl_addRefreshView;

//加加载视图(只需要加载)
- (void)rl_addLoadView;

//刷新/加载(既需要下拉刷新，有需要上拉加载)
- (void)rl_refreshAndLoadView;

@end

