//
//  DGNetworkCenter.m
//  Debugo
//

#import "DGNetworkCenter.h"
#import <objc/runtime.h>

NSNotificationName const DGNetworkRecordsDidChangeNotification = @"DGNetworkRecordsDidChangeNotification";

static NSString * const DGNetworkTaskDidResumeNotification = @"com.alamofire.networking.task.resume";
static NSString * const DGNetworkTaskDidCompleteNotification = @"com.alamofire.networking.task.complete";
static NSString * const DGNetworkTaskDidCompleteSerializedResponseKey = @"com.alamofire.networking.task.complete.serializedresponse";
static NSString * const DGNetworkTaskDidCompleteResponseDataKey = @"com.alamofire.networking.complete.finish.responsedata";
static NSString * const DGNetworkTaskDidCompleteErrorKey = @"com.alamofire.networking.task.complete.error";
static NSString * const DGNetworkTaskDidCompleteSessionTaskMetrics = @"com.alamofire.networking.complete.sessiontaskmetrics";

static const void *kDGNetworkRecordKey = &kDGNetworkRecordKey;
static const void *kDGNetworkRequestBodyKey = &kDGNetworkRequestBodyKey;
static const NSUInteger kDGNetworkRecordLimit = 200;
static const NSUInteger kDGNetworkBodyLimit = 100 * 1024;

typedef NSURLSessionDataTask *(*DGNetworkDataTaskIMP)(id, SEL, NSURLRequest *, id, id, id);
static DGNetworkDataTaskIMP dg_originalDataTaskIMP = NULL;

static NSString *DGNetworkLimitedText(NSString *text) {
    if (text.length <= kDGNetworkBodyLimit) {
        return text ?: @"";
    }
    return [[text substringToIndex:kDGNetworkBodyLimit] stringByAppendingString:@"\n…(已截断)"];
}

static NSString *DGNetworkPrettyText(id object) {
    if (!object || object == (id)kCFNull) {
        return @"";
    }
    if ([object isKindOfClass:NSString.class]) {
        NSData *data = [(NSString *)object dataUsingEncoding:NSUTF8StringEncoding];
        id json = data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] : nil;
        if (json && ![json isKindOfClass:NSString.class]) {
            return DGNetworkPrettyText(json);
        }
        return DGNetworkLimitedText(object);
    }
    if ([object isKindOfClass:NSData.class]) {
        NSData *data = object;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (json && ![json isKindOfClass:NSString.class] && ![json isKindOfClass:NSData.class]) {
            return DGNetworkPrettyText(json);
        }
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (string.length) {
            return DGNetworkLimitedText(string);
        }
        return [NSString stringWithFormat:@"<binary %lu bytes>", (unsigned long)data.length];
    }
    if ([NSJSONSerialization isValidJSONObject:object]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
        if (data) {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return DGNetworkLimitedText(string);
        }
    }
    return DGNetworkLimitedText([object description]);
}

/// NSURLSession 创建任务后，HTTPBody 经常会被收成 HTTPBodyStream。
/// 流只能读一次，所以在 dataTask 创建前把 body 留一份。
static NSData *DGNetworkSnapshotRequestBody(NSURLRequest *request) {
    if (request.HTTPBody.length > 0) {
        return request.HTTPBody;
    }
    NSInputStream *stream = request.HTTPBodyStream;
    if (!stream || ![request isKindOfClass:NSMutableURLRequest.class]) {
        return nil;
    }

    [stream open];
    if (stream.streamStatus == NSStreamStatusError || stream.streamStatus == NSStreamStatusNotOpen) {
        return nil;
    }

    NSMutableData *data = [NSMutableData data];
    uint8_t buffer[16 * 1024];
    while (1) {
        NSInteger count = [stream read:buffer maxLength:sizeof(buffer)];
        if (count <= 0) {
            break;
        }
        [data appendBytes:buffer length:(NSUInteger)count];
    }
    [stream close];
    [(NSMutableURLRequest *)request setHTTPBodyStream:[[NSInputStream alloc] initWithData:data]];
    return data;
}

static NSString *DGNetworkRequestBodyText(NSURLSessionTask *task) {
    NSData *body = objc_getAssociatedObject(task, kDGNetworkRequestBodyKey);
    if (![body isKindOfClass:NSData.class] || body.length == 0) {
        body = task.originalRequest.HTTPBody;
    }
    if (body.length == 0) {
        body = task.currentRequest.HTTPBody;
    }
    if (body.length > 0) {
        return DGNetworkPrettyText(body);
    }
    if (task.originalRequest.HTTPBodyStream || task.currentRequest.HTTPBodyStream) {
        return @"(body stream，未读取以免消费请求体)";
    }
    return @"";
}

static NSString *DGNetworkHeaderText(NSDictionary *headers) {
    if (headers.count == 0) {
        return @"";
    }
    NSArray *keys = [headers.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableArray<NSString *> *lines = [NSMutableArray arrayWithCapacity:keys.count];
    for (id key in keys) {
        [lines addObject:[NSString stringWithFormat:@"%@: %@", key, headers[key]]];
    }
    return [lines componentsJoinedByString:@"\n"];
}

@interface DGNetworkCenter ()

@property (nonatomic, strong) NSHashTable *managers;
@property (nonatomic, strong) NSMutableArray<DGNetworkRecord *> *records;
@property (nonatomic, assign) BOOL observing;

- (BOOL)dg_isMonitoringManager:(id)manager;

@end

static NSURLSessionDataTask *DGNetworkSwizzledDataTask(id self, SEL _cmd, NSURLRequest *request, id uploadProgress, id downloadProgress, id completionHandler) {
    NSData *body = nil;
    if ([DGNetworkCenter.sharedCenter dg_isMonitoringManager:self]) {
        body = DGNetworkSnapshotRequestBody(request);
    }
    NSURLSessionDataTask *task = dg_originalDataTaskIMP ? dg_originalDataTaskIMP(self, _cmd, request, uploadProgress, downloadProgress, completionHandler) : nil;
    if (task && body.length > 0) {
        objc_setAssociatedObject(task, kDGNetworkRequestBodyKey, body, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return task;
}

static void DGNetworkInstallDataTaskHook(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"AFURLSessionManager");
        SEL sel = @selector(dataTaskWithRequest:uploadProgress:downloadProgress:completionHandler:);
        Method method = class_getInstanceMethod(cls, sel);
        if (!method) {
            return;
        }
        dg_originalDataTaskIMP = (DGNetworkDataTaskIMP)method_setImplementation(method, (IMP)DGNetworkSwizzledDataTask);
    });
}

@implementation DGNetworkCenter

+ (instancetype)sharedCenter {
    static DGNetworkCenter *center = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[DGNetworkCenter alloc] init];
    });
    return center;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _managers = [NSHashTable weakObjectsHashTable];
        _records = [NSMutableArray array];
        _listModules = DGNetworkListModuleAll;
    }
    return self;
}

- (void)monitorSessionManager:(AFURLSessionManager *)sessionManager {
    Class managerClass = NSClassFromString(@"AFURLSessionManager");
    id manager = sessionManager;
    if (!managerClass || ![manager isKindOfClass:managerClass]) {
        return;
    }
    DGNetworkInstallDataTaskHook();
    @synchronized (self.managers) {
        [self.managers addObject:manager];
    }
    if (NSThread.isMainThread) {
        [self startObservingIfNeeded];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startObservingIfNeeded];
        });
    }
}

- (BOOL)dg_isMonitoringManager:(id)manager {
    if (!manager) {
        return NO;
    }
    @synchronized (self.managers) {
        return [self.managers containsObject:manager];
    }
}

- (NSArray<DGNetworkRecord *> *)allRecords {
    if (!NSThread.isMainThread) {
        __block NSArray<DGNetworkRecord *> *records = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            records = [self.records copy];
        });
        return records;
    }
    return [self.records copy];
}

- (void)setListModules:(DGNetworkListModule)listModules {
    if (_listModules == listModules) {
        return;
    }
    _listModules = listModules;
    if (NSThread.isMainThread) {
        [self postChange];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postChange];
        });
    }
}

- (void)clearRecords {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.records removeAllObjects];
        [self postChange];
    });
}

#pragma mark - Observe

- (void)startObservingIfNeeded {
    if (self.observing) {
        return;
    }
    self.observing = YES;
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self selector:@selector(taskDidResume:) name:DGNetworkTaskDidResumeNotification object:nil];
    [center addObserver:self selector:@selector(taskDidComplete:) name:DGNetworkTaskDidCompleteNotification object:nil];
}

- (nullable id)managerForTask:(NSURLSessionTask *)task {
    if (![task isKindOfClass:NSURLSessionTask.class]) {
        return nil;
    }
    NSString *description = task.taskDescription;
    if (description.length == 0) {
        return nil;
    }
    @synchronized (self.managers) {
        for (id manager in self.managers) {
            NSString *expected = [NSString stringWithFormat:@"%p", manager];
            if ([description isEqualToString:expected]) {
                return manager;
            }
        }
    }
    return nil;
}

- (void)taskDidResume:(NSNotification *)notification {
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self taskDidResume:notification];
        });
        return;
    }
    NSURLSessionTask *task = notification.object;
    if (![self managerForTask:task]) {
        return;
    }
    if (objc_getAssociatedObject(task, kDGNetworkRecordKey)) {
        return;
    }
    DGNetworkRecord *record = [self recordForTask:task];
    objc_setAssociatedObject(task, kDGNetworkRecordKey, record, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self insertRecord:record];
}

- (void)taskDidComplete:(NSNotification *)notification {
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self taskDidComplete:notification];
        });
        return;
    }
    NSURLSessionTask *task = notification.object;
    if (![self managerForTask:task]) {
        return;
    }
    DGNetworkRecord *record = objc_getAssociatedObject(task, kDGNetworkRecordKey);
    BOOL inserted = NO;
    if (!record) {
        record = [self recordForTask:task];
        objc_setAssociatedObject(task, kDGNetworkRecordKey, record, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        inserted = YES;
    }
    [self fillRecord:record task:task userInfo:notification.userInfo];
    if (inserted || ![self.records containsObject:record]) {
        [self insertRecord:record];
    } else {
        [self postChange];
    }
}

- (DGNetworkRecord *)recordForTask:(NSURLSessionTask *)task {
    NSURLRequest *request = task.currentRequest ?: task.originalRequest;
    DGNetworkRecord *record = [[DGNetworkRecord alloc] init];
    record.recordID = [NSString stringWithFormat:@"%p-%lu", task, (unsigned long)task.taskIdentifier];
    record.startDate = [NSDate date];
    record.method = request.HTTPMethod.uppercaseString ?: @"";
    record.URLString = request.URL.absoluteString ?: @"";
    record.requestHeaders = DGNetworkHeaderText(request.allHTTPHeaderFields);
    record.requestBody = DGNetworkRequestBodyText(task);
    return record;
}

- (void)fillRecord:(DGNetworkRecord *)record task:(NSURLSessionTask *)task userInfo:(NSDictionary *)userInfo {
    NSURLRequest *request = task.currentRequest ?: task.originalRequest;
    if (request.URL.absoluteString.length) {
        record.URLString = request.URL.absoluteString;
    }
    if (request.HTTPMethod.length) {
        record.method = request.HTTPMethod.uppercaseString;
    }
    if (request.allHTTPHeaderFields.count) {
        record.requestHeaders = DGNetworkHeaderText(request.allHTTPHeaderFields);
    }
    NSString *requestBody = DGNetworkRequestBodyText(task);
    if (requestBody.length > 0) {
        record.requestBody = requestBody;
    }

    if ([task.response isKindOfClass:NSHTTPURLResponse.class]) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        record.statusCode = response.statusCode;
        record.responseHeaders = DGNetworkHeaderText(response.allHeaderFields);
    }

    if (@available(iOS 10.0, *)) {
        NSURLSessionTaskMetrics *metrics = userInfo[DGNetworkTaskDidCompleteSessionTaskMetrics];
        if ([metrics isKindOfClass:NSURLSessionTaskMetrics.class] && metrics.taskInterval.duration > 0) {
            record.duration = metrics.taskInterval.duration;
        } else if (record.startDate) {
            record.duration = [[NSDate date] timeIntervalSinceDate:record.startDate];
        }
    } else if (record.startDate) {
        record.duration = [[NSDate date] timeIntervalSinceDate:record.startDate];
    }

    id serialized = userInfo[DGNetworkTaskDidCompleteSerializedResponseKey];
    NSData *data = userInfo[DGNetworkTaskDidCompleteResponseDataKey];
    if (serialized) {
        record.responseBody = DGNetworkPrettyText(serialized);
    } else if ([data isKindOfClass:NSData.class]) {
        record.responseBody = DGNetworkPrettyText(data);
    } else {
        record.responseBody = @"";
    }

    NSError *error = userInfo[DGNetworkTaskDidCompleteErrorKey];
    record.errorText = [error isKindOfClass:NSError.class] ? error.localizedDescription : nil;
    record.finished = YES;
}

- (void)insertRecord:(DGNetworkRecord *)record {
    [self.records insertObject:record atIndex:0];
    if (self.records.count > kDGNetworkRecordLimit) {
        [self.records removeObjectsInRange:NSMakeRange(kDGNetworkRecordLimit, self.records.count - kDGNetworkRecordLimit)];
    }
    [self postChange];
}

- (void)postChange {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGNetworkRecordsDidChangeNotification object:self];
}

@end
