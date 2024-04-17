//
//  DGLogPlugin.m
//  Debugo-Example-ObjectiveC
//
//  Created by kika on 2024/4/17.
//  Copyright © 2024 ripperhe. All rights reserved.
//

#import "DGLogPlugin.h"
#import "DGCache.h"
#import "DGLogBackViewController.h"

@interface DGLogPlugin()

@property (nonatomic, strong, nullable) DGLogWindow *logWindow;

@end

@implementation DGLogPlugin

+ (NSString *)pluginName {
    return @"Log日志";
}

+ (BOOL)pluginSwitch {
    if ([[self shared] logWindow] && [[self shared] logWindow].hidden == NO) {
        return YES;
    }
    return NO;
}

+ (void)setPluginSwitch:(BOOL)pluginSwitch {
    if (pluginSwitch) {
        if (![[self shared] logWindow]) {
            CGRect frame = CGRectMake(0, 100, UIScreen.mainScreen.bounds.size.width, 200);
            DGLogWindow *window = [[DGLogWindow alloc] initWithFrame:frame];
            window.name = @"Log Window";
            [window setHidden:NO];
            [[self shared] setLogWindow:window];
        }
        [(DGLogBackViewController *)[[self shared] logWindow].rootViewController refreshHeight:200];
        [[[self shared] logWindow] setHidden:NO];
    } else {
        if ([[self shared] logWindow]) {
            [(DGLogBackViewController *)[[self shared] logWindow].rootViewController dismissWithAnimation:^{
                [[[self shared] logWindow] destroy];
                [[self shared] setLogWindow:nil];
            }];
        }
    }
}

#pragma mark -

static DGLogPlugin *_instance;
+ (instancetype)shared {
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init];
        });
    }
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (DGLogPluginConfiguration *)configuration {
    if (!_configuration) {
        _configuration = [DGLogPluginConfiguration new];
    }
    return _configuration;
}

- (void)addTypeModel:(DGLogTypeModel *)typeModel {
    DGLogTypeModel *newTypeModel = typeModel;
    
//    for (DGLogTypeModel *model in self.currentCommonAccountArray) {
//        if (newTypeModel.typeID == model.typeID) {
//            // 重复数据 忽略
//            return;
//        }
//    }
    
    // 没有重复数据，添加到缓存中
    NSString *key = [NSString stringWithFormat:@"%d", newTypeModel.typeID];
    [self.cacheTypeDic setObject:newTypeModel forKey:key];
    // 缓存到本地
    [DGCache.shared.accountPlister setObject:newTypeModel forKey:key];
}

#pragma mark - getter

- (DGOrderedDictionary<NSString *,DGLogTypeModel *> *)cacheTypeDic {
    if (!_cacheTypeDic) {
        DGOrderedDictionary *modelDic = [DGOrderedDictionary dictionary];
        // 获取本地缓存
        NSDictionary *cacheTypeModel = [DGCache.shared.accountPlister read];
        NSArray *sortedKeys = [cacheTypeModel.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
            return [obj2 compare:obj1];
        }];
        [sortedKeys enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DGLogTypeModel *model = [[DGLogTypeModel alloc] init];
            model.typeID = 1;
            NSString *key = [NSString stringWithFormat:@"%d", model.typeID];
            [modelDic setObject:model forKey:key];
        }];
        _cacheTypeDic = modelDic;
    }
    return _cacheTypeDic;
}

@end
