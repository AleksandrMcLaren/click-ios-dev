//
//  CKUserProfileController.m
//  click
//
//  Created by Igor Tetyuev on 19.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKUserProfileController.h"
#import "CKProfileHeaderView.h"
#import "CKCountrySelectionController.h"
#import "CKCountryCell.h"
#import "CKCitySelectionController.h"

@interface CKLoginInputCell : UITableViewCell

@property (nonatomic, readonly) UITextField *login;

@end

@implementation CKLoginInputCell
{
    UILabel *_check;
}

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([self class])])
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _login = [UITextField new];
        _login.placeholder = @"Логин";
        _login.tag = 2;
        [self.contentView addSubview:_login];
        
        _check = [UILabel labelWithText:@"Проверить" font:[UIFont systemFontOfSize:16.0] textColor:[UIColor grayColor] textAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_check];
        
        [_login makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.left).offset(16);
            make.centerY.equalTo(self.contentView.centerY);
            make.right.equalTo(_check.left).offset(-16);
        }];
        
        [_check makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.right);
            make.centerY.equalTo(self.contentView.centerY);
        }];
    }
    return self;
}

@end

@interface CKSubtitleCell : UITableViewCell

@end

@implementation CKSubtitleCell


- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([self class])])
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.textLabel.font = [UIFont systemFontOfSize:16.0];
        self.textLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.font = [UIFont systemFontOfSize:16.0];
        self.detailTextLabel.textColor = [UIColor grayColor];
    }
    return self;
}

@end

@interface CKSectionHeader : UIView;

@property (nonatomic, readonly) UILabel *label;

@end

@implementation CKSectionHeader
{
    UIView *_topSeparator;
    UIView *_bottomSeparator;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _topSeparator = [UIView new];
        _topSeparator.backgroundColor = CKClickProfileGrayColor;
        [self addSubview:_topSeparator];
        _bottomSeparator = [UIView new];
        _bottomSeparator.backgroundColor = CKClickProfileGrayColor;
        [self addSubview:_bottomSeparator];
        _label = [UILabel new];
        _label.textColor = [UIColor darkGrayColor];
        _label.font = [UIFont systemFontOfSize:16.0];
        [self addSubview:_label];
        self.backgroundColor = CKClickLightGrayColor;
        [_topSeparator makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left);
            make.right.equalTo(self.right);
            make.top.equalTo(self.top);
            make.height.equalTo(0.5);
        }];
        [_bottomSeparator makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left);
            make.right.equalTo(self.right);
            make.bottom.equalTo(self.bottom);
            make.height.equalTo(0.5);
        }];
        [_label makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left).offset(15);
            make.centerY.equalTo(self.centerY);
        }];
    }
    return self;
}

@end

@interface CKUserProfileController()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, CKCountrySelectionControllerDelegate, UITextFieldDelegate, CKCitySelectionControllerDelegate>

@end

@implementation CKUserProfileController

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Отменить" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
        self.title = @"Профиль";
        self.profile = [[CKApplicationModel sharedInstance] userProfile];
    }
    return self;
}

- (void)cancel
{
    [[CKApplicationModel sharedInstance] submitNewProfile];
}

- (void)viewDidLoad
{
    CKProfileHeaderView *header = [CKProfileHeaderView new];
    header.frame = CGRectMake(0, 0, self.view.bounds.size.width, 112);
    self.tableView.tableHeaderView = header;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    header.firstName.delegate = self;
    header.firstName.text = self.profile.name;
    header.secondName.delegate = self;
    header.secondName.text = self.profile.surname;
    [header.avatar setImage:self.profile.avatar forState:UIControlStateNormal];
    if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [header.avatar addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
}

- (void)takePhotoWithSource:(UIImagePickerControllerSourceType)source
{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = source;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSData *dataImage = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerEditedImage"],1);
    if (!dataImage)
    {
        dataImage = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"],1);
    }
    UIImage *img = [[UIImage alloc] initWithData:dataImage];
    CKProfileHeaderView *header = (CKProfileHeaderView *)self.tableView.tableHeaderView;
    [header.avatar setImage:img forState:UIControlStateNormal];
    self.profile.avatar = img;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)takePhoto
{
    
    UIAlertController *photoPicker = [UIAlertController alertControllerWithTitle:nil
                                                                          message:nil
                                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIImagePickerControllerSourceType lastSource = 0;
    for (NSArray *i in @[
                              @[@"Камера",@(UIImagePickerControllerSourceTypeCamera)],
                              @[@"Фотоальбом",@(UIImagePickerControllerSourceTypePhotoLibrary)],
                              @[@"Сохраненные фотографии",@(UIImagePickerControllerSourceTypeSavedPhotosAlbum)],
                              ])
    {
        if (![UIImagePickerController isSourceTypeAvailable:[i[1] integerValue]]) continue;
        lastSource = [i[1] integerValue];
        UIAlertAction *action = [UIAlertAction actionWithTitle:i[0]
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *a){
                                                                 [self takePhotoWithSource:[i[1] integerValue]];
                                                             }];
        [photoPicker addAction:action];
    }
    
    if (photoPicker.actions.count == 1)
    {
        // only one source
        [self takePhotoWithSource:lastSource];
        return;
    }
    if (photoPicker.actions.count == 0)
    {
        // no sources
        
        return;
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Отменить"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *a){
                                                             
                                                         }];
    [photoPicker addAction:cancelAction];
    
    [self presentViewController:photoPicker
                       animated:YES
                     completion:nil];
}

- (void)pickSex
{
    UIAlertController *sexPicker = [UIAlertController alertControllerWithTitle:nil
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    for (NSArray *i in @[
                         @[@"Мужской",@"m"],
                         @[@"Женский",@"f"],
                         @[@"Не указан",@""],
                         ])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:i[0]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *a){
                                                           NSLog(@"selected sex: %@", i[1]);
                                                           self.profile.sex = i[1];
                                                           [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                                                       }];
        [sexPicker addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Отменить"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *a){
                                                             [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                                                         }];
    [sexPicker addAction:cancelAction];
    
    [self presentViewController:sexPicker
                       animated:YES
                     completion:nil];
}

- (void)pickDate
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIDatePicker *picker = [[UIDatePicker alloc] init];
    
    NSDate *now = [NSDate date];
    NSDateComponents *minusAge = [NSDateComponents new];
    minusAge.year = -13;
    NSDate *yearsAgo = [[NSCalendar currentCalendar] dateByAddingComponents:minusAge
                                                                            toDate:now
                                                                           options:0];
    NSDateComponents *oldestAge = [NSDateComponents new];
    oldestAge.year = -110;
    NSDate *manyYearsAgo = [[NSCalendar currentCalendar] dateByAddingComponents:oldestAge
                                                                     toDate:now
                                                                    options:0];
    [picker setMaximumDate:yearsAgo];
    [picker setDate:yearsAgo];
    [picker setMinimumDate:manyYearsAgo];
    [picker setDatePickerMode:UIDatePickerModeDate];
    [alertController.view addSubview:picker];
    [picker makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(alertController.view.top);
        make.left.equalTo(alertController.view.left);
        make.width.equalTo(alertController.view.width);
    }];
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.profile.birthDate = picker.date;
           [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        }];
        action;
    })];
    
    UIAlertAction *notShowAction = [UIAlertAction actionWithTitle:@"Не указывать"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *a){
                                                             self.profile.birthDate = nil;
           [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                                                         }];
    [alertController addAction:notShowAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Отменить"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *a){
                                                             [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                                                         }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController  animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case 0:
            self.profile.name = textField.text;
            break;
        case 1:
            self.profile.surname = textField.text;
            break;
        case 2:
            self.profile.login = textField.text;
            break;
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 1:
        {
            CKSectionHeader *header = [CKSectionHeader new];
            return header;
        };
            break;
        case 2:
        {
            CKSectionHeader *header = [CKSectionHeader new];
            header.label.text = @"РАСПОЛОЖЕНИЕ";
            return header;
        }
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return 36.0;
            break;
        case 2:
            return 36.0;
            break;
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 3;
            break;
        default:
            break;
    }
    return 0;
}

+(NSString*)date2str:(NSDate*)date {
    if (!date) return @"Не указана";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];

    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            CKLoginInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CKLoginInputCell"];
            if (!cell)
            {
                cell = [CKLoginInputCell new];
            }
            cell.separatorInset = UIEdgeInsetsZero;
            cell.layoutMargins = UIEdgeInsetsZero;
            cell.preservesSuperviewLayoutMargins = NO;
            cell.login.delegate = self;
            cell.login.text = self.profile.login;
            return cell;
            
        }
            break;
        case 1:
        {
            CKSubtitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CKSubtitleCell"];
            if (!cell)
            {
                cell = [CKSubtitleCell new];
                cell.separatorInset = UIEdgeInsetsZero;
                cell.layoutMargins = UIEdgeInsetsZero;
                cell.preservesSuperviewLayoutMargins = NO;
            }
            switch (indexPath.row)
            {
                case 0:
                {
                    cell.textLabel.text = @"Пол";
                    NSDictionary *sexes = @{@"m":@"Мужской", @"f":@"Женский"};
                    NSString *sex = sexes[self.profile.sex];
                    if (!sex) sex = @"Не указан";
                    cell.detailTextLabel.text = sex;
                }
                    break;
                case 1:
                    cell.textLabel.text = @"Дата рождения";
                    cell.detailTextLabel.text = [CKUserProfileController date2str:self.profile.birthDate
                                                 ];
                    break;
            }
            return cell;
        }
            break;
        case 2:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetectLocationCell"];
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.textLabel.textColor = CKClickBlueColor;
                    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
                    cell.textLabel.text = @"Определить мое местоположение";
                    cell.separatorInset = UIEdgeInsetsZero;
                    cell.layoutMargins = UIEdgeInsetsZero;
                    cell.preservesSuperviewLayoutMargins = NO;
                    return cell;
                }
                    break;
                case 1:
                {
                    CKCountryCell *cell = [CKCountryCell new];
                    cell.title.text = self.profile.countryName;
                    cell.countryBall.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld", (long)self.profile.iso]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.separatorInset = UIEdgeInsetsZero;
                    cell.layoutMargins = UIEdgeInsetsZero;
                    cell.preservesSuperviewLayoutMargins = NO;
                    return cell;
                }
                    break;
                case 2:
                {
                    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CityCell"];
                    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.indentationLevel = 1;
                    cell.indentationWidth = 61;
                    cell.textLabel.text = self.profile.cityName;
                    if ([self.profile.cityName length] == 0)
                    {
                        cell.textLabel.text = @"Город";
                        cell.textLabel.textColor = CKClickProfileGrayColor;
                    } else
                    {
                        cell.textLabel.textColor = [UIColor blackColor];
                    }
                    cell.separatorInset = UIEdgeInsetsZero;
                    cell.layoutMargins = UIEdgeInsetsZero;
                    cell.preservesSuperviewLayoutMargins = NO;
                    return cell;
                }
                    break;
                default:
                    break;
                    
            }
        }
            break;
        default:
            break;
    }
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    switch (indexPath.section) {
        case 0:
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [self pickSex];
                    break;
                case 1:
                    [self pickDate];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                    break;
                case 1:
                {
                    CKCountrySelectionController *controller = [CKCountrySelectionController new];
                    controller.delegate = self;
                    [self.navigationController pushViewController:controller animated:YES];
                }
                    break;
                case 2:
                {
                    CKCitySelectionController *controller = [CKCitySelectionController new];
                    controller.countryId = self.profile.countryId;
                    controller.delegate = self;
                    [self.navigationController pushViewController:controller animated:YES];
                }
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

- (void)countrySelectionController:(CKCountrySelectionController *)controller didSelectCountryWithId:(NSInteger)id name:(NSString *)name code:(NSNumber *)code
{
    NSDictionary *country = [[CKApplicationModel sharedInstance] countryWithId:id];
    self.profile.iso = [country[@"iso"] integerValue];
    self.profile.countryId = id;
    self.profile.countryName = country[@"name"];
    self.profile.city = 0;
    self.profile.cityName = nil;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)citySelectionController:(CKCitySelectionController *)controller didSelectCityWithId:(NSInteger)id name:(NSString *)name
{
    self.profile.city = id;
    self.profile.cityName = name;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
