//
//  ViewController.m
//  BBRefresh
//
//  Created by 程肖斌 on 2019/1/28.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+refreshAndLoad.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *table_view;
@property(nonatomic, assign) NSInteger   count;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.count = 20;
    CGRect frame = self.view.bounds;
    frame.origin.y = 100;
    frame.size.height -= 150;
    self.table_view = [[UITableView alloc]initWithFrame:frame];
    self.table_view.dataSource = self;
    self.table_view.delegate   = self;
    self.table_view.backgroundColor = UIColor.grayColor;
    [self.table_view registerClass:UITableViewCell.class
            forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.table_view];
    
    [self.table_view rl_refreshAndLoadView];
    [self.table_view.rl_refresh_view addTarget:self
                                      selector:@selector(getRefreshData)];
    [self.table_view.rl_load_view addTarget:self
                                   selector:@selector(getLoadDatas)];
}

- (void)getRefreshData{
    __weak typeof(self) weak_self = self;
    long priority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
    dispatch_async(dispatch_get_global_queue(priority, 0), ^{
        [NSThread sleepForTimeInterval:3];
        dispatch_async(dispatch_get_main_queue(), ^{
            weak_self.count = 20;
            [weak_self.table_view reloadData];
            [weak_self.table_view.rl_refresh_view hasRefreshDone];
        });
    });
}

- (void)getLoadDatas{
    __weak typeof(self) weak_self = self;
    long priority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
    dispatch_async(dispatch_get_global_queue(priority, 0), ^{
        [NSThread sleepForTimeInterval:3];
        dispatch_async(dispatch_get_main_queue(), ^{
            weak_self.count += 20;
            [weak_self.table_view reloadData];
            weak_self.table_view.rl_load_view.state = BBLoadNormal;
        });
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                            forIndexPath:indexPath];
    cell.textLabel.text = @(indexPath.row).description;
    return cell;
}


@end
