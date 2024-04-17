//
//  DGLogWindow.m
//  Debugo
//
//  GitHub https://github.com/ripperhe/Debugo
//  Created by ripper on 2018/9/1.
//  Copyright © 2018年 ripper. All rights reserved.
//


#import "DGLogWindow.h"
#import "DGCommon.h"
#import "DGLogBackViewController.h"

#define DGLogWindowIsIPhoneX ([[UIScreen mainScreen] nativeBounds].size.height >= 2436.0)
#define DGLogWindowTopMargin (DGLogWindowIsIPhoneX ? 88.0 : 64.0)
#define DGLogWindowBottomMargin (DGLogWindowIsIPhoneX ? 83.0 : 49.0)

@interface DGLogWindow()

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, copy) NSString *memoryAddressKey;

@end

@implementation DGLogWindow

- (void)dealloc {
    DGLogFunction;
}

- (instancetype)initWithFrame:(CGRect)frame {
    // update center
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    CGPoint newCenter = [DGLogWindow checkNewCenterWithPoint:center size:frame.size];
    CGFloat w = frame.size.width;
    CGFloat h = frame.size.height;
    frame = CGRectMake(newCenter.x - w * 0.5, newCenter.y - h * 0.5, w, h);
    
    if(self = [super initWithFrame:frame]) {
        self.windowLevel = 1000000;
        // rootViewController
        self.rootViewController = [[DGLogBackViewController alloc] init];
        
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.isDragging == NO) {
        // deal rotate
        CGPoint newCenter = [DGLogWindow checkNewCenterWithPoint:self.center size:self.frame.size];
        if (CGPointEqualToPoint(newCenter, self.center) == NO) {
            self.center = newCenter;
        }
    }
}

- (void)setupUI {
    // pan
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.contentView addGestureRecognizer:pan];
}

/// 变大
- (void)growUpHeight {
    CGFloat minH = 100;
    CGFloat maxH = UIScreen.mainScreen.bounds.size.height - DGLogWindowTopMargin - DGLogWindowBottomMargin;
    CGFloat height = self.dg_height;
    height += 30;
    if (height > maxH) {
        height = maxH;
    }
    
    if (height < minH) {
        height = minH;
    }
    
    self.dg_height = height;
}

/// 变小
- (void)growDownHeight {
    CGFloat minH = 100;
    CGFloat maxH = UIScreen.mainScreen.bounds.size.height - DGLogWindowTopMargin - DGLogWindowBottomMargin;
    CGFloat height = self.dg_height;
    height -= 30;
    if (height > maxH) {
        height = maxH;
    }
    
    if (height < minH) {
        height = minH;
    }
    
    self.dg_height = height;
}

#pragma mark - getter
- (UIView *)contentView {
    return self.rootViewController.view;
}

- (NSString *)memoryAddressKey {
    if (!_memoryAddressKey) {
        _memoryAddressKey = [NSString stringWithFormat:@"%@_%p", NSStringFromClass([self class]), self];
    }
    return _memoryAddressKey;
}

#pragma mark - event response
- (void)handlePanGesture:(UIPanGestureRecognizer*)p {
    UIWindow *appWindow = dg_mainWindow();
    CGPoint panPoint = [p locationInView:appWindow];
    
    if (p.state == UIGestureRecognizerStateBegan) {
        self.isDragging = YES;
        self.contentView.alpha = 1;
    } else if (p.state == UIGestureRecognizerStateChanged) {
        self.center = CGPointMake(panPoint.x, panPoint.y);
    } else if (p.state == UIGestureRecognizerStateEnded
             || p.state == UIGestureRecognizerStateCancelled) {
        CGPoint newCenter = [DGLogWindow checkNewCenterWithPoint:panPoint size:self.frame.size];
        [UIView animateWithDuration:.25 animations:^{
            self.center = newCenter;
        } completion:^(BOOL finished) {
            self.isDragging = NO;
        }];
    } else {
        DGLog(@"%@ pan state : %zd", self, p.state);
    }
}

#pragma mark - private methods
+ (CGPoint)checkNewCenterWithPoint:(CGPoint)point size:(CGSize)size {
    CGFloat ballWidth = size.width;
    CGFloat ballHeight = size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    CGFloat left = fabs(point.x);
    CGFloat right = fabs(screenWidth - left);
    
    CGPoint newCenter = CGPointZero;
    CGFloat targetY = 0;
    
    //Correcting Y
    if (point.y < DGLogWindowTopMargin + ballHeight / 2.0) {
        targetY = DGLogWindowTopMargin + ballHeight / 2.0;
    } else if (point.y > (screenHeight - ballHeight / 2.0 - DGLogWindowBottomMargin)) {
        targetY = screenHeight - ballHeight / 2.0 - DGLogWindowBottomMargin;
    } else {
        targetY = point.y;
    }
    
    CGFloat centerXSpace = (0.5 - 0) * ballWidth;
    
    if (left <= right) {
        newCenter = CGPointMake(centerXSpace, targetY);
    } else {
        newCenter = CGPointMake(screenWidth - centerXSpace, targetY);
    }
    
    return newCenter;
}

@end
