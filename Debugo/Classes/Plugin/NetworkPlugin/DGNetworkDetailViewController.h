//
//  DGNetworkDetailViewController.h
//  Debugo
//

#import <UIKit/UIKit.h>
#import "DGNetworkRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface DGNetworkDetailViewController : UIViewController

- (instancetype)initWithRecord:(DGNetworkRecord *)record;

@end

NS_ASSUME_NONNULL_END
