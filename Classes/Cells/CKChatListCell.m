//
//  CKChatListCell.m
//  click
//
//  Created by Igor Tetyuev on 03.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKChatListCell.h"

@implementation CKChatListCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
    {
        _avatar = [CKAvatarView new];
        
        [self.contentView addSubview:_avatar];
        
        _title = [UILabel labelWithText:@"Текст" font:[UIFont boldSystemFontOfSize: 16.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
        _title.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_title];
        
        _subtitle = [UILabel labelWithText:@"Текст последнего сообщения" font:[UIFont systemFontOfSize: 14.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
        _subtitle.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_subtitle];
        
        _activity = [UILabel labelWithText:@"5 минут" font:[UIFont systemFontOfSize: 14.0] textColor:CKClickProfileGrayColor textAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_activity];
        
        _unreadCount = [UILabel labelWithText:@"0" font:[UIFont systemFontOfSize: 14.0] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentCenter];
        _unreadCount.backgroundColor= CKClickBlueColor;
        _unreadCount.clipsToBounds = YES;
        _unreadCount.layer.cornerRadius = 8;
        [self.contentView addSubview:_unreadCount];
        
        [_avatar makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(48);
            make.width.equalTo(48);
            make.left.equalTo(self.contentView.left).offset(16);
            make.centerY.equalTo(self.contentView.centerY);
        }];
        
        [_title makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatar.right).offset(8);
            make.top.equalTo(self.contentView.top).offset(12);
            make.right.greaterThanOrEqualTo(_activity.left).offset(16);
        }];
        
        [_activity makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.top).offset(12);
            make.right.equalTo(self.contentView.right).offset(-8);
        }];
        
        [_unreadCount makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView.bottom).offset(-8);
            make.right.equalTo(self.contentView.right).offset(-8);
            make.height.equalTo(16);
        }];
        
        [_subtitle makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatar.right).offset(8);
            make.bottom.equalTo(self.contentView.bottom).offset(-12);
            make.right.lessThanOrEqualTo(_unreadCount.left).offset(-16);
        }];
        self.rightUtilityButtons = @[[self utilityButtonWithTitle:@"Ещё..." color:CKClickBlueColor fontSize:16.0], [self utilityButtonWithTitle:@"Удалить" color:[UIColor redColor] fontSize:16.0]];

    }
    return self;
}

- (UIButton *)utilityButtonWithTitle:(NSString *)title color:(UIColor *)color fontSize:(CGFloat)fontSize
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = color;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    button.titleLabel.numberOfLines = 3;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    return button;
}

- (NSString *)letterNameWithName:(NSString *)name surname:(NSString *)surname login:(NSString *)login
{
    if (!surname && !name) name = login;
    
    if (!surname)
    {
        surname = name;
        name = nil;
    }
    if (name.length) return [name substringToIndex:1];
    return nil;
}

- (void)setModel:(CKDialogListEntryModel *)model
{
    _model = model;
    [self.avatar setAvatarFile:model.dialogAvatarId fallbackName:[self letterNameWithName:model.userName surname:model.userSurname login:model.userLogin]];
    
    self.unreadCount.text = [NSString stringWithFormat:@"%ld", (long)model.messagesUnread];
    [_unreadCount remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.bottom).offset(-12);
        make.right.equalTo(self.contentView.right).offset(-8);
        make.width.equalTo([_unreadCount sizeThatFits:CGSizeMake(100, 16)].width+8);
        make.height.equalTo(16);
    }];
    if (model.messagesUnread == 0)
    {
        self.unreadCount.hidden = YES;
        self.leftUtilityButtons = nil;
        
    } else
    {
        self.unreadCount.hidden = NO;
        
        self.leftUtilityButtons = @[[self utilityButtonWithTitle:@"пометить\nкак\nпрочитанное" color:CKClickBlueColor fontSize:12.0]];
    }
}


@end
