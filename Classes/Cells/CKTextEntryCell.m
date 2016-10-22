//
//  CKTextEntryCell.m
//  click
//
//  Created by Igor Tetyuev on 10.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKTextEntryCell.h"
#import "UIColor+hex.h"
#import "UILabel+utility.h"

@implementation CKTextEntryCell

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CKTextEntryCell class])])
    {
        _title = [UILabel labelWithText:@"" font:CKButtonFont textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
        _title.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_title];
        
        _textField = [UITextField new];
        _textField.font = [UIFont systemFontOfSize:17.0];

        [self.contentView addSubview:_textField];
        
        [_title makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left).offset(16);
            make.centerY.equalTo(self.centerY);
        }];
        
        [_textField makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left).offset(60);
            make.centerY.equalTo(self.centerY);
            make.right.equalTo(self.right).offset(-12);
        }];
        
        self.preservesSuperviewLayoutMargins = false;
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
    }
    return self;
}

- (void)setTextField:(UITextField *)textField
{
    [_textField removeFromSuperview];
    _textField = textField;
    [self.contentView addSubview:_textField];
    [_textField makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(61);
        make.centerY.equalTo(self.centerY);
        make.right.equalTo(self.right).offset(-70);
    }];
}

@end
