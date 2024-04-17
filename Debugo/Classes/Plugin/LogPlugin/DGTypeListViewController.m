//
//  DGTypeListViewController.m
//  Debugo
//
//  GitHub https://github.com/ripperhe/Debugo
//  Created by ripper on 2018/9/1.
//  Copyright © 2018年 ripper. All rights reserved.
//

#import "DGTypeListViewController.h"
#import "DGLogPlugin.h"

@interface DGTypeListViewController ()

@property (nonatomic, strong) NSMutableArray <DGLogTypeModel *>*dataArray;

@end

@implementation DGTypeListViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"左右拖动触发拖动手势";
    self.navigationItem.leftBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"放大" style:UIBarButtonItemStylePlain target:self action:@selector(growUp)],
        [[UIBarButtonItem alloc] initWithTitle:@"缩小" style:UIBarButtonItemStylePlain target:self action:@selector(growDown)],
    ];
    
    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(close)]
    ];
    
    if (!self.dataArray.count) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 80)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"现在还没有数据";
        self.tableView.tableFooterView = label;
    }else {
        self.tableView.tableFooterView = nil;
    }
}

- (void)growUp {
    [DGLogPlugin.shared.logWindow growUpHeight];
}

- (void)growDown {
    [DGLogPlugin.shared.logWindow growDownHeight];
}

- (void)close {
    [DGLogPlugin setPluginSwitch:NO];
}

#pragma mark - data
- (NSMutableArray<DGLogTypeModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DGLogTypeModel *typeModel = self.dataArray[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.detailTextLabel.textColor = kDGHighlightColor;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d", typeModel.typeID];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    kDGImpactFeedback
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DGLogTypeModel *typeModel = self.dataArray[indexPath.row];
    [DGLogPlugin setPluginSwitch:NO];
    if (DGLogPlugin.shared.configuration.executeBlock) {
        DGLogPlugin.shared.configuration.executeBlock(typeModel);
    }
}

@end
