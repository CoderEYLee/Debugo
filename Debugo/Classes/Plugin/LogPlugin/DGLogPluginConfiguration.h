//
//  DGLogPluginConfiguration.h
//  Debugo-Example-ObjectiveC
//
//  Created by kika on 2024/4/17.
//  Copyright © 2024 ripperhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DGLogTypeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DGLogPluginConfiguration : NSObject

/** 使用 login bubble 选中列表时，会调用这个 block，并传回模型信息，你需要在这个 block 中实现业务 */
@property (nonatomic, copy) void(^executeBlock)(DGLogTypeModel *typeModel);

@end

NS_ASSUME_NONNULL_END
