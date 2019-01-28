//
//  BBLoadView.m
//  BBRefresh
//
//  Created by 程肖斌 on 2019/1/28.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import "BBLoadView.h"
#import "BBRefreshView.h"

#define BB_load_height 60 //加载view的高度

@interface BBLoadView()
@property(nonatomic, strong) UILabel *title_des;
@property(nonatomic, strong) UIActivityIndicatorView *indicator;

@property(nonatomic, weak) BBRefreshView *refresh_view;
@property(nonatomic, weak) UIScrollView  *scroll_view;

@property(nonatomic, weak)   id target;
@property(nonatomic, assign) SEL selector;
@end

@implementation BBLoadView

- (instancetype)initWithFrame:(CGRect)frame{
    if([super initWithFrame:frame]){
        self.title_des = [[UILabel alloc]init];
        self.title_des.textAlignment = NSTextAlignmentCenter;
        self.title_des.font = [UIFont systemFontOfSize:15];
        self.title_des.textColor = UIColor.blackColor;
        [self addSubview:self.title_des];
        
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.indicator];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.title_des sizeToFit];
    CGFloat length = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    if(self.indicator.hidden){self.title_des.frame = self.bounds;}
    else{
        CGFloat len = self.title_des.bounds.size.width+10;
        self.indicator.center = CGPointMake(length/2-len/2-15, height/2);
        self.title_des.frame = CGRectMake(length/2-len/2, height/2-10, len, 20);
    }
}

- (void)configure:(UIScrollView *)scoll_view
      refreshView:(BBRefreshView *)refresh_view{
    if(self.scroll_view){return ;} //防止重复调用该方法
    [scoll_view addSubview:self];
    self.scroll_view  = scoll_view;
    self.refresh_view = refresh_view;
    
    UIEdgeInsets edge = self.scroll_view.contentInset;
    edge.bottom = BB_load_height;
    self.scroll_view.contentInset = edge;
    self.frame = CGRectMake(0, self.scroll_view.contentSize.height, self.scroll_view.bounds.size.width, BB_load_height);
    
    [self.scroll_view addObserver:self
                       forKeyPath:@"contentOffset"
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
    [self.scroll_view addObserver:self
                       forKeyPath:@"contentSize"
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
    self.state = BBLoadNormal;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"contentSize"]){
        self.frame = CGRectMake(0, self.scroll_view.contentSize.height, self.scroll_view.bounds.size.width, 60);
    }
    else{
        CGFloat Y   = self.scroll_view.contentOffset.y;
        CGFloat add = Y + self.scroll_view.bounds.size.height + self.bounds.size.height;
        if(Y < 0){return;}  //必须要上拉才允许加载
        if(add < self.scroll_view.contentSize.height){return;}//上拉的不够
        if(self.state != BBLoadNormal){return;}//不可加载
        if(self.refresh_view.state == BBRefreshRefresh){return;}//不可共存
        if(![self.target respondsToSelector:self.selector]){return;}//不可响应
        self.state = BBLoadLoading;
        [self.target performSelector:self.selector withObject:nil];
    }
}

- (void)clickToGetMore{
    if(self.state != BBLoadFail){return;}
    if(self.refresh_view.state == BBRefreshRefresh){return;}
    if(![self.target respondsToSelector:self.selector]){return;}
    [self.target performSelector:self.selector withObject:nil];
}
#pragma clang diagnostic pop

- (void)addTarget:(id)target selector:(SEL)selector{
    self.target   = target;
    self.selector = selector;
}

- (UILabel *)configureLabel{
    return self.title_des;
}

//set
- (void)setState:(BBLoad)state{
    _state = state;
    switch (state) {
        case BBLoadNormal:
            self.title_des.text = @"上拉加载更多";
            break;
        case BBLoadLoading:
            self.title_des.text = @"正在加载更多";
            break;
        case BBLoadFail:
            self.title_des.text = @"加载失败,点击重试";
            break;
        case BBLoadNone:
            self.title_des.text = @"暂无更多数据";
            break;
        default:
            break;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
