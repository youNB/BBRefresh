//
//  BBRefreshView.m
//  BBRefresh
//
//  Created by 程肖斌 on 2019/1/28.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import "BBRefreshView.h"
#import "BBLoadView.h"

#define BB_refresh_height  80  //下拉多少才可以刷新
#define BB_spring_duration 0.3 //松开手后回弹要多久
#define BB_normal_duration 0.5 //刷新成功后多久恢复静态

@interface BBRefreshView()
@property(nonatomic, strong) UILabel *title_des;
@property(nonatomic, strong) UIView  *mask_view;

@property(nonatomic, weak) BBLoadView   *load_view;
@property(nonatomic, weak) UIScrollView *scoll_view;

@property(nonatomic, weak)   id target;
@property(nonatomic, assign) SEL selector;

@property(nonatomic, assign) UIEdgeInsets scroll_edge;
@end

@implementation BBRefreshView

- (instancetype)initWithFrame:(CGRect)frame{
    if([super initWithFrame:frame]){
        self.title_des = [[UILabel alloc]init];
        self.title_des.textAlignment = NSTextAlignmentCenter;
        self.title_des.font = [UIFont systemFontOfSize:15];
        self.title_des.textColor = UIColor.redColor;
        [self addSubview:self.title_des];
        
        self.mask_view = [[UIView alloc]init];
        [self addSubview:self.mask_view];
    }
    return self;
}

- (void)configure:(UIScrollView *)scoll_view
         loadView:(BBLoadView *)load_view{
    if(self.scoll_view){return;}//说明重复调用了
    [scoll_view addSubview:self];
    self.scoll_view = scoll_view;
    self.load_view  = load_view;
    self.mask_view.backgroundColor = scoll_view.backgroundColor;
    
    CGFloat height = scoll_view.contentInset.top;
    self.mask_view.frame = CGRectMake(0, -height, scoll_view.bounds.size.width, height);
    CGFloat HEIGHT = UIScreen.mainScreen.bounds.size.height;
    height = (HEIGHT > 800 ? 20 : 0) + BB_refresh_height;
    self.frame = CGRectMake(0, -height, scoll_view.bounds.size.width, height);
    self.title_des.frame = CGRectMake(0, self.bounds.size.height-40, self.bounds.size.width, 40);
    
    [scoll_view addObserver:self
                 forKeyPath:@"contentOffset"
                    options:NSKeyValueObservingOptionNew
                    context:NULL];
    [scoll_view.panGestureRecognizer addObserver:self
                                      forKeyPath:@"state"
                                         options:NSKeyValueObservingOptionNew
                                         context:NULL];
    self.state = BBRefreshNormal;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"state"]){
        if(self.state == BBRefreshRefresh){return;}        //正在刷新
        if(self.load_view.state == BBLoadLoading){return;} //不可与上拉加载并存
        if(![self.target respondsToSelector:self.selector]){return;}//不响应
        CGFloat Y = self.scoll_view.contentOffset.y + self.scoll_view.contentInset.top;
        if(Y > 0 || fabs(Y) < BB_refresh_height){return;} //距离不够
        UIGestureRecognizerState state = [change[@"new"] integerValue];
        if(state != UIGestureRecognizerStateEnded){return;}//非正常结束
        [self animationAndRefresh]; //可以刷新
    }
    else{
        
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)animationAndRefresh{
    __weak typeof(self) weak_self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:BB_spring_duration animations:^{
            UIEdgeInsets edge = weak_self.scoll_view.contentInset;
            CGPoint offset    = weak_self.scoll_view.contentOffset;
            weak_self.scroll_edge   = weak_self.scoll_view.contentInset;
            
            edge.top = BB_refresh_height;
            weak_self.scoll_view.contentInset = edge;
            
            offset.y = -BB_refresh_height;
            weak_self.scoll_view.contentOffset = offset;
        } completion:^(BOOL finished) {
#pragma warning---这里添加刷新时候要展示的动画
            
            //调用方法获取刷新数据
            weak_self.state = BBRefreshRefresh;
            [weak_self.target performSelector:weak_self.selector withObject:nil];//刷新
        }];
    });
}
#pragma clang diagnostic pop

- (void)hasRefreshDone{
    __weak typeof(self) weak_self = self;
    [UIView animateWithDuration:BB_normal_duration animations:^{
        weak_self.scoll_view.contentInset  = weak_self.scroll_edge;
    } completion:^(BOOL finished) {
        weak_self.state = BBRefreshNormal;
    }];
}

- (void)addTarget:(id)target selector:(SEL)selector{
    self.target   = target;
    self.selector = selector;
}

//set
- (void)setState:(BBRefresh)state{
    _state = state;
    switch (state) {
        case BBRefreshNormal:
            self.title_des.text = @"刷新完成";
            break;
            case BBRefreshRefresh:
        self.title_des.text = @"刷新中,请稍后";
            break;
        default:
            break;
    }
}

@end
