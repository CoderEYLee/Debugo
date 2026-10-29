//
//  ViewController.m
//  Debugo-Example-ObjectiveC
//
//  Created by ripper on 2019/2/20.
//  Copyright © 2019 ripperhe. All rights reserved.
//

#import "ViewController.h"
#import "LoginViewController.h"
#import <Debugo/Debugo.h>
#import <AFNetworking/AFNetworking.h>

@interface ViewController ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sessionManager = [AFHTTPSessionManager manager];
    [DGNetworkPlugin monitorSessionManager:self.sessionManager];
    DGNetworkPlugin.listModules = DGNetworkListModuleURI | DGNetworkListModuleResponseHeaders | DGNetworkListModuleResponseBody;

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 132)];
    UIButton *logButton = [self headerButtonWithTitle:@"写入一条 Log" action:@selector(writeLog) y:16];
    UIButton *requestButton = [self headerButtonWithTitle:@"发送一条请求" action:@selector(sendRequest) y:72];
    [header addSubview:logButton];
    [header addSubview:requestButton];
    self.tableView.tableHeaderView = header;
}

- (UIButton *)headerButtonWithTitle:(NSString *)title action:(SEL)action y:(CGFloat)y {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(16, y, CGRectGetWidth(self.view.bounds) - 32, 44);
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 8;
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)writeLog {
    DGLogTypeModel *model = [DGLogTypeModel new];
    model.typeID = (int)DGLogPlugin.shared.arrayM.count + 1;
    model.dg_dic = @{
        @"message": @"来自 Example 的一条日志",
        @"time": [NSDate date].description,
    };
    [DGLogPlugin.shared addTypeModel:model];
}

- (void)sendRequest {
    [self.sessionManager GET:@"https://httpbin.org/get"
                  parameters:@{@"from": @"debugo-example"}
                     headers:nil
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"example request success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"example request failed: %@", error);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self clickGoToTestLogin];
    }
}

- (void)clickGoToTestLogin {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LoginViewController *loginVC = [board instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.navigationController pushViewController:loginVC animated:YES];
}

@end
