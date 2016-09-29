//
//  CKFriendProfileDetailCell.m
//  click
//
//  Created by Igor Tetyuev on 30.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKFriendProfileDetailCell.h"

@implementation CKFriendProfileDetailCell

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CKFriendProfileDetailCell"])
    {
        _titleLabel = [UILabel labelWithText:@"Title" font:[UIFont systemFontOfSize:13.0] textColor:[UIColor colorFromHexString:@"#c8c8c8"] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:_titleLabel];
        _detailLabel = [UILabel labelWithText:@"Detail" font:[UIFont systemFontOfSize:15.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:_detailLabel];
        
        [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.left).offset(16);
            make.top.equalTo(self.contentView.top).offset(6);
            make.right.greaterThanOrEqualTo(self.contentView.right).offset(-16);
        }];
        [_detailLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.left).offset(16);
            make.bottom.equalTo(self.contentView.bottom).offset(-6);
            make.right.greaterThanOrEqualTo(self.contentView.right).offset(-16);
            make.top.greaterThanOrEqualTo(_titleLabel.bottom).offset(6);
        }];
        self.backgroundColor = CKClickLightGrayColor;

    }
    return self;
}

@end
