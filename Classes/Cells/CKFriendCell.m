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
    if (![_name.text isEqual:@""])
    {
        [_login remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatar.right).offset(8);
            make.bottom.equalTo(_avatar.bottom).offset(-4);
            make.top.greaterThanOrEqualTo(_name.bottom).offset(2);
        }];
        [_login setFont:[UIFont systemFontOfSize: 10.0]];
        [_login setTextColor:[UIColor grayColor]];
        [_login setTextAlignment:NSTextAlignmentLeft];
        [_name remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatar.right).offset(8);
            make.top.equalTo(_avatar.top).offset(4);
        }];
    }
    else
    {
        [_login setFont:[UIFont boldSystemFontOfSize: 12.0]];
        [_login setTextColor:[UIColor blackColor]];
        [_login setTextAlignment:NSTextAlignmentLeft];
        [_login remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatar.right).offset(8);
            make.top.equalTo(_avatar.top).offset(10);
        }];
    }
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
    if (![friend.name isEqual: @""])
    {
        self.name.text = [[NSString stringWithFormat:@"%@ %@", friend.name?friend.name:@"", friend.surname?friend.surname:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.login.text = friend.login.length?friend.login:friend.id;
    }
    else
    {
        self.name.text = @"";
        self.login.text = friend.login.length?friend.login:friend.id;
    }
    self.avatar.user = friend;
    _avatar.fallbackColor = [self setColorToAvatar];
}

- (UIColor *) setColorToAvatar
{
    _avatar.fallbackColor = [UIColor orangeColor];
    NSString *str = [NSString new];
    str = _friend.name;
    if ([str isEqual:@""] || str == nil)
    {
        str = [[_friend.login substringToIndex:1] uppercaseString];
    }
    else
    {
        str = [[str substringToIndex:1] uppercaseString];
    }
    
    typedef void (^CaseBlock)();
    
    // Squint and this looks like a proper switch!
    NSDictionary *d = @{
                        @"A":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:230/255.0f green:54/255.0f blue:180/255.0f alpha:1.0];
                            },
                        @"B":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:250/255.0f green:55/255.0f blue:122/255.0f alpha:1.0];
                            },
                        @"C":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:255/255.0f green:112/255.0f blue:102/255.0f alpha:1.0];
                            },
                        @"D":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:255/255.0f green:123/255.0f blue:82/255.0f alpha:1.0];
                            },
                        @"E":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:254/255.0f green:200/255.0f blue:7/255.0f alpha:1.0];
                            },
                        @"F":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:96/255.0f green:219/255.0f blue:100/255.0f alpha:1.0];
                            },
                        @"G":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:194/255.0f green:35/255.0f blue:137/255.0f alpha:1.0];
                            },
                        @"H":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:232/255.0f green:30/255.0f blue:99/255.0f alpha:1.0];
                            },
                        @"I":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:243/255.0f green:67/255.0f blue:54/255.0f alpha:1.0];
                            },
                        @"J":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:254/255.0f green:87/255.0f blue:34/255.0f alpha:1.0];
                            },
                        @"K":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:254/255.0f green:151/255.0f blue:0/255.0f alpha:1.0];
                            },
                        @"L":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:76/255.0f green:174/255.0f blue:80/255.0f alpha:1.0];
                            },
                        @"M":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:124/255.0f green:21/255.0f blue:104/255.0f alpha:1.0];
                            },
                        @"N":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:135/255.0f green:14/255.0f blue:79/255.0f alpha:1.0];
                            },
                        @"O":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:182/255.0f green:28/255.0f blue:28/255.0f alpha:1.0];
                            },
                        @"P":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:190/255.0f green:54/255.0f blue:12/255.0f alpha:1.0];
                            },
                        @"Q":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:299/255.0f green:81/255.0f blue:0/255.0f alpha:1.0];
                            },
                        @"R":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:27/255.0f green:94/255.0f blue:32/255.0f alpha:1.0];
                            },
                        @"S":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:0/255.0f green:181/255.0f blue:164/255.0f alpha:1.0];
                            },
                        @"T":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:0/255.0f green:197/255.0f blue:222/255.0f alpha:1.0];
                            },
                        @"U":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:78/255.0f green:99/255.0f blue:219/255.0f alpha:1.0];
                            },
                        @"V":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:144/255.0f green:76/255.0f blue:228/255.0f alpha:1.0];
                            },
                        @"W":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:210/255.0f green:53/255.0f blue:237/255.0f alpha:1.0];
                            },
                        @"X":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:121/255.0f green:157/255.0f blue:173/255.0f alpha:1.0];
                            },
                        @"Y":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:176/255.0f green:124/255.0f blue:105/255.0f alpha:1.0];
                            },
                        @"Z":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:0/255.0f green:149/255.0f blue:135/255.0f alpha:1.0];
                            },
                        @"0":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:0/255.0f green:172/255.0f blue:194/255.0f alpha:1.0];
                            },
                        @"1":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:63/255.0f green:81/255.0f blue:180/255.0f alpha:1.0];
                            },
                        @"2":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:109/255.0f green:60/255.0f blue:178/255.0f alpha:1.0];
                            },
                        @"3":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:155/255.0f green:39/255.0f blue:175/255.0f alpha:1.0];
                            },
                        @"4":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:96/255.0f green:125/255.0f blue:138/255.0f alpha:1.0];
                            },
                        @"5":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:121/255.0f green:85/255.0f blue:72/255.0f alpha:1.0];
                            },
                        @"6":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:0/255.0f green:77/255.0f blue:64/255.0f alpha:1.0];
                            },
                        @"7":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:0/255.0f green:96/255.0f blue:100/255.0f alpha:1.0];
                            },
                        @"8":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:21/255.0f green:31/255.0f blue:124/255.0f alpha:1.0];
                            },
                        @"9":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:70/255.0f green:32/255.0f blue:127/255.0f alpha:1.0];
                            },
                        @"А":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:230/255.0f green:54/255.0f blue:180/255.0f alpha:1.0];
                            },
                        @"Б":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:250/255.0f green:55/255.0f blue:122/255.0f alpha:1.0];
                            },
                        @"В":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:255/255.0f green:112/255.0f blue:102/255.0f alpha:1.0];
                            },
                        @"Г":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:255/255.0f green:123/255.0f blue:82/255.0f alpha:1.0];
                            },
                        @"Д":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:254/255.0f green:200/255.0f blue:7/255.0f alpha:1.0];
                            },
                        @"Е":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:96/255.0f green:219/255.0f blue:100/255.0f alpha:1.0];
                            },
                        @"Ё":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:194/255.0f green:35/255.0f blue:137/255.0f alpha:1.0];
                            },
                        @"Ж":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:232/255.0f green:30/255.0f blue:99/255.0f alpha:1.0];
                            },
                        @"З":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:243/255.0f green:67/255.0f blue:54/255.0f alpha:1.0];
                            },
                        @"И":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:254/255.0f green:87/255.0f blue:34/255.0f alpha:1.0];
                            },
                        @"Й":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:254/255.0f green:151/255.0f blue:0/255.0f alpha:1.0];
                            },
                        @"К":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:76/255.0f green:174/255.0f blue:80/255.0f alpha:1.0];
                            },
                        @"Л":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:124/255.0f green:21/255.0f blue:104/255.0f alpha:1.0];
                            },
                        @"М":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:135/255.0f green:14/255.0f blue:79/255.0f alpha:1.0];
                            },
                        @"Н":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:182/255.0f green:28/255.0f blue:28/255.0f alpha:1.0];
                            },
                        @"О":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:190/255.0f green:54/255.0f blue:12/255.0f alpha:1.0];
                            },
                        @"П":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:299/255.0f green:81/255.0f blue:0/255.0f alpha:1.0];
                            },
                        @"Р":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:27/255.0f green:94/255.0f blue:32/255.0f alpha:1.0];
                            },
                        @"С":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:0/255.0f green:181/255.0f blue:164/255.0f alpha:1.0];
                            },
                        @"Т":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:0/255.0f green:197/255.0f blue:222/255.0f alpha:1.0];
                            },
                        @"У":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:78/255.0f green:99/255.0f blue:219/255.0f alpha:1.0];
                            },
                        @"Ф":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:144/255.0f green:76/255.0f blue:228/255.0f alpha:1.0];
                            },
                        @"Х":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:210/255.0f green:53/255.0f blue:237/255.0f alpha:1.0];
                            },
                        @"Ц":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:121/255.0f green:157/255.0f blue:173/255.0f alpha:1.0];
                            },
                        @"Ч":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:176/255.0f green:124/255.0f blue:105/255.0f alpha:1.0];
                            },
                        @"Ш":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:0/255.0f green:149/255.0f blue:135/255.0f alpha:1.0];
                            },
                        @"Щ":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:0/255.0f green:172/255.0f blue:194/255.0f alpha:1.0];
                            },
                        @"Ъ":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:63/255.0f green:81/255.0f blue:180/255.0f alpha:1.0];
                            },
                        @"Ы":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:109/255.0f green:60/255.0f blue:178/255.0f alpha:1.0];
                            },
                        @"Ь":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:155/255.0f green:39/255.0f blue:175/255.0f alpha:1.0];
                            },
                        @"Э":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:96/255.0f green:125/255.0f blue:138/255.0f alpha:1.0];
                            },
                        @"Ю":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:121/255.0f green:85/255.0f blue:72/255.0f alpha:1.0];
                            },
                        @"Я":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:0/255.0f green:77/255.0f blue:64/255.0f alpha:1.0];
                            }
                        };
    
    CaseBlock c = d[str];
    if (c) c(); else {
        _avatar.fallbackColor = [UIColor orangeColor];
    }
    return _avatar.fallbackColor;
}
@end
