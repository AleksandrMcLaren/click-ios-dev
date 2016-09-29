//
//  CKAddressBookCell.m
//  click
//
//  Created by Igor Tetyuev on 29.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKAddressBookCell.h"

@implementation CKAddressBookCell
{
    UIView *_separator;
}


- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CKAddressBookCell class])])
    {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        _separator = [UIView new];
        [self.contentView addSubview:_separator];
        _separator.backgroundColor = CKClickProfileGrayColor;
        [_separator makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.left).offset(16);
            make.right.equalTo(self.contentView.right).offset(-16);
            make.bottom.equalTo(self.contentView.bottom).offset(-1);
            make.height.equalTo(0.5);
        }];
        
        _inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_inviteButton];
        _inviteButton.layer.cornerRadius = 5;
        _inviteButton.layer.borderWidth = 1.0f;
        _inviteButton.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [_inviteButton setTitle:@"Пригласить" forState:UIControlStateNormal];
        [_inviteButton setTitleColor:CKClickBlueColor forState:UIControlStateNormal];
        _inviteButton.layer.borderColor = CKClickBlueColor.CGColor;
        [_inviteButton makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.right).offset(-16);
            make.top.equalTo(self.contentView.top).offset(8);
            make.bottom.equalTo(self.contentView.bottom).offset(-8);
            make.width.equalTo(80);
            
        }];
        
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect r = self.textLabel.frame;
    r.origin.x = 16.0;
    self.textLabel.frame = r;
}

@end
