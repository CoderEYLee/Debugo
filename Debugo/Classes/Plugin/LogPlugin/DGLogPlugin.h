//
//  DGLogPlugin.h
//  Debugo-Example-ObjectiveC
//
//  Created by kika on 2024/4/17.
//  Copyright © 2024 ripperhe. All rights reserved.
//

#import "DGPlugin.h"
#import "DGCommon.h"
#import "DGLogWindow.h"
#import "DGLogPluginConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

//通知名称
UIKIT_EXTERN NSString *const DebugoLogWindowNotification;

@interface DGLogPlugin : DGPlugin

@property (nonatomic, strong) DGLogPluginConfiguration *configuration;

@property (nonatomic, strong, readonly) DGLogWindow *logWindow;

+ (instancetype)shared;

- (void)addTypeModel:(DGLogTypeModel *)typeModel;

@end

NS_ASSUME_NONNULL_END
