//
//  CKProfileHeaderView.m
//  click
//
//  Created by Igor Tetyuev on 19.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKProfileHeaderView.h"

@implementation CKProfileHeaderView
{
    UIView *_nameSeparatorView;
    UIView *_secondNameSeparatorView;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _firstName = [UITextField new];
        _firstName.placeholder = @"Имя";
        _firstName.tag = 0;
        [self addSubview:_firstName];
        
        _secondName = [UITextField new];
        _secondName.placeholder = @"Фамилия";
        _secondName.tag = 1;
        [self addSubview:_secondName];
        
        _avatar = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatar.layer.borderColor = [CKClickProfileGrayColor CGColor];
        _avatar.layer.borderWidth = 2.0;
        _avatar.layer.cornerRadius = 37.5;
        _avatar.clipsToBounds = YES;
        
        _avatar.imageView.layer.cornerRadius = 37.5;
        _avatar.imageView.clipsToBounds = YES;
        
        [_avatar setTitle:@"добавить\nфото" forState:UIControlStateNormal];
        _avatar.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _avatar.titleLabel.textAlignment = NSTextAlignmentCenter;
        _avatar.titleLabel.numberOfLines = 2;
        [_avatar setTitleColor:CKClickBlueColor forState:UIControlStateNormal];
        [self addSubview:_avatar];
        
        _nameSeparatorView = [UIView new];
        _nameSeparatorView.backgroundColor = CKClickProfileGrayColor;
        [self addSubview:_nameSeparatorView];

        _secondNameSeparatorView = [UIView new];
        _secondNameSeparatorView.backgroundColor = CKClickProfileGrayColor;
        [self addSubview:_secondNameSeparatorView];
        
        float padding = CK_STANDART_CONTROL_PADDING;
        
        [_avatar makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left).offset(padding*.5);
            make.top.equalTo(self.top).offset(padding*.5);
            make.width.equalTo(76);
            make.height.equalTo(76);
        }];
        [_firstName makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatar.right).offset(padding);
            make.top.equalTo(self.top).offset(padding);
            make.right.equalTo(self.right);
        }];
        [_nameSeparatorView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_firstName.left);
            make.top.equalTo(_firstName.bottom).offset(padding*.5);
            make.right.equalTo(self.right);
            make.height.equalTo(0.5);
        }];
        [_secondName makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatar.right).offset(padding);
            make.top.equalTo(_nameSeparatorView).offset(padding*.5);
            make.right.equalTo(self.right);
        }];
        [_secondNameSeparatorView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_secondName.left);
            make.top.equalTo(_secondName.bottom).offset(padding*.5);
            make.right.equalTo(self.right);
            make.height.equalTo(0.5);
        }];


    }
    return self;
}

@end
