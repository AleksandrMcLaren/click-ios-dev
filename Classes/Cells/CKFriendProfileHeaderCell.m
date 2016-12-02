//
//  CKFriendProfileHeaderCell.m
//  click
//
//  Created by Igor Tetyuev on 29.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKFriendProfileHeaderCell.h"
#import "CKCache.h"
#import "CKUserAvatarView.h"
#import "CKFriendProfileController.h"


@implementation CKFriendProfileHeaderCell
{
    CKFriendProfileController *profileController;
    NSString *exitDate;
}

- (instancetype)init
{
    profileController = [CKFriendProfileController new];
    _isLiked = NO;
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CKFriendProfileHeaderCell"])
    {
        self.backgroundColor = CKClickLightGrayColor;
        
        _avatar = [CKUserAvatarView new];
        _avatar.fallbackColor = [UIColor orangeColor];
        [self.contentView addSubview:_avatar];
        
        _name = [UILabel labelWithText:@"Борис Иванович" font:[UIFont boldSystemFontOfSize:20.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
        _name.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_name];
        
        _surname = [UILabel labelWithText:@"Борис Иванович" font:[UIFont boldSystemFontOfSize:20.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
        _surname.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_surname];
        
        _status = [UILabel labelWithText:@"Status" font:[UIFont systemFontOfSize:16.0] textColor:[UIColor colorFromHexString:@"#838383"] textAlignment:NSTextAlignmentLeft];
        _status.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_status];
        
        _login = [UILabel labelWithText:@"Login" font:[UIFont systemFontOfSize:16.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
        _login.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_login];
        
        _openChat = [UIButton buttonWithType:UIButtonTypeCustom];
        [_openChat setImage:[UIImage imageNamed:@"profileOpenDialog"] forState:UIControlStateNormal];
        _openChat.showsTouchWhenHighlighted = YES;
        [self.contentView addSubview:_openChat];
        
        
        _likes = [UIButton buttonWithType:UIButtonTypeCustom];
        [_likes setBackgroundColor:[UIColor whiteColor]];
        [_likes setTitleColor:[UIColor colorFromHexString:@"#666666"] forState:UIControlStateNormal];
        _likes.layer.borderColor = [[UIColor colorFromHexString:@"#dddddd"] CGColor];
        _likes.layer.borderWidth = 0.5;
        _likes.titleLabel.font = [UIFont systemFontOfSize:16.0];
        _likes.showsTouchWhenHighlighted = YES;
        [self.contentView addSubview:_likes];
        
        [_avatar makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.top).offset(12);
            make.left.equalTo(self.contentView.left).offset(16);
            make.width.equalTo(75);
            make.height.equalTo(75);
        }];
        [_likes makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.right).offset(-16);
            make.bottom.equalTo(_avatar.centerY).offset(0);
            make.width.equalTo(70);
            make.height.equalTo(30);
        }];
        [_name makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatar.right).offset(12);
            make.bottom.equalTo(_avatar.centerY).offset(-2);
            make.right.greaterThanOrEqualTo(_likes.left).offset(-16);
        }];
        
        [_surname makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_avatar.centerY).offset(2);
            make.left.equalTo(_avatar.right).offset(12);
            make.right.greaterThanOrEqualTo(_likes.left).offset(-16);        }];
        
        [_status makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_avatar.centerY).offset(32);
            make.left.equalTo(_avatar.right).offset(12);
            make.right.greaterThanOrEqualTo(_likes.left).offset(-16);
        }];
        [_login makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView.bottom).offset(-12);
            make.left.equalTo(self.contentView.left).offset(16);
        }];
        [_openChat makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(23);
            make.height.equalTo(20);
            make.bottom.equalTo(self.contentView.bottom).offset(-12);
            make.right.equalTo(self.contentView.right).offset(-16);
        }];
        
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = NO;
        self.backgroundColor = CKClickLightGrayColor;
        
    }
    return self;
}

- (void) setNumberOfLikes:(NSInteger)likes
{
    NSString *imageName = [NSString new];
    if (_isLiked == YES)
    {
        imageName = @"thumbs_up_blue";
    }
    else
    {
        imageName = @"thumbs_up_gray";
    }
    NSMutableAttributedString *likesString = [NSMutableAttributedString new];
    [likesString appendAttributedString:[NSMutableAttributedString withString:[NSString stringWithFormat:@"%ld ", (long)likes]]];
    [likesString appendAttributedString:[NSMutableAttributedString withImageName:imageName geometry:CGRectMake(0, -1, 16, 15)]];
    [_likes setAttributedTitle:likesString forState:UIControlStateNormal];
}

- (void) setUserStatus:(NSString *)status showCalendar:(BOOL)showCalendar
{
    NSMutableAttributedString *statusString = [NSMutableAttributedString new];
    if (showCalendar == YES)
    {
        [statusString appendAttributedString:[NSMutableAttributedString withImageName:@"green" geometry:CGRectMake(0, 0, 11, 11)]];
        [statusString appendAttributedString:[NSMutableAttributedString withString:[NSString stringWithFormat:@" %@", status]]];
        _status.attributedText = statusString;
    }
    else
    {
        [statusString appendAttributedString:[NSMutableAttributedString withImageName:@"gray" geometry:CGRectMake(0, 0, 11, 11)]];
        [statusString appendAttributedString:[NSMutableAttributedString withString:[NSString stringWithFormat:@" %@", status]]];
        _status.attributedText = statusString;
    }
}

- (void)setFriend:(CKUserModel *)friend
{
    _friend = friend;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM в HH:mm"];
    NSString *result = [formatter stringFromDate:friend.statusDate];
    if (result == nil || [result isEqual:@""] ) result = @"давно";
    
    [self setNumberOfLikes:_friend.likes];
    if (_friend.status == 1)
    {
        [self setUserStatus:@"В сети" showCalendar:YES];
    }
    else
    {
        if ([_friend.sex isEqual:@"f"])
        {
            NSString *fullStringStatus = [NSString stringWithFormat:@"Была в сети %@", result];
            [self setUserStatus:fullStringStatus showCalendar:NO];
        }
        else
        {
            NSString *fullStringStatus = [NSString stringWithFormat:@"Был в сети %@", result];
            [self setUserStatus:fullStringStatus showCalendar:NO];
        }
    }
    
    
    _friend = friend;
    NSString * letter = [NSString new];
    if ([friend.name isEqual: @""] || friend.name == nil)
    {
        letter = [[friend.login substringToIndex:1] uppercaseString];
    }
    else
    {
        letter = [[friend.name substringToIndex:1] uppercaseString];
    }
    UIColor *color = [CKUserAvatarView getColorForAvatar:letter];
    self.avatar.fallbackColor = color;
    self.avatar.user = friend;
    self.name.text = [NSString stringWithFormat:@"%@", friend.name?friend.name:@""];
    self.surname.text = [NSString stringWithFormat:@"%@", friend.surname?friend.surname:@""];
    self.login.text = friend.login.length?friend.login:friend.id;
}

@end
