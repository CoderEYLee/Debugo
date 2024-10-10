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

NSString *const DebugoLogWindowNotification=@"DebugoLogWindowNotification";

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
    if (nil == typeModel) {
        return;
    }
    [NSNotificationCenter.defaultCenter postNotificationName:DebugoLogWindowNotification object:self userInfo:@{@"typeModel": typeModel}];
}

@end
