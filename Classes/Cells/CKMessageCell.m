//
//  CKMessageCell.m
//  click
//
//  Created by Igor Tetyuev on 07.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKMessageCell.h"
#import <CoreText/CoreText.h>

@interface AttachButton : UIButton

@property (nonatomic, assign) CKAttachModel *model;

@end

@implementation AttachButton {
    UIActivityIndicatorView *_activityIndicator;
}

- (instancetype) initWithModel:(CKAttachModel *)model {
    if (self = [super init]) {
        _model = model;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 0.5;
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:_activityIndicator];
        [_activityIndicator makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        @weakify(self);
        [[RACObserve(_model, preview) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
            @strongify(self);
            [self setImage:model.preview forState:UIControlStateNormal];
        }];
        [[RACObserve(_model, isBusy) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
            @strongify(self);
            self.enabled = !_model.isBusy;
            if (_model.isBusy) {
                [_activityIndicator startAnimating];
            }
            else {
                [_activityIndicator stopAnimating];
            }
        }];
    }
    return self;
}

@end

@interface CKBalloon : UIView

@property (nonatomic, strong) UIImageView *shadow;

@end

@implementation CKBalloon

- (void)layoutSubviews
{
    self.maskView.frame = self.bounds;
    self.shadow.frame = self.frame;
}


@end

@interface CKMessageCell()

@property (nonatomic, assign) BOOL isReceived;

@end

@implementation CKMessageCell

- (instancetype) init
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CKMessageCell"])
    {
        _isReceived = YES;
        _isFirst = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.balloon = [CKBalloon new];
        self.balloon.backgroundColor = [UIColor yellowColor];
        self.mask = [[UIImageView alloc] initWithImage:
                 [[UIImage imageNamed:@"cellMask"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 16, 20, 20)
                                                                      resizingMode:UIImageResizingModeStretch]];
        self.mask.contentMode = UIViewContentModeScaleToFill;
        self.balloon.maskView = self.mask;
        UIImageView *shadow = [[UIImageView alloc] initWithImage:
                               [[UIImage imageNamed:@"cellMaskShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 16, 20, 20)
                                                                                      resizingMode:UIImageResizingModeStretch]];
        NSLog(@"shadow: %@", shadow);
        self.balloon.shadow = shadow;
        self.balloon.shadow.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:self.balloon.shadow];
        [self.contentView addSubview:self.balloon];
        self.text = [UILabel labelWithText:@"" font:[UIFont systemFontOfSize:17.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
        self.text.numberOfLines = 0;
        self.text.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.balloon addSubview:self.text];
        
        self.time = [UILabel labelWithText:@"10:10" font:[UIFont systemFontOfSize:13.0] textColor:[UIColor colorFromHexString:@"#565e6d"] textAlignment:NSTextAlignmentRight];
        [self.balloon addSubview:self.time];
        [self setNeedsUpdateConstraints];
    }
    return self;
}


+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints
{
    
    [self.text remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.balloon.top).offset(15);
        make.left.equalTo(self.balloon.left).offset(10);
        make.width.lessThanOrEqualTo(220);
    }];
    
    UIView *prev = self.text;
    __block CGFloat contentwidth = (self.text.attributedText.length > 0) ? 220 : 0;
    for (UIButton *i in self.attachementButtons) {
        [i remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(prev.bottom).offset(8);
            make.left.equalTo(self.text.left);
            UIImage *image = [i imageForState:UIControlStateNormal];
            CGFloat width = fmin(200, image.size.width);
            contentwidth = fmax(contentwidth, width + 20);
            make.width.equalTo(width);
            if (image.size.width == 0) {
                make.height.equalTo(0);
            }
            else {
                make.height.equalTo(width * (image.size.height / image.size.width));
            }
            
        }];
        prev = i;
    }
    
    if (_isReceived)
    {
        [self.balloon remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.left);
            make.top.equalTo(0);
            make.width.equalTo(contentwidth);
            make.bottom.greaterThanOrEqualTo(prev.bottom).offset(self.time.attributedText.length?30:0);
        }];

    } else
    {
        [self.balloon remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.right);
            make.top.equalTo(0);
            make.width.equalTo(contentwidth);
            make.bottom.greaterThanOrEqualTo(prev.bottom).offset(self.time.attributedText.length?30:0);
        }];

    }
    
    [self.contentView remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top);
        make.left.equalTo(self.left);
        make.width.equalTo(self.width);
        make.height.equalTo(self.balloon);
    }];
    
    [self.time remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.balloon.bottom).offset(-10);
        make.right.equalTo(self.balloon.right).offset(-10);
    }];
    [super updateConstraints];

}

- (void)setIsFirst:(BOOL)isFirst
{
    _isFirst = isFirst;
    if (_isFirst)
    {
        self.mask = [[UIImageView alloc] initWithImage:
                     [[UIImage imageNamed:@"cellMask"] resizableImageWithCapInsets:UIEdgeInsetsMake(21, 16, 16, 16)
                                                                      resizingMode:UIImageResizingModeStretch]];
        self.balloon.shadow = [[UIImageView alloc] initWithImage:
                               [[UIImage imageNamed:@"cellMaskShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 16, 20, 20)
                                                                                      resizingMode:UIImageResizingModeStretch]];
        self.balloon.shadow = UIViewContentModeScaleToFill;
        self.balloon.maskView = self.mask;

    } else
    {
        self.mask = [[UIImageView alloc] initWithImage:
                                     [[UIImage imageNamed:@"secondaryCellMask"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 20, 16)
                                                                                      resizingMode:UIImageResizingModeStretch]];
        self.balloon.shadow = [[UIImageView alloc] initWithImage:
                               [[UIImage imageNamed:@"secondaryCellMaskShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 20, 16)
                                                                                      resizingMode:UIImageResizingModeStretch]];
        self.balloon.shadow = UIViewContentModeScaleToFill;
        self.balloon.maskView = self.mask;

    }
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setIsReceived:(BOOL)isReceived
{
    _isReceived = isReceived;

    if (isReceived)
    {
        self.mask.transform = CGAffineTransformIdentity;
        self.balloon.shadow.transform =CGAffineTransformIdentity;
        self.balloon.backgroundColor = [UIColor whiteColor];
    } else
    {
        self.mask.transform = CGAffineTransformMakeScale(-1, 1);
        self.balloon.shadow.transform = CGAffineTransformMakeScale(-1, 1);
        self.balloon.backgroundColor = [UIColor colorFromHexString:@"#cce8f9"];
    }
}

- (CGRect)estimatePayloadSize
{
    CGRect s = CGRectMake(0, 0, 60, 16);
    return s;
}

- (void)setMessage:(CKMessageModel *)message
{
    _message = message;
    NSMutableAttributedString *messageText = [NSMutableAttributedString withString:message.message];
    
    if (message.attachements.count == 0 && message.date) {
        [messageText appendAttributedString:[NSMutableAttributedString withString:@"\u2060"]];
        [messageText appendAttributedString:[NSMutableAttributedString withImage:[CKMessageCell imageWithColor:[UIColor clearColor]] geometry:[self estimatePayloadSize]]];
    }
    
    self.text.attributedText = messageText;
    
    for (UIView *i in self.attachementButtons) {
        [i removeFromSuperview];
    }
    
    self.attachementButtons = [NSMutableArray new];
    NSInteger buttonCounter = 0;
    for (CKAttachModel *attach in message.attachements) {
        AttachButton *button = [[AttachButton alloc] initWithModel:attach];
        [self.balloon addSubview:button];
        [self.attachementButtons addObject:button];
        button.tag = buttonCounter;
        buttonCounter++;
        [button addTarget:self action:@selector(attachButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.isReceived = !message.isOwner;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTF"];
    [dateFormatter setDateFormat:@"HH:mm"];
    if (message.date) {
        NSMutableAttributedString *time = [[NSMutableAttributedString alloc] initWithString:[dateFormatter stringFromDate:message.date]];
        [time appendAttributedString:[NSMutableAttributedString withImageName:@"tick_gray" geometry:CGRectMake(0, -2, 12, 12)]];
        self.time.attributedText = time;
        self.time.hidden = NO;
    }
    else {
        self.time.hidden = YES;
    }
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (void)attachButtonPressed:(UIButton *)button {
    [self.delegate attachementButtonPressedWithModel:self.message attachNumber:button.tag];
}

@end
