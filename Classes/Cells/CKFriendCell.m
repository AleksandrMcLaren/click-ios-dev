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
        //_avatar.fallbackColor = [self setColorToAvatar];
        
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
        //_login = [UILabel labelWithText:_login.text font:[UIFont systemFontOfSize:10.0] textColor:[UIColor grayColor] textAlignment:NSTextAlignmentLeft];
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
        //_login = [UILabel labelWithText:_login.text font:[UIFont boldSystemFontOfSize:12.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
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

- (void)setFriend:(CKUser *)friend
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
}

- (UIColor *) setColorToAvatar
{
    _avatar.fallbackColor = [UIColor orangeColor];
    NSString *str = [_avatar.user.name substringToIndex:1];
    
    typedef void (^CaseBlock)();
    
    // Squint and this looks like a proper switch!
    NSDictionary *d = @{
                        @"A":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:230 green:54 blue:180 alpha:1.0];
                            },
                        @"B":
                            ^{
                                _avatar.fallbackColor = [UIColor orangeColor];
                            },
                        @"C":
                            ^{
                                _avatar.fallbackColor = [UIColor orangeColor];
                            },
                        @"D":
                            ^{
                                _avatar.fallbackColor = [UIColor orangeColor];
                            },
                        @"E":
                            ^{
                                _avatar.fallbackColor = [UIColor orangeColor];
                            },
                        @"F":
                            ^{
                                _avatar.fallbackColor = [UIColor orangeColor];
                            },
                        @"G":
                            ^{
                                _avatar.fallbackColor = [UIColor colorWithRed:96 green:219 blue:100 alpha:1.0];
                            },
                        @"H":
                            ^{
                                _avatar.fallbackColor = [UIColor orangeColor];
                            }
                        };
    
    CaseBlock c = d[str];
    if (c) c(); else {
        _avatar.fallbackColor = [UIColor orangeColor];
    }
    return _avatar.fallbackColor;
}
/*
 switch (lastChar.charAt(0))
 {
 case 'A':
 rgb = new int[]{230, 54, 180};
 break;
 case 'B':
 rgb = new int[]{250, 55, 122};
 break;
 case 'C':
 rgb = new int[]{255, 112, 102};
 break;
 case 'D':
 rgb = new int[]{255, 123, 82};
 break;
 case 'E':
 rgb = new int[]{254, 200, 7};
 break;
 case 'F':
 rgb = new int[]{96, 219, 100};
 break;
 case 'G':
 rgb = new int[]{194, 35, 137};
 break;
 case 'H':
 rgb = new int[]{232, 30, 99};
 break;
 case 'I':
 rgb = new int[]{243, 67, 54};
 break;
 case 'J':
 rgb = new int[]{254, 87, 34};
 break;
 case 'K':
 rgb = new int[]{254, 151, 0};
 break;
 case 'L':
 rgb = new int[]{76, 174, 80};
 break;
 case 'M':
 rgb = new int[]{124, 21, 104};
 break;
 case 'N':
 rgb = new int[]{135, 14, 79};
 break;
 case 'O':
 rgb = new int[]{182, 28, 28};
 break;
 case 'P':
 rgb = new int[]{190, 54, 12};
 break;
 case 'Q':
 rgb = new int[]{229, 81, 0};
 break;
 case 'R':
 rgb = new int[]{27, 94, 32};
 break;
 case 'S':
 rgb = new int[]{0, 181, 164};
 break;
 case 'T':
 rgb = new int[]{0, 197, 222};
 break;
 case 'U':
 rgb = new int[]{78, 99, 219};
 break;
 case 'V':
 rgb = new int[]{144, 76, 228};
 break;
 case 'W':
 rgb = new int[]{210, 53, 237};
 break;
 case 'X':
 rgb = new int[]{121, 157, 173};
 break;
 case 'Y':
 rgb = new int[]{176, 124, 105};
 break;
 case 'Z':
 rgb = new int[]{0, 149, 135};
 break;
 case '0':
 rgb = new int[]{0, 172, 194};
 break;
 case '1':
 rgb = new int[]{63, 81, 180};
 break;
 case '2':
 rgb = new int[]{109, 60, 178};
 break;
 case '3':
 rgb = new int[]{155, 39, 175};
 break;
 case '4':
 rgb = new int[]{96, 125, 138};
 break;
 case '5':
 rgb = new int[]{121, 85, 72};
 break;
 case '6':
 rgb = new int[]{0, 77, 64};
 break;
 case '7':
 rgb = new int[]{0, 96, 100};
 break;
 case '8':
 rgb = new int[]{21, 31, 124};
 break;
 case '9':
 rgb = new int[]{70, 32, 127};
 break;
 default:
 rgb = new int[]{113, 28, 128};
 break;
 }
 */

@end
