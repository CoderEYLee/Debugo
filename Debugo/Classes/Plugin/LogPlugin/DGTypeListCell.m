//
//  DGTypeListCell.m
//  Debugo
//
//  Created by Atlas on 2024/10/9.
//

#import "DGTypeListCell.h"

@implementation DGTypeListCell

- (void)setLogTypeModel:(DGLogTypeModel *)logTypeModel {
    _logTypeModel = logTypeModel;
    self.textLabel.numberOfLines = 0;
    self.detailTextLabel.numberOfLines = 0;
    self.textLabel.text = [NSString stringWithFormat:@"#%d", logTypeModel.typeID];
    self.detailTextLabel.text = logTypeModel.dg_dic.count ? logTypeModel.dg_dic.description : @"";
}

@end
