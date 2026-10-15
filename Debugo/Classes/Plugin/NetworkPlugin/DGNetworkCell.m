//
//  DGNetworkCell.m
//  Debugo
//

#import "DGNetworkCell.h"
#import "DGNetworkLayout.h"

static UIColor *DGNetworkPurple(void) {
    return [UIColor colorWithRed:108 / 255.0 green:92 / 255.0 blue:231 / 255.0 alpha:1];
}

@interface DGNetworkInsetLabel : UILabel
@end

@implementation DGNetworkInsetLabel

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    return CGSizeMake(size.width + 14, 22);
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 7, 0, 7))];
}

@end

@interface DGNetworkCell ()

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) DGNetworkInsetLabel *statusLabel;
@property (nonatomic, strong) UILabel *methodLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIButton *detailButton;
@property (nonatomic, strong) UILabel *uriLabel;
@property (nonatomic, strong) UIView *headersModuleView;
@property (nonatomic, strong) UILabel *headersLabel;
@property (nonatomic, strong) UIView *requestDataModuleView;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIView *responseHeadersModuleView;
@property (nonatomic, strong) UILabel *responseHeadersLabel;
@property (nonatomic, strong) UIView *responseModuleView;
@property (nonatomic, strong) UILabel *responseLabel;

@end

@implementation DGNetworkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self setupUI];
        self.modules = DGNetworkListModuleAll;
    }
    return self;
}

- (void)setupUI {
    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = [UIColor whiteColor];
    cardView.layer.cornerRadius = 16;
    cardView.layer.masksToBounds = YES;
    [self.contentView addSubview:cardView];
    self.cardView = cardView;
    DGNetworkPinEdges(cardView, self.contentView, UIEdgeInsetsMake(6, 12, 6, 12));

    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor grayColor];
    [cardView addSubview:timeLabel];
    self.timeLabel = timeLabel;

    DGNetworkInsetLabel *statusLabel = [[DGNetworkInsetLabel alloc] init];
    statusLabel.font = [UIFont boldSystemFontOfSize:12];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.layer.cornerRadius = 6;
    statusLabel.layer.masksToBounds = YES;
    [statusLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [statusLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [cardView addSubview:statusLabel];
    self.statusLabel = statusLabel;

    UILabel *methodLabel = [[UILabel alloc] init];
    methodLabel.font = [UIFont boldSystemFontOfSize:15];
    methodLabel.textColor = [UIColor blackColor];
    [methodLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [cardView addSubview:methodLabel];
    self.methodLabel = methodLabel;

    UILabel *durationLabel = [[UILabel alloc] init];
    durationLabel.font = [UIFont systemFontOfSize:13];
    durationLabel.textColor = [UIColor grayColor];
    [cardView addSubview:durationLabel];
    self.durationLabel = durationLabel;

    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [detailButton setTitle:@"详情" forState:UIControlStateNormal];
    [detailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    detailButton.titleLabel.font = [UIFont systemFontOfSize:13];
    detailButton.backgroundColor = DGNetworkPurple();
    detailButton.layer.cornerRadius = 14;
    detailButton.contentEdgeInsets = UIEdgeInsetsMake(4, 12, 4, 12);
    [detailButton addTarget:self action:@selector(tapDetail) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:detailButton];
    self.detailButton = detailButton;

    self.uriLabel = [self bodyLabelWithLines:3];
    self.headersLabel = [self bodyLabelWithLines:6];
    self.bodyLabel = [self bodyLabelWithLines:8];
    self.responseHeadersLabel = [self bodyLabelWithLines:6];
    self.responseLabel = [self bodyLabelWithLines:10];
    self.headersModuleView = [self moduleViewWithTitle:@"Request headers:" body:self.headersLabel];
    self.requestDataModuleView = [self moduleViewWithTitle:@"Request data:" body:self.bodyLabel];
    self.responseHeadersModuleView = [self moduleViewWithTitle:@"Response headers:" body:self.responseHeadersLabel];
    self.responseModuleView = [self moduleViewWithTitle:@"Response body:" body:self.responseLabel];

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.uriLabel,
        self.headersModuleView,
        self.requestDataModuleView,
        self.responseHeadersModuleView,
        self.responseModuleView,
    ]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 10;
    stackView.alignment = UIStackViewAlignmentFill;
    [cardView addSubview:stackView];

    DGNetworkDisableAutoresizing(timeLabel);
    DGNetworkDisableAutoresizing(statusLabel);
    DGNetworkDisableAutoresizing(methodLabel);
    DGNetworkDisableAutoresizing(durationLabel);
    DGNetworkDisableAutoresizing(detailButton);
    DGNetworkDisableAutoresizing(stackView);

    [NSLayoutConstraint activateConstraints:@[
        DGNetworkConstraint(statusLabel, NSLayoutAttributeTop, NSLayoutRelationEqual, cardView, NSLayoutAttributeTop, 14),
        DGNetworkConstraint(statusLabel, NSLayoutAttributeLeft, NSLayoutRelationEqual, cardView, NSLayoutAttributeLeft, 14),

        DGNetworkConstraint(methodLabel, NSLayoutAttributeLeft, NSLayoutRelationEqual, statusLabel, NSLayoutAttributeRight, 8),
        DGNetworkConstraint(methodLabel, NSLayoutAttributeCenterY, NSLayoutRelationEqual, statusLabel, NSLayoutAttributeCenterY, 0),

        DGNetworkConstraint(durationLabel, NSLayoutAttributeLeft, NSLayoutRelationEqual, methodLabel, NSLayoutAttributeRight, 8),
        DGNetworkConstraint(durationLabel, NSLayoutAttributeCenterY, NSLayoutRelationEqual, statusLabel, NSLayoutAttributeCenterY, 0),
        DGNetworkConstraint(detailButton, NSLayoutAttributeLeft, NSLayoutRelationGreaterThanOrEqual, durationLabel, NSLayoutAttributeRight, 8),

        DGNetworkConstraint(cardView, NSLayoutAttributeRight, NSLayoutRelationEqual, detailButton, NSLayoutAttributeRight, 12),
        DGNetworkConstraint(detailButton, NSLayoutAttributeCenterY, NSLayoutRelationEqual, statusLabel, NSLayoutAttributeCenterY, 0),
        DGNetworkConstraint(detailButton, NSLayoutAttributeHeight, NSLayoutRelationEqual, nil, NSLayoutAttributeNotAnAttribute, 28),

        DGNetworkConstraint(timeLabel, NSLayoutAttributeTop, NSLayoutRelationEqual, statusLabel, NSLayoutAttributeBottom, 8),
        DGNetworkConstraint(timeLabel, NSLayoutAttributeLeft, NSLayoutRelationEqual, cardView, NSLayoutAttributeLeft, 14),
        DGNetworkConstraint(cardView, NSLayoutAttributeRight, NSLayoutRelationEqual, timeLabel, NSLayoutAttributeRight, 14),

        DGNetworkConstraint(stackView, NSLayoutAttributeTop, NSLayoutRelationEqual, timeLabel, NSLayoutAttributeBottom, 12),
        DGNetworkConstraint(stackView, NSLayoutAttributeLeft, NSLayoutRelationEqual, cardView, NSLayoutAttributeLeft, 14),
        DGNetworkConstraint(cardView, NSLayoutAttributeRight, NSLayoutRelationEqual, stackView, NSLayoutAttributeRight, 14),
        DGNetworkConstraint(cardView, NSLayoutAttributeBottom, NSLayoutRelationEqual, stackView, NSLayoutAttributeBottom, 14),
    ]];
}

- (UIView *)moduleViewWithTitle:(NSString *)title body:(UILabel *)bodyLabel {
    UIView *moduleView = [[UIView alloc] init];
    UILabel *titleLabel = [self titleLabelWithText:title];
    [moduleView addSubview:titleLabel];
    [moduleView addSubview:bodyLabel];
    DGNetworkPinHorizontal(titleLabel, moduleView, 0);
    DGNetworkPinHorizontal(bodyLabel, moduleView, 0);
    [NSLayoutConstraint activateConstraints:@[
        DGNetworkConstraint(titleLabel, NSLayoutAttributeTop, NSLayoutRelationEqual, moduleView, NSLayoutAttributeTop, 0),
        DGNetworkConstraint(bodyLabel, NSLayoutAttributeTop, NSLayoutRelationEqual, titleLabel, NSLayoutAttributeBottom, 4),
        DGNetworkConstraint(moduleView, NSLayoutAttributeBottom, NSLayoutRelationEqual, bodyLabel, NSLayoutAttributeBottom, 0),
    ]];
    return moduleView;
}

- (void)setModules:(DGNetworkListModule)modules {
    _modules = modules;
    self.uriLabel.hidden = (modules & DGNetworkListModuleURI) == 0;
    self.headersModuleView.hidden = (modules & DGNetworkListModuleRequestHeaders) == 0;
    self.requestDataModuleView.hidden = (modules & DGNetworkListModuleRequestData) == 0;
    self.responseHeadersModuleView.hidden = (modules & DGNetworkListModuleResponseHeaders) == 0;
    self.responseModuleView.hidden = (modules & DGNetworkListModuleResponseBody) == 0;
}

- (UILabel *)titleLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    return label;
}

- (UILabel *)bodyLabelWithLines:(NSInteger)lines {
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = lines;
    label.font = [UIFont fontWithName:@"Menlo" size:12] ?: [UIFont systemFontOfSize:12];
    label.textColor = [UIColor darkGrayColor];
    return label;
}

- (void)setRecord:(DGNetworkRecord *)record {
    _record = record;
    if (!record) {
        return;
    }
    self.timeLabel.text = record.timeText;
    self.statusLabel.text = record.statusText;
    self.statusLabel.backgroundColor = record.statusColor;
    self.methodLabel.text = record.method;
    self.durationLabel.text = record.durationText;

    NSString *uri = record.URLString.length ? record.URLString : @"(空)";
    NSMutableAttributedString *uriText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Uri:\n%@", uri]];
    [uriText addAttributes:@{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:14],
        NSForegroundColorAttributeName: [UIColor blackColor],
    } range:NSMakeRange(0, 4)];
    [uriText addAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:13],
        NSForegroundColorAttributeName: [UIColor blackColor],
    } range:NSMakeRange(4, uriText.length - 4)];
    self.uriLabel.attributedText = uriText;

    self.headersLabel.text = record.requestHeaders.length ? record.requestHeaders : @"(空)";
    self.bodyLabel.text = record.requestBody.length ? record.requestBody : @"(空)";
    self.responseHeadersLabel.text = record.responseHeaders.length ? record.responseHeaders : (record.isFinished ? @"(空)" : @"请求中…");

    NSString *response = record.responseBody.length ? record.responseBody : (record.isFinished ? @"(空)" : @"请求中…");
    if (record.errorText.length) {
        response = [response stringByAppendingFormat:@"\n\nError:\n%@", record.errorText];
    }
    self.responseLabel.text = response;
}

- (void)tapDetail {
    if (self.record && self.detailHandler) {
        self.detailHandler(self.record);
    }
}

@end
