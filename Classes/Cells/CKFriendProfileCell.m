//
//  CKFriendProfileCell.m
//  click
//
//  Created by Igor Tetyuev on 30.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKFriendProfileCell.h"

@implementation CKFriendProfileCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _titleLabel = [UILabel labelWithText:@"" font:[UIFont systemFontOfSize:16.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:_titleLabel];
        _detailLabel = [UILabel labelWithText:@"" font:[UIFont systemFontOfSize:16.0] textColor:[UIColor colorFromHexString:@"#81807f"] textAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_detailLabel];
        
        [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.left).offset(16);
            make.centerY.equalTo(self.contentView.centerY);
            make.right.greaterThanOrEqualTo(_detailLabel.left).offset(16);
        }];
        [_detailLabel makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.right).offset(-30);
            make.centerY.equalTo(self.contentView.centerY);
        }];
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = NO;
        self.backgroundColor = CKClickLightGrayColor;
    }
    return self;
}

//- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
//{
//    [super setAccessoryType:accessoryType];
//    [_detailLabel remakeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.contentView.right).offset((accessoryType==UITableViewCellAccessoryDisclosureIndicator)?-8:-16);
//        make.centerY.equalTo(self.contentView.centerY);
//    }];
//}

@end
