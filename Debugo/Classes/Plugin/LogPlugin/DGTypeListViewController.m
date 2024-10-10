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
#import "DGTypeListCell.h"

@interface DGTypeListViewController ()

@property (nonatomic, strong) NSMutableArray <DGLogTypeModel *>*dataArray;

@end

@implementation DGTypeListViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"左右拖动";
    self.navigationItem.leftBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"放大" style:UIBarButtonItemStylePlain target:self action:@selector(growUp)],
        [[UIBarButtonItem alloc] initWithTitle:@"缩小" style:UIBarButtonItemStylePlain target:self action:@selector(growDown)],
    ];
    
    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"clear" style:UIBarButtonItemStylePlain target:self action:@selector(clear)],
        [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(close)],
    ];
    
    //添加通知
    [self addNoti];
}

- (void)growUp {
    [DGLogPlugin.shared.logWindow growUpHeight];
}

- (void)growDown {
    [DGLogPlugin.shared.logWindow growDownHeight];
}

- (void)clear {
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
}

- (void)close {
    [DGLogPlugin setPluginSwitch:NO];
}

- (void)addNoti {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDebugoLogWindowNoti:) name:DebugoLogWindowNotification object:nil];
}

- (void)receiveDebugoLogWindowNoti:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    DGLogTypeModel *typeModel = userInfo[@"typeModel"];
    [self.dataArray addObject:typeModel];
    [self.tableView reloadData];
    
    NSIndexPath *last = [NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:last atScrollPosition:UITableViewScrollPositionBottom animated:NO];
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
    DGTypeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DGTypeListViewControllerCell"];
    if (!cell) {
        Class cls = NSClassFromString(DGLogPlugin.shared.configuration.cellClsString);
        if (cls) {
            cell = [[cls alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DGTypeListViewControllerCell"];
        } else {
            cell = [[DGTypeListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DGTypeListViewControllerCell"];
        }
        cell.detailTextLabel.textColor = kDGHighlightColor;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d", typeModel.typeID];
    cell.logTypeModel = typeModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    kDGImpactFeedback
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DGLogTypeModel *typeModel = self.dataArray[indexPath.row];
    if (DGLogPlugin.shared.configuration.executeBlock) {
        DGLogPlugin.shared.configuration.executeBlock(typeModel);
    }
}

@end
