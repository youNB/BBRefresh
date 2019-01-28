//
//  BBLoadView.h
//  BBRefresh
//
//  Created by 程肖斌 on 2019/1/28.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BBLoad) {
    BBLoadNormal,   //静态
    BBLoadLoading,  //加载中
    BBLoadFail,     //加载失败
    BBLoadNone      //没有更多数据
};

@class BBRefreshView;
@interface BBLoadView : UIView
@property(nonatomic, assign) BBLoad state;

- (void)configure:(UIScrollView *)scoll_view
      refreshView:(BBRefreshView *)refresh_view;

- (void)addTarget:(id)target selector:(SEL)selector;

- (UILabel *)configureLabel;

@end

