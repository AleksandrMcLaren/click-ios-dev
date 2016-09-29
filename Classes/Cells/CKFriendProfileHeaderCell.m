//
//  CKFriendProfileHeaderCell.m
//  click
//
//  Created by Igor Tetyuev on 29.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKFriendProfileHeaderCell.h"
#import "CKCache.h"

@implementation CKFriendProfileHeaderCell

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CKFriendProfileHeaderCell"])
    {
        self.backgroundColor = CKClickLightGrayColor;
        
        _avatar = [CKUserAvatarView new];
        _avatar.fallbackColor = [UIColor orangeColor];
        [self.contentView addSubview:_avatar];
        
        _name = [UILabel labelWithText:@"Борис Иванович" font:[UIFont boldSystemFontOfSize:22.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
        _name.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_name];
        
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
        _likes.titleLabel.font = [UIFont systemFontOfSize:12.0];
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
            make.width.equalTo(50);
            make.height.equalTo(20);
        }];
        [_name makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatar.right).offset(12);
            make.bottom.equalTo(_avatar.centerY).offset(-2);
            make.right.greaterThanOrEqualTo(_likes.left).offset(-16);
        }];

        [_status makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_avatar.centerY).offset(2);
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
    NSMutableAttributedString *likesString = [NSMutableAttributedString new];
    [likesString appendAttributedString:[NSMutableAttributedString withString:[NSString stringWithFormat:@"%ld ", (long)likes]]];
    [likesString appendAttributedString:[NSMutableAttributedString withImageName:@"thumbs_up_gray" geometry:CGRectMake(0, -1, 12, 11)]];
    [_likes setAttributedTitle:likesString forState:UIControlStateNormal];
}

- (void) setUserStatus:(NSString *)status showCalendar:(BOOL)showCalendar
{
    NSMutableAttributedString *statusString = [NSMutableAttributedString new];
    if (showCalendar) [statusString appendAttributedString:[NSMutableAttributedString withImageName:@"profileCalendar" geometry:CGRectMake(0, 0, 11, 11)]];
    [statusString appendAttributedString:[NSMutableAttributedString withString:[NSString stringWithFormat:@" %@", status]]];
    _status.attributedText = statusString;
}

- (void)setFriend:(CKUserModel *)friend
{
    _friend = friend;
    [self setNumberOfLikes:_friend.likes];
    [self setUserStatus:@"В сети" showCalendar:YES];
    
    _friend = friend;
    self.avatar.user = friend;
    self.name.text = [[NSString stringWithFormat:@"%@ %@", friend.name?friend.name:@"", friend.surname?friend.surname:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.login.text = friend.login.length?friend.login:friend.id;
}

@end
