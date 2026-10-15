//
//  DGNetworkCenter.h
//  Debugo
//

#import <Foundation/Foundation.h>
#import "DGNetworkRecord.h"

@class AFURLSessionManager;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSNotificationName const DGNetworkRecordsDidChangeNotification;

/// 列表卡片里可单独开关的内容。详情页始终展示全部。
typedef NS_OPTIONS(NSUInteger, DGNetworkListModule) {
    /// 请求地址
    DGNetworkListModuleURI              = 1 << 0,
    /// 请求头
    DGNetworkListModuleRequestHeaders   = 1 << 1,
    /// 请求体
    DGNetworkListModuleRequestData      = 1 << 2,
    /// 响应头
    DGNetworkListModuleResponseHeaders  = 1 << 3,
    /// 响应体
    DGNetworkListModuleResponseBody     = 1 << 4,
    /// 以上全部模块
    DGNetworkListModuleAll              = DGNetworkListModuleURI | DGNetworkListModuleRequestHeaders | DGNetworkListModuleRequestData | DGNetworkListModuleResponseHeaders | DGNetworkListModuleResponseBody,
};

/// 按传入的 AFURLSessionManager 拦截请求。调试器不持有 manager。
@interface DGNetworkCenter : NSObject

+ (instancetype)sharedCenter;

/// 列表 cell 展示的模块，默认 DGNetworkListModuleAll。
@property (nonatomic, assign) DGNetworkListModule listModules;

- (void)monitorSessionManager:(AFURLSessionManager *)sessionManager;

- (NSArray<DGNetworkRecord *> *)allRecords;

- (void)clearRecords;

@end

NS_ASSUME_NONNULL_END
