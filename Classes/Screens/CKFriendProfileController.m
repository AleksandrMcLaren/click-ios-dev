//
//  CKFriendProfileController.m
//  click
//
//  Created by Igor Tetyuev on 29.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKFriendProfileController.h"
#import "CKFriendProfileCell.h"
#import "CKFriendProfileHeaderCell.h"
#import "CKFriendProfileDetailCell.h"
#import "CKFriendProfileLocationCell.h"
#import "CKDialogChatController.h"

@implementation CKFriendProfileController
{
    CKUserModel *_user;
    CLGeocoder *_geocoder;
}

- (instancetype)initWithUser:(CKUserModel *)user
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        _user = user;
        _geocoder = [CLGeocoder new];
        if (!(_user.location.latitude==0 && _user.location.longitude == 0))
        {
            [_geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:_user.location.latitude longitude:_user.location.longitude] completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                NSLog(@"%@", placemarks);
            }];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    self.tableView.tableFooterView = [UIView new];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) return nil;
    UIView *v = [UIView new];
    v.backgroundColor = [UIColor colorFromHexString:@"#f4f4f5"];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) return 9.0;
    return 0.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 5;
            break;
        case 1:
            return 5;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            switch (indexPath.row)
        {
            case 0:
                return 158.0;
                break;
            case 1:
            case 2:
            case 3:
                return 56.0;
                break;
            case 4:
                return (_user.location.latitude==0 && _user.location.longitude == 0)?65.0:95.0;
                break;
        }
            break;
        case 1:
            return 44.0;
            break;
    }
    return 0;
}

- (void)openChat
{
    CKDialogChatController *ctl = [[CKDialogChatController alloc] initWithUserId:_user.id];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    CKFriendProfileHeaderCell *cell = [CKFriendProfileHeaderCell new];
                    cell.friend = _user;
                    [cell.openChat addTarget:self action:@selector(openChat) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                    break;
                case 1:
                {
                    CKFriendProfileDetailCell *cell = [CKFriendProfileDetailCell new];
                    
                    NSMutableString *stringts = [NSMutableString stringWithString:_user.id];
                    [stringts insertString:@"+" atIndex:0];
                    [stringts insertString:@" (" atIndex:2];
                    [stringts insertString:@") " atIndex:7];
                    [stringts insertString:@"-" atIndex:12];
                    [stringts insertString:@"-" atIndex:15];
                    
                    cell.detailLabel.text = stringts;
                    
                    NSMutableAttributedString *mobilestring = [NSMutableAttributedString new];
                    [mobilestring appendAttributedString:[NSMutableAttributedString withString:@"мобильный "]];
                    [mobilestring appendAttributedString:[NSMutableAttributedString withImageName:@"star_gray" geometry:CGRectMake(0, -2, 12, 12)]];
                    
                    cell.titleLabel.attributedText = mobilestring;
                    
                    return cell;
                }
                    break;
                case 2:
                {
                    CKFriendProfileDetailCell *cell = [CKFriendProfileDetailCell new];
                    cell.titleLabel.text = @"пол";
                    cell.detailLabel.text = @{@"":@"Не указан", @"f":@"Женский", @"m":@"Мужской"}[_user.sex];
                    return cell;
                }
                    break;
                case 3:
                {
                    CKFriendProfileDetailCell *cell = [CKFriendProfileDetailCell new];
                    cell.titleLabel.text = @"возраст";
                    cell.detailLabel.text = _user.age?@"Не указан":[NSString stringWithFormat:@"%ld лет", (long)_user.age];
                    return cell;
                }
                    break;
                case 4:
                {
                    CKFriendProfileLocationCell *cell = [CKFriendProfileLocationCell new];
                    cell.titleLabel.text = @"расположение";
                    if (_user.location.latitude==0 && _user.location.longitude == 0)
                    {
                        cell.detailLabel.text = @"Скрыто настройками приватности";
                        cell.distanceLabel.text = (_user.distance>1)?[NSString stringWithFormat:@"%.0fm", _user.distance]:@"";
                        cell.showMap.hidden = YES;
                    } else
                    {
                        cell.detailLabel.text = @"Не определено";
                        cell.distanceLabel.text = (_user.distance>1)?[NSString stringWithFormat:@"%.0fm", _user.distance]:@"";
                    }
                    return cell;
                }
                    break;
                default:
                    break;
            }

            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                {
                    CKFriendProfileCell *cell = [[CKFriendProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"switchCell"];
                    UISwitch *userBanSwitch = [UISwitch new];
                    cell.titleLabel.text = @"Заблокировать";
                    cell.accessoryView = userBanSwitch;
                    return cell;
                }
                    break;
                case 1:
                {
                    CKFriendProfileCell *cell = [[CKFriendProfileCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"mediaCell"];
                    cell.titleLabel.text = @"Медиафайлы";
                    cell.detailLabel.text = [NSString stringWithFormat:@"%d", 555];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                    break;
                case 2:
                {
                    CKFriendProfileCell *cell = [[CKFriendProfileCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"notificationsCell"];
                    cell.titleLabel.text = @"Уведомления";
                    cell.detailLabel.text = [NSString stringWithFormat:@"Нет"];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                    break;
                case 3:
                {
                    CKFriendProfileCell *cell = [[CKFriendProfileCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"commonGroupsCell"];
                    cell.titleLabel.text = @"Общие группы";
                    cell.detailLabel.text = [NSString stringWithFormat:@"555"];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                    break;
                case 4:
                {
                    CKFriendProfileCell *cell = [[CKFriendProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clearMessages"];
                    cell.titleLabel.text = @"Очистить Диалоги";
                    cell.titleLabel.textColor = CKClickBlueColor;
                    return cell;
                }
                    break;
                default:
                    break;
            }
            
            break;
    }
    return nil;
}

@end
