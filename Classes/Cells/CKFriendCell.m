//
//  CKFriendCell.m
//  click
//
//  Created by Igor Tetyuev on 10.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKFriendCell.h"
#import "UIColor+hex.h"
#import "UILabel+utility.h"
#import "CKCache.h"

@implementation CKFriendCell
{
    UIView *_separator;
    UIImageView *_checkmark;
    UIView *_circle;
}

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CKFriendCell class])])
    {

        self.backgroundColor = CKClickLightGrayColor;

        _avatar = [CKUserAvatarView new];
        _avatar.fallbackColor = [UIColor orangeColor];
        [self.contentView addSubview:_avatar];
        
        _name = [UILabel labelWithText:@"" font:[UIFont boldSystemFontOfSize:12.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
        _name.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_name];
        
        _login = [UILabel labelWithText:@"" font:[UIFont systemFontOfSize:10.0] textColor:[UIColor grayColor] textAlignment:NSTextAlignmentLeft];
        _login.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_login];
        
        _separator = [UIView new];
        _separator.backgroundColor = CKClickProfileGrayColor;
        [self.contentView addSubview:_separator];

        _checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkwhite"]];
        _checkmark.contentMode = UIViewContentModeScaleAspectFit;
        _checkmark.layer.cornerRadius = 10;
        _checkmark.clipsToBounds = YES;
        _checkmark.backgroundColor = CKClickBlueColor;
        _checkmark.hidden = YES;
        [self.contentView addSubview:_checkmark];
        
        _circle = [UIView new];
        _circle.contentMode = UIViewContentModeCenter;
        _circle.layer.cornerRadius = 10;
        _circle.layer.borderColor = [CKClickProfileGrayColor CGColor];
        _circle.layer.borderWidth = 1.0;
        _circle.clipsToBounds = YES;
        _circle.hidden = YES;
        [self.contentView addSubview:_circle];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    [_separator remakeConstraints:^(MASConstraintMaker *make) {
        if (_isSelectable)
        {
            make.left.equalTo(self.avatar.centerX).offset(-8);
        } else
        {
            make.left.equalTo(self.contentView.left).offset(_isLast?16:60);
        }
        make.right.equalTo(self.contentView.right).offset(-16);
        make.bottom.equalTo(self.contentView.bottom).offset(-1);
        make.height.equalTo(0.5);
    }];
    
    [_checkmark remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(20);
        make.height.equalTo(20);
        make.centerY.equalTo(_avatar.centerY);
        make.left.equalTo(11.0);
    }];
    
    [_circle remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_checkmark);
    }];
    
    [_avatar remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.left).offset(_isSelectable?48:20);
        make.top.equalTo(self.contentView.top).offset(6);
        make.bottom.equalTo(self.contentView.bottom).offset(-6);
        make.width.equalTo(_avatar.height);
        
    }];
    [_login remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatar.right).offset(8);
        make.bottom.equalTo(_avatar.bottom).offset(-4);
        make.top.greaterThanOrEqualTo(_name.bottom).offset(2);
    }];
    [_name remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatar.right).offset(8);
        make.top.equalTo(_avatar.top).offset(4);
    }];
}

- (void)setIsLast:(BOOL)isLast
{
    _isLast = isLast;
    [self setNeedsUpdateConstraints];
}

- (void)setIsSelectable:(BOOL)isSelectable
{
    _isSelectable = isSelectable;
    _checkmark.hidden = !(_isSelectable && _isSelected);
    _circle.hidden = !(_isSelectable && !_isSelected);
    [self setNeedsUpdateConstraints];
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    _checkmark.hidden = !(_isSelectable && _isSelected);
    _circle.hidden = !(_isSelectable && !_isSelected);
}

- (void)setFriend:(CKUserModel *)friend
{
    _friend = friend;
    self.name.text = [[NSString stringWithFormat:@"%@ %@", friend.name?friend.name:@"", friend.surname?friend.surname:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.login.text = friend.login.length?friend.login:friend.id;
    self.avatar.user = friend;
}

@end
