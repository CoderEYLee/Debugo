//
//  DGNetworkLayout.h
//  Debugo
//

#import <UIKit/UIKit.h>

NS_INLINE void DGNetworkDisableAutoresizing(UIView *view) {
    view.translatesAutoresizingMaskIntoConstraints = NO;
}

NS_INLINE NSLayoutConstraint *DGNetworkConstraint(id item, NSLayoutAttribute attribute, NSLayoutRelation relation, id toItem, NSLayoutAttribute toAttribute, CGFloat constant) {
    return [NSLayoutConstraint constraintWithItem:item attribute:attribute relatedBy:relation toItem:toItem attribute:toAttribute multiplier:1 constant:constant];
}

NS_INLINE void DGNetworkPinEdges(UIView *view, UIView *container, UIEdgeInsets insets) {
    DGNetworkDisableAutoresizing(view);
    [NSLayoutConstraint activateConstraints:@[
        DGNetworkConstraint(view, NSLayoutAttributeTop, NSLayoutRelationEqual, container, NSLayoutAttributeTop, insets.top),
        DGNetworkConstraint(view, NSLayoutAttributeLeft, NSLayoutRelationEqual, container, NSLayoutAttributeLeft, insets.left),
        DGNetworkConstraint(container, NSLayoutAttributeBottom, NSLayoutRelationEqual, view, NSLayoutAttributeBottom, insets.bottom),
        DGNetworkConstraint(container, NSLayoutAttributeRight, NSLayoutRelationEqual, view, NSLayoutAttributeRight, insets.right),
    ]];
}

NS_INLINE void DGNetworkPinHorizontal(UIView *view, UIView *container, CGFloat inset) {
    DGNetworkDisableAutoresizing(view);
    [NSLayoutConstraint activateConstraints:@[
        DGNetworkConstraint(view, NSLayoutAttributeLeft, NSLayoutRelationEqual, container, NSLayoutAttributeLeft, inset),
        DGNetworkConstraint(container, NSLayoutAttributeRight, NSLayoutRelationEqual, view, NSLayoutAttributeRight, inset),
    ]];
}
