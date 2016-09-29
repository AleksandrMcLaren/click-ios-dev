//
//  CKAttachButton.m
//  click
//
//  Created by Igor Tetyuev on 09.06.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKAttachButton.h"

@implementation CKAttachButton {
    UIImageView *_imageView;
    UILabel *_label;
}

- (instancetype) initWithImageNamed:(NSString *)imageName title:(NSString *)title {
    if (self = [super init]) {
        self.clipsToBounds = YES;
        self.showsTouchWhenHighlighted = YES;
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        _imageView.contentMode = UIViewContentModeCenter;
        
        _label = [UILabel labelWithText:title font:[UIFont systemFontOfSize:11.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentCenter];
        [self addSubview:_imageView];
        [self addSubview:_label];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    [_imageView remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
    }];
    [_label remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.centerX.equalTo(self);
    }];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(50.0, 72.0);
}

@end
