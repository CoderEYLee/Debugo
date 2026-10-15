//
//  DGNetworkRecord.m
//  Debugo
//

#import "DGNetworkRecord.h"

static UIColor *DGNetworkColor(CGFloat red, CGFloat green, CGFloat blue) {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1];
}

@implementation DGNetworkRecord

- (NSString *)timeText {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    });
    return [formatter stringFromDate:self.startDate ?: [NSDate date]];
}

- (NSString *)durationText {
    if (!self.isFinished) {
        return @"...";
    }
    if (self.duration < 1) {
        return [NSString stringWithFormat:@"%.0fms", self.duration * 1000];
    }
    return [NSString stringWithFormat:@"%.2fs", self.duration];
}

- (NSString *)statusText {
    if (!self.isFinished) {
        return @"...";
    }
    if (self.statusCode <= 0) {
        return @"ERR";
    }
    return [NSString stringWithFormat:@"%ld", (long)self.statusCode];
}

- (UIColor *)statusColor {
    if (!self.isFinished) {
        return DGNetworkColor(142, 142, 147);
    }
    if (self.statusCode >= 200 && self.statusCode < 300) {
        return DGNetworkColor(52, 199, 89);
    }
    if (self.statusCode >= 300 && self.statusCode < 400) {
        return DGNetworkColor(255, 149, 0);
    }
    return DGNetworkColor(123, 97, 255);
}

- (NSString *)detailText {
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"%@ %@ %@\n", self.statusText, self.method ?: @"", self.durationText];
    [text appendFormat:@"%@\n\n", self.timeText];
    [text appendFormat:@"Uri:\n%@\n\n", self.URLString ?: @""];
    [text appendFormat:@"Request headers:\n%@\n\n", self.requestHeaders.length ? self.requestHeaders : @"(空)"];
    [text appendFormat:@"Request data:\n%@\n\n", self.requestBody.length ? self.requestBody : @"(空)"];
    [text appendFormat:@"Response headers:\n%@\n\n", self.responseHeaders.length ? self.responseHeaders : @"(空)"];
    [text appendFormat:@"Response body:\n%@", self.responseBody.length ? self.responseBody : @"(空)"];
    if (self.errorText.length) {
        [text appendFormat:@"\n\nError:\n%@", self.errorText];
    }
    return text;
}

@end
