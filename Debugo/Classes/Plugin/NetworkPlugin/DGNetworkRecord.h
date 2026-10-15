//
//  DGNetworkRecord.h
//  Debugo
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 一条被拦截的 AFNetworking 请求。
@interface DGNetworkRecord : NSObject

@property (nonatomic, copy) NSString *recordID;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, copy) NSString *requestHeaders;
@property (nonatomic, copy) NSString *requestBody;
@property (nonatomic, copy) NSString *responseHeaders;
@property (nonatomic, copy) NSString *responseBody;
@property (nonatomic, copy, nullable) NSString *errorText;

- (NSString *)timeText;
- (NSString *)durationText;
- (NSString *)statusText;
- (UIColor *)statusColor;
- (NSString *)detailText;

@end

NS_ASSUME_NONNULL_END
