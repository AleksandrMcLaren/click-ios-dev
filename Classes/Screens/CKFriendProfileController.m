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
#import "CKMessageServerConnection.h"

@implementation CKFriendProfileController
{
    
    CLGeocoder *_geocoder;
    
    NSArray *fullContactList;
    CKPhoneContact *chosenContact;
    CKFriendProfileHeaderCell *cellHeader;
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
    fullContactList = [[CKApplicationModel sharedInstance] fullContacts];
    return self;
}

- (void)viewDidLoad
{
    if (_wentFromTheMap == true)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"К карте" style: UIBarButtonItemStylePlain target:self action:@selector(backToMap)];
    }
    self.tableView.tableFooterView = [UIView new];
}

- (void) viewWillAppear:(BOOL)animated
{
    for (CKPhoneContact *i in fullContactList) {
        NSString *phoneNumber = i.phoneNumber;
        if (phoneNumber.length == 11 && ([[phoneNumber substringToIndex:1]  isEqual: @"8"]))
        {
            phoneNumber = [phoneNumber stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"7"];
        }
        if ([phoneNumber isEqual: _user.id])
        {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"В адресную книгу" style: UIBarButtonItemStylePlain target:self action:@selector(goToTheAddressBook)];
            chosenContact = i;
            break;
        }
    }
    
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
            return 4;
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
                //return (_user.location.latitude==0 && _user.location.longitude == 0)?65.0:95.0;
                return 65.0;
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

- (void)setLike
{
    
    if (_user.isLiked == 1)
    {
        cellHeader.isLiked = NO;
        [[CKMessageServerConnection sharedInstance] setLike:_user.id withValue:@0];
        NSInteger likesCount = _user.likes - 1;
        [cellHeader setNumberOfLikes: likesCount];
        [[CKApplicationModel sharedInstance] UpdateUserInfo:_user.id callback:^(CKUserModel* newModel) {
            _user = newModel;
        }];
        
    }
    else
    {
        cellHeader.isLiked = YES;
        [[CKMessageServerConnection sharedInstance] setLike:_user.id withValue:@1];
        NSInteger likesCount = _user.likes + 1;
        [cellHeader setNumberOfLikes: likesCount];
        [[CKApplicationModel sharedInstance] UpdateUserInfo:_user.id callback:^(CKUserModel* newModel) {
            _user = newModel;
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        case 1:
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
            
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    cellHeader = [CKFriendProfileHeaderCell new];
                    if (_user.isLiked == 1) cellHeader.isLiked = YES;
                    else cellHeader.isLiked = NO;
                    cellHeader.friend = _user;
                    [cellHeader.likes addTarget:self action:@selector(setLike) forControlEvents:UIControlEventTouchUpInside];
                    [cellHeader.openChat addTarget:self action:@selector(openChat) forControlEvents:UIControlEventTouchUpInside];
                    return cellHeader;
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
                    cell.titleLabel.text = @"Расположение";
                    if (_user.location.latitude==0 && _user.location.longitude == 0)
                    {
                        cell.detailLabel.text = @"Скрыто настройками приватности";
                        cell.distanceLabel.text = (_user.distance>1)?[NSString stringWithFormat:@"%.0fm", _user.distance]:@"";
                        cell.showMap.hidden = YES;
                    } else
                    {
                        if (_user.countryId == 0)
                        {
                            cell.detailLabel.text = @"Не определено";
                            cell.distanceLabel.text = (_user.distance>1)?[NSString stringWithFormat:@"%.0fm", _user.distance]:@"";
                        }
                        else
                        {
                            if (_user.city !=0)
                            {
                                cell.detailLabel.text = [NSString stringWithFormat:@"%@, %@", _user.countryName, _user.cityName];
                            }
                            else
                            {
                                cell.detailLabel.text = _user.countryName;
                            }
                            cell.distanceLabel.text = (_user.distance>1)?[NSString stringWithFormat:@"%.0fm", _user.distance]:@"";
                            
                        }
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
                    cell.titleLabel.text = @"Не беспокоить";
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
                    //                case 2:
                    //                {
                    //                    CKFriendProfileCell *cell = [[CKFriendProfileCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"notificationsCell"];
                    //                    cell.titleLabel.text = @"Уведомления";
                    //                    cell.detailLabel.text = [NSString stringWithFormat:@"Нет"];
                    //                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    //                    return cell;
                    //                }
                    //                    break;
                case 2:
                {
                    CKFriendProfileCell *cell = [[CKFriendProfileCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"commonGroupsCell"];
                    cell.titleLabel.text = @"Общие группы";
                    cell.detailLabel.text = [NSString stringWithFormat:@"555"];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                    break;
                case 3:
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

- (void) backToMap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) goToTheAddressBook
{
    CNContactStore *store = [[CNContactStore alloc] init];
    
    CNMutableContact *contact = [[CNMutableContact alloc] init];
    contact.givenName = chosenContact.name;
    contact.familyName = chosenContact.surname;
    CNLabeledValue *homePhone =  [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[CNPhoneNumber phoneNumberWithStringValue:chosenContact.phoneNumber]];
    contact.phoneNumbers = @[homePhone];
    
    CNContactViewController *controller = [CNContactViewController viewControllerForContact:contact];
    
    controller.contactStore = store;
    controller.delegate = self;
    controller.title = @"";
    
    UINavigationController *newNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Вернуться к контакту" style:UIBarButtonItemStylePlain target:self action:@selector(backToContact)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [controller setAllowsEditing:NO];
    [controller setToolbarItems:[[NSArray alloc] initWithObjects:flexibleSpace, doneButton, flexibleSpace, nil] animated:NO];
    
    newNavigationController.toolbarHidden = NO;
    controller.edgesForExtendedLayout = UIRectEdgeNone;
    [self presentViewController:newNavigationController animated:YES completion:nil];

}



- (void) backToContact
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
