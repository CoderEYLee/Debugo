//
//  DGLogBackViewController.m
//  Debugo
//
//  GitHub https://github.com/ripperhe/Debugo
//  Created by ripper on 2018/9/1.
//  Copyright © 2018年 ripper. All rights reserved.
//

#import "DGLogBackViewController.h"
#import "DGTypeListViewController.h"
#import "DGNavigationController.h"
#import "DGLogPlugin.h"
#import "DGAnimationDelegate.h"

#define kBottomMargin (100.0 + kDGBottomSafeMargin)
#define kLeftMargin 10

@interface DGLogBackViewController ()

@property (nonatomic, weak) UIView *contentView;

@end

@implementation DGLogBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    DGNavigationController *navVC = [[DGNavigationController alloc] initWithRootViewController:[DGTypeListViewController new]];
    navVC.view.frame = CGRectMake(kLeftMargin,
                                  kDGScreenH,
                                  [UIScreen mainScreen].bounds.size.width - 2 * kLeftMargin,
                                  300);
    navVC.view.clipsToBounds = YES;
    [self addChildViewController:navVC];
    [self.view addSubview:navVC.view];
    self.contentView = navVC.view;
    
    [UIView animateWithDuration:.2 animations:^{
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.1];
        self.contentView.dg_y = 0;
    }];
}

- (void)refreshHeight:(CGFloat)height {
    if (nil == self.contentView) {
        return;
    }
    
    self.contentView.dg_height = height - 40;
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    self.contentView.layer.cornerRadius = 13.0;
}

- (void)dismissWithAnimation:(void (^)(void))completion {
    [UIView animateWithDuration:.2 animations:^{
        self.contentView.dg_y = kDGScreenH;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

@end
