//
//  CKFriendProfileLocationCell.m
//  click
//
//  Created by Igor Tetyuev on 30.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKFriendProfileLocationCell.h"

@implementation CKFriendProfileLocationCell

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CKFriendProfileLocationCell"])
    {
        _titleLabel = [UILabel labelWithText:@"Title" font:[UIFont systemFontOfSize:16.0] textColor:[UIColor colorFromHexString:@"#c8c8c8"] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:_titleLabel];
        _detailLabel = [UILabel labelWithText:@"Detail" font:[UIFont systemFontOfSize:16.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
        _detailLabel.numberOfLines = 2;
        [self.contentView addSubview:_detailLabel];
        _distanceLabel = [UILabel labelWithText:@"Distance" font:[UIFont systemFontOfSize:11.0] textColor:[UIColor colorFromHexString:@"#848484"] textAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_distanceLabel];
        _showMap = [UILabel labelWithText:@"На карте" font:[UIFont systemFontOfSize:11.0] textColor:CKClickBlueColor textAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_showMap];
        
        [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.left).offset(16);
            make.top.equalTo(self.contentView.top).offset(8);
            make.right.greaterThanOrEqualTo(_distanceLabel.left).offset(-8);
        }];
        [_detailLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.left).offset(16);
            make.bottom.greaterThanOrEqualTo(self.contentView.bottom).offset(-8);
            make.right.greaterThanOrEqualTo(_showMap.left).offset(-8);
            make.top.equalTo(_titleLabel.bottom).offset(8);
        }];
        [_distanceLabel makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_titleLabel.bottom).offset(0);
            make.right.equalTo(self.contentView.right).offset(-16);
        }];
        [_showMap makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.centerY).offset(0);
            make.right.equalTo(self.contentView.right).offset(-16);
        }];
        self.backgroundColor = CKClickLightGrayColor;

        
    }
    return self;
}

@end
