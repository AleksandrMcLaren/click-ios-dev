//
//  CKAttachCell.m
//  click
//
//  Created by Igor Tetyuev on 10.06.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKAttachCell.h"

@implementation CKAttachCell {
    UIImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        [_imageView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 1.0;
        self.layer.cornerRadius = 2.0;
        self.clipsToBounds = YES;
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _deleteButton.layer.cornerRadius = 8.0;
        [_deleteButton setBackgroundColor:[UIColor whiteColor]];
        _deleteButton.clipsToBounds = YES;
        [_deleteButton setImage:[UIImage imageNamed:@"cross_blue_circle"] forState:UIControlStateNormal];
        [self addSubview:_deleteButton];
        
        [_deleteButton makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(16.0);
            make.height.equalTo(16.0);
            make.left.equalTo(self.right).offset(-24);
            make.top.equalTo(self.top).offset(8);
        }];

    }
    return self;
}

- (void)setModel:(CKAttachModel *)model {
    _model = model;
    _imageView.image = model.preview;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(64, 64);
}


@end
