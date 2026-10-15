//
//  DGNetworkPlugin.m
//  Debugo
//

#import "DGNetworkPlugin.h"
#import "DGNetworkCenter.h"
#import "DGNetworkListViewController.h"

@implementation DGNetworkPlugin

+ (void)monitorSessionManager:(AFURLSessionManager *)sessionManager {
    [DGNetworkCenter.sharedCenter monitorSessionManager:sessionManager];
}

+ (DGNetworkListModule)listModules {
    return DGNetworkCenter.sharedCenter.listModules;
}

+ (void)setListModules:(DGNetworkListModule)listModules {
    DGNetworkCenter.sharedCenter.listModules = listModules;
}

+ (UIImage *)pluginImage {
    UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:34 weight:UIImageSymbolWeightRegular];
    UIImage *image = [UIImage systemImageNamed:@"network" withConfiguration:configuration];
    UIColor *color = [UIColor colorWithRed:108 / 255.0 green:92 / 255.0 blue:231 / 255.0 alpha:1];
    return [image imageWithTintColor:color renderingMode:UIImageRenderingModeAlwaysOriginal];
}

+ (NSString *)pluginName {
    return @"网络请求";
}

+ (UIViewController *)pluginViewController {
    return [DGNetworkListViewController new];
}

@end
