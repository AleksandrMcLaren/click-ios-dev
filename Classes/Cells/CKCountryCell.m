//
//  CKCountryCell.m
//  click
//
//  Created by Igor Tetyuev on 10.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKCountryCell.h"
#import "UIColor+hex.h"
#import "UILabel+utility.h"

@implementation CKCountryCell

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CKCountryCell class])])
    {
        _countryBall = [UIImageView new];
        _countryBall.contentMode = UIViewContentModeScaleAspectFill;
        _countryBall.layer.cornerRadius = 29.0/2;
        _countryBall.clipsToBounds = YES;
        _countryBall.layer.borderColor = [UIColor colorFromHexString:@"#d2d2d1"].CGColor;
        _countryBall.layer.borderWidth = 1.0;

        [self.contentView addSubview:_countryBall];
        
        _title = [UILabel labelWithText:@"" font:[UIFont systemFontOfSize:16.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:_title];
        _title.lineBreakMode = NSLineBreakByTruncatingTail;
        
        _countryCode = [UILabel labelWithText:@"" font:[UIFont systemFontOfSize:11.0] textColor:[UIColor grayColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:_countryCode];
        
        [_countryBall makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(29);
            make.height.equalTo(29);
            make.left.equalTo(self.left).offset(16);
            make.centerY.equalTo(self.centerY);
        }];
        [_countryCode makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.right).offset(-44);
            make.centerY.equalTo(self.centerY);
        }];
        [_title makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_countryBall.right).offset(16);
            make.centerY.equalTo(self.centerY);
            make.right.lessThanOrEqualTo(_countryCode.left).offset(-8);
        }];
        self.preservesSuperviewLayoutMargins = false;
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
        
    }
    return self;
}

@end
