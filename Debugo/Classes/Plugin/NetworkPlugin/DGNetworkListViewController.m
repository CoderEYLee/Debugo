//
//  DGNetworkListViewController.m
//  Debugo
//

#import "DGNetworkListViewController.h"
#import "DGNetworkCell.h"
#import "DGNetworkCenter.h"
#import "DGNetworkDetailViewController.h"
#import "DGNetworkLayout.h"
#import "DGTool.h"

@interface DGNetworkListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, copy) NSArray<DGNetworkRecord *> *records;

@end

@implementation DGNetworkListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"网络请求拦截";
    self.view.backgroundColor = kDGBackgroundColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(clearRecords)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:108 / 255.0 green:92 / 255.0 blue:231 / 255.0 alpha:1];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 280;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.contentInset = UIEdgeInsetsMake(6, 0, 12, 0);
    [tableView registerClass:DGNetworkCell.class forCellReuseIdentifier:NSStringFromClass(DGNetworkCell.class)];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    DGNetworkPinEdges(tableView, self.view, UIEdgeInsetsZero);

    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.text = @"还没有请求\n业务方传入 AFURLSessionManager 后，对应请求会显示在这里";
    emptyLabel.numberOfLines = 0;
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.font = [UIFont systemFontOfSize:15];
    emptyLabel.textColor = [UIColor grayColor];
    [self.view addSubview:emptyLabel];
    self.emptyLabel = emptyLabel;
    DGNetworkDisableAutoresizing(emptyLabel);
    [NSLayoutConstraint activateConstraints:@[
        DGNetworkConstraint(emptyLabel, NSLayoutAttributeCenterX, NSLayoutRelationEqual, self.view, NSLayoutAttributeCenterX, 0),
        DGNetworkConstraint(emptyLabel, NSLayoutAttributeCenterY, NSLayoutRelationEqual, self.view, NSLayoutAttributeCenterY, 0),
        DGNetworkConstraint(emptyLabel, NSLayoutAttributeLeft, NSLayoutRelationGreaterThanOrEqual, self.view, NSLayoutAttributeLeft, 32),
        DGNetworkConstraint(self.view, NSLayoutAttributeRight, NSLayoutRelationGreaterThanOrEqual, emptyLabel, NSLayoutAttributeRight, 32),
    ]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRecords) name:DGNetworkRecordsDidChangeNotification object:nil];
    [self reloadRecords];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)reloadRecords {
    self.records = [DGNetworkCenter.sharedCenter allRecords];
    self.emptyLabel.hidden = self.records.count > 0;
    [self.tableView reloadData];
}

- (void)clearRecords {
    [DGNetworkCenter.sharedCenter clearRecords];
}

- (void)openDetail:(DGNetworkRecord *)record {
    DGNetworkDetailViewController *viewController = [[DGNetworkDetailViewController alloc] initWithRecord:record];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DGNetworkCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(DGNetworkCell.class) forIndexPath:indexPath];
    DGNetworkRecord *record = self.records[indexPath.row];
    cell.modules = DGNetworkCenter.sharedCenter.listModules;
    cell.record = record;
    dg_weakify(self)
    cell.detailHandler = ^(DGNetworkRecord *selected) {
        dg_strongify(self)
        [self openDetail:selected];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self openDetail:self.records[indexPath.row]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
