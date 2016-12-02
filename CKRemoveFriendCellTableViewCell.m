//
//  CKRemoveFriendCellTableViewCell.m
//  click
//
//  Created by Anatoly Mityaev on 29.11.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "CKRemoveFriendCellTableViewCell.h"

@implementation CKRemoveFriendCellTableViewCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_removeButton setTitle:@"" forState:UIControlStateNormal];
        [self.contentView addSubview:_removeButton];
        
        [_removeButton makeConstraints:^(MASConstraintMaker *make) {
            //make.left.equalTo(self.contentView.left).offset(26);
            make.centerX.equalTo(self.contentView.centerX);
            make.centerY.equalTo(self.contentView.centerY);
            make.width.equalTo(300);
            make.height.equalTo(30);
            //make.right.greaterThanOrEqualTo(self.contentView.right).offset(-26);
        }];
        
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = NO;
        self.backgroundColor = CKClickLightGrayColor;
    }
    return self;
}
@end
