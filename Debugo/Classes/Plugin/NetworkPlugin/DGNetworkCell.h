//
//  DGNetworkCell.h
//  Debugo
//

#import <UIKit/UIKit.h>
#import "DGNetworkRecord.h"
#import "DGNetworkCenter.h"

NS_ASSUME_NONNULL_BEGIN

@interface DGNetworkCell : UITableViewCell

@property (nonatomic, strong, nullable) DGNetworkRecord *record;
/// 当前 cell 展示的模块。未设置时展示全部。
@property (nonatomic, assign) DGNetworkListModule modules;
@property (nonatomic, copy, nullable) void (^detailHandler)(DGNetworkRecord *record);

@end

NS_ASSUME_NONNULL_END
