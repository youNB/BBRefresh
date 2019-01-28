//
//  BBRefreshView.h
//  BBRefresh
//
//  Created by 程肖斌 on 2019/1/28.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BBRefresh) {
    BBRefreshNormal,    //静态
    BBRefreshRefresh    //刷新态
};

@class BBLoadView;
@interface BBRefreshView : UIView
@property(nonatomic, assign) BBRefresh state;

- (void)configure:(UIScrollView *)scoll_view
         loadView:(BBLoadView *)load_view;

- (void)hasRefreshDone; //刷新结束后要调用这个方法

- (void)addTarget:(id)target selector:(SEL)selector;

@end

