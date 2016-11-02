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
#import <SDWebImage/UIButton+WebCache.h>
#import "CKCache.h"
#import "UIView+Shake.h"
#import "UIButton+ContinueButton.h"
#import <Contacts/CNPostalAddress.h>
#import "NSString+Verify.h"

typedef enum CKLoginState{
    CKLoginStateVeryfying,
    CKLoginStateExist,
    CKLoginStateNotExist,
    CKLoginStateNone
}CKLoginState;

@interface CKLoginInputCell : UITableViewCell

@property (nonatomic, readonly, strong) UITextField *login;
@property (nonatomic, readonly, assign) CKLoginState loginState;
@end

@implementation CKLoginInputCell
{
    UILabel *_check;
    UIImageView* _loginStateImageView;
    UIActivityIndicatorView* _activityIndicator;
}

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([self class])])
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        _login = [UITextField new];
        _login.placeholder = @"Логин";
        _login.tag = 2;
        [self.contentView addSubview:_login];
        
//        _check = [UILabel labelWithText:@"Проверить" font:[UIFont systemFontOfSize:16.0] textColor:[UIColor grayColor] textAlignment:NSTextAlignmentRight];
//        [self.contentView addSubview:_check];
//        
        _loginStateImageView = [UIImageView new];
        _loginStateImageView.hidden = YES;
        _loginStateImageView.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:_loginStateImageView];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidden = YES;
        
        [self.contentView addSubview:_activityIndicator];
        
        
        float padding = CK_STANDART_CONTROL_PADDING;
        
        [_login makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.left).offset(padding);
            make.centerY.equalTo(self.contentView.centerY);
//            make.right.equalTo(_check.left).offset(-padding);
            
            make.right.equalTo(_loginStateImageView).offset(-2*padding);
        }];
        
//        [_check makeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(self.contentView.right);
//            make.centerY.equalTo(self.contentView.centerY);
//        }];
        
        [_loginStateImageView makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.centerY);
            make.right.equalTo(self.contentView.right).offset(-padding);
            make.height.equalTo(24);
            make.width.equalTo(24);
        }];
        
        [_activityIndicator makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.centerY);
            make.right.equalTo(self.contentView.right).offset(-padding);
        }];
        
        [self.contentView bringSubviewToFront:_activityIndicator];
        
        self.loginState = CKLoginStateNone;
    }
    return self;
}

-(void)setLoginState:(CKLoginState)loginState{
    if (_loginState != loginState) {
        _loginState = loginState;
        switch (_loginState) {
            case CKLoginStateVeryfying:
                _loginStateImageView.hidden = YES;
                _activityIndicator.hidden = NO;
                 [_activityIndicator startAnimating];
                break;
            case CKLoginStateExist:
                [_activityIndicator stopAnimating];
                _loginStateImageView.image = [UIImage imageNamed:@"ic_cancel_red"];
                _loginStateImageView.hidden = NO;
                _activityIndicator.hidden = YES;
                break;
            case CKLoginStateNotExist:
                [_activityIndicator stopAnimating];
                _loginStateImageView.image = [UIImage imageNamed:@"ic_ok_green"];
                _loginStateImageView.hidden = NO;
                _activityIndicator.hidden = YES;
                break;
            case CKLoginStateNone:
                [_activityIndicator stopAnimating];
                _loginStateImageView.image = nil;
                _loginStateImageView.hidden = YES;
                _activityIndicator.hidden = YES;
                break;
                
            default:
                break;
        }
    }
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

@interface CKUserProfileController()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, CKCountrySelectionControllerDelegate, UITextFieldDelegate, CKCitySelectionControllerDelegate, UITableViewDataSource, UITableViewDelegate>{
    NSString* _originalLogin;
    NSTimer* _loginVerifyTimer;
    CKLoginInputCell* _loginCell;
    UITapGestureRecognizer* _tapRecognizerForHide;
    UIActivityIndicatorView* _locationActivityIndicatorView;
}

@property (nonatomic, strong) UITableView* tableView;
@property (strong, nonatomic) RACCommand *executeSearch;

@end

@implementation CKUserProfileController

- (instancetype)init
{
    if (self = [super init])
    {
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Отменить" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
        self.title = @"Профиль";
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        self.profile = [[CKApplicationModel sharedInstance] userProfile];
    }
    return self;
}

- (void)contune
{
    [self dismissKeyboard];
    
    CKProfileHeaderView *header = (CKProfileHeaderView *)self.tableView.tableHeaderView;
    
    if (!header.firstName.text.length) {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [header.firstName shake];
        return;
    }
    if (!header.secondName.text.length) {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [header.secondName shake];
        return;
    }
    if (!_loginCell.login.text.length) {
        [_loginCell.login shake];
        return;
    }
    
    NSRange nonLatinSymbols = [_loginCell.login.text nonLatinSymbols];
    NSMutableAttributedString *attributedLogin =  [[NSMutableAttributedString alloc] initWithString:_loginCell.login.text];
    
    if (nonLatinSymbols.location != NSNotFound) {
         [_loginCell.login shake];
        [UIView transitionWithView:_loginCell.login duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

            [attributedLogin addAttribute:NSForegroundColorAttributeName
                                    value:[UIColor redColor]
                                    range:nonLatinSymbols];

            [_loginCell.login setAttributedText: attributedLogin];

        } completion:^(BOOL finished) {
            [attributedLogin addAttribute:NSForegroundColorAttributeName
                                    value:[UIColor blackColor]
                                    range:NSMakeRange(0, attributedLogin.length)];
            
            [_loginCell.login setAttributedText: attributedLogin];
            
        }];
        return;
    }

    
    if (_loginCell.loginState != CKLoginStateNotExist) {
        [_loginCell.login shake];
        return;
    }
    
    [[CKApplicationModel sharedInstance] submitNewProfile];
}

- (void)viewDidLoad
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = CKScreenHeight < 500;
    [self.view addSubview:self.tableView];
    
    CKProfileHeaderView *header = [CKProfileHeaderView new];
    header.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 80+16);
    self.tableView.tableHeaderView = header;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    header.firstName.delegate = self;
    header.firstName.text = self.profile.name;
    header.secondName.delegate = self;
    header.secondName.text = self.profile.surname;
    
    if (self.profile.avatar) {
        [header.avatar setImage:self.profile.avatar forState:UIControlStateNormal];
    }else{
        [header.avatar sd_setImageWithURL:[NSURL URLWithString:[[CKApplicationModel sharedInstance] userProfile].avatarURLString] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [[CKCache sharedInstance] putImage:image withURLString:[[CKApplicationModel sharedInstance] userProfile].avatarURLString];
                [[CKApplicationModel sharedInstance] userProfile].avatar = image;
        }];
    }
    if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [header.avatar addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    self.continueButton = [[UIButton alloc] initContinueButton];
    
    [self.view addSubview:self.continueButton];
    [self.continueButton addTarget:self action:@selector(contune) forControlEvents:UIControlEventTouchUpInside];
 
    float padding = CK_STANDART_CONTROL_PADDING;
    [self.continueButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.bottom.equalTo(self.view.bottom).offset(-padding);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
    }];
    
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top);
        make.bottom.equalTo(self.continueButton.top).offset(-padding*0.5);
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
    }];

}

- (void)takePhotoWithSource:(NSInteger)source
{
    if (source == -1) {
//        NSData* dataImage = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"],1);
//        UIImage* img = [[UIImage alloc] initWithData:dataImage];
        CKProfileHeaderView *header = (CKProfileHeaderView *)self.tableView.tableHeaderView;
        [header.avatar setImage:nil forState:UIControlStateNormal];
        self.profile.avatar = nil;
    }else{
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.sourceType = (UIImagePickerControllerSourceType)source;
        picker.delegate = self;
        picker.allowsEditing = YES;
        [self presentViewController:picker animated:YES completion:nil];
    }
    
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
    
    
    NSMutableArray* items = @[
                              @[@"Камера",@(UIImagePickerControllerSourceTypeCamera)],
                              @[@"Фотоальбом",@(UIImagePickerControllerSourceTypePhotoLibrary)],
                              @[@"Сохраненные фотографии",@(UIImagePickerControllerSourceTypeSavedPhotosAlbum)],
                              @[@"Удалить",@(-1)],
                              ].mutableCopy;

    for (NSArray *i in items)
    {
        NSInteger actionType = [i[1] integerValue];
        if (actionType == -1) {
            if (!self.profile.avatar) {
                continue;
            }
        }else if (![UIImagePickerController isSourceTypeAvailable:actionType]) {
            continue;
        }
      
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:_loginCell.login]) {
        NSString *newLogin = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self startVerifyLogin:newLogin];
        
    }
    
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
            self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            self.activityIndicatorView.hidesWhenStopped = YES;
            [header addSubview:self.activityIndicatorView];
            
            [self.activityIndicatorView makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(header.center);
            }];
            
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
            _loginCell = [tableView dequeueReusableCellWithIdentifier:@"CKLoginInputCell"];
            if (!_loginCell)
            {
                _loginCell = [CKLoginInputCell new];
            }
            _loginCell.separatorInset = UIEdgeInsetsZero;
            _loginCell.layoutMargins = UIEdgeInsetsZero;
            _loginCell.preservesSuperviewLayoutMargins = NO;
            _loginCell.login.delegate = self;
            _loginCell.login.text = self.profile.login;
//            _loginTextField = cell.login;
            _loginCell.loginState = self.profile.isCreated && self.profile.login.length ?  CKLoginStateNotExist : CKLoginStateNone;
            return _loginCell;
            
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
                    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
                    cell.textLabel.text = @"Определить мое местоположение";
                    [cell.textLabel sizeToFit];
                    cell.separatorInset = UIEdgeInsetsZero;
                    cell.layoutMargins = UIEdgeInsetsZero;
                    cell.preservesSuperviewLayoutMargins = NO;
                    
                    _locationActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    _locationActivityIndicatorView.hidden = YES;
                    _locationActivityIndicatorView.hidesWhenStopped = YES;
                    
                    [cell addSubview:_locationActivityIndicatorView];
                    
                    [_locationActivityIndicatorView makeConstraints:^(MASConstraintMaker *make) {
                        make.right.equalTo(cell.right).offset(-8);
                        make.centerY.equalTo(cell.centerY);
                    }];
                    
                    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locate)];
                    tapGestureRecognizer.numberOfTapsRequired = 1;
                    [cell.textLabel addGestureRecognizer:tapGestureRecognizer];
                    cell.textLabel.userInteractionEnabled = YES;
                    
                    return cell;
                }
                    break;
                case 1:
                {
                    CKCountryCell *cell = [CKCountryCell new];
                    if (self.profile.countryName.length) {
                        cell.title.text = self.profile.countryName;
                        cell.title.textColor = [UIColor blackColor];
                    }else{
                        cell.title.text = @"Страна";
                        cell.title.textColor = CKClickProfileGrayColor;
                    }
                    
                    [[RACObserve(cell.countryBall, image)
                     map:^id(UIImage* image) {
                         return @(image == nil);
                     }]
                     subscribeNext:^(id x) {
                         cell.countryBall.hidden = [x boolValue];
                    }];
                    
                    cell.countryBall.image = self.profile.iso ? [UIImage imageNamed:[NSString stringWithFormat:@"%ld", (long)self.profile.iso]] : nil;
                    
                    
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
    [self didSelectCountry:country];
}

-(void)didSelectCountry:(NSDictionary*) country{
    self.profile.iso = [country[@"iso"] integerValue];
    self.profile.countryId = [country[@"id"] integerValue];
    self.profile.countryName = country[@"name"];
    self.profile.city = 0;
    self.profile.cityName = nil;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)citySelectionController:(CKCitySelectionController *)controller didSelectCityWithId:(NSInteger)id name:(NSString *)name
{
    [self didSelectCityWithId:id name:name];
}

- (void)didSelectCityWithId:(NSInteger)id name:(NSString *)name
{
    self.profile.city = id;
    self.profile.cityName = name ? name : @"";
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:NO];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) setProfile:(CKUserModel *)profile{
    _profile = profile;
    if (_profile.login.length) {
        _originalLogin = _profile.login;
    }
}

-(void) startVerifyLogin:(NSString*)login{
    
    NSRange nonLatinSymbols = [login nonLatinSymbols];
    
    if (nonLatinSymbols.location != NSNotFound) {
        _loginCell.loginState = CKLoginStateExist;
        return;
    }
    
    if (login.length < 5) {
        _loginCell.loginState = CKLoginStateExist;
        return;
    }
    
    _loginCell.loginState = CKLoginStateVeryfying;
    
    if (_loginVerifyTimer != nil) {
        [_loginVerifyTimer invalidate];
        _loginVerifyTimer = nil;
    }
    
    // reschedule the search: in 1.0 second, call the searchForKeyword: method on the new textfield content
    _loginVerifyTimer = [NSTimer scheduledTimerWithTimeInterval: 2.0
                                                        target: self
                                                      selector: @selector(searchForKeyword:)
                                                      userInfo: login
                                                       repeats: NO];
};

- (void) searchForKeyword:(NSTimer *)timer
{
    // retrieve the keyword from user info
    NSString *login = (NSString*)timer.userInfo;
    
    [[CKApplicationModel sharedInstance] checkUserLogin:login withCallback:^(id model) {
        _loginCell.loginState = [model boolValue] ? CKLoginStateNotExist : CKLoginStateNotExist;
    }];
}

#pragma mark Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification
{
    _tapRecognizerForHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    _tapRecognizerForHide.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:_tapRecognizerForHide];
}


- (void)keyboardFrameChanged:(NSNotification *)notification
{
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:_tapRecognizerForHide];
}


- (void)dismissKeyboard
{
    CKProfileHeaderView *header = (CKProfileHeaderView *)self.tableView.tableHeaderView;
    
    if (header.firstName.isFirstResponder) [header.firstName resignFirstResponder];
    if (header.secondName.isFirstResponder) [header.secondName resignFirstResponder];
}


- (void) viewTapped {
    [self dismissKeyboard];
}


#pragma mark Location

-(void)locate{
    [_locationActivityIndicatorView startAnimating];
    [[CKApplicationModel sharedInstance] getLocationInfowithCallback:^(NSDictionary* result) {
        [_locationActivityIndicatorView stopAnimating];
        
        NSString* countryid = result[@"countryid"] ? result[@"countryid"] : nil;
        NSString* countryname = result[@"countryname"] ? result[@"countryname"] : nil;
        NSInteger iso = result[@"iso"] ? [result[@"iso"] integerValue ]: 0;
        
        if (countryid && countryname) {
            [self didSelectCountry:@{@"iso":@(iso), @"id":countryid, @"name":countryname}];
        }
        
        NSInteger cityid = result[@"cityid"] ? [result[@"cityid"] integerValue] : 0;
        NSString* cityname = result[@"cityname"] ? result[@"cityname"] : nil;
        
        if (cityname) {
            [self didSelectCityWithId:cityid name:result[@"cityname"]  ];
        }
        

    }];


}


@end
