//
//  CKLoginViewController.m
//  click
//
//  Created by Igor Tetyuev on 09.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKLoginViewController.h"
#import "UIColor+hex.h"
#import "UILabel+utility.h"
#import "CKApplicationModel.h"
#import "CKCountryCell.h"
#import "CKCountrySelectionController.h"
#import "CKTextEntryCell.h"
#import "CKPromoInfoController.h"
#import "CKLoginCodeViewController.h"
#import "UIView+Shake.h"
#import "CKOperationsProtocol.h"
#import "UIButton+ContinueButton.h"
#import "Reachability.h"

@interface CKLoginViewController()<CKCountrySelectionControllerDelegate, UITextFieldDelegate, CKOperationsProtocol>

@property (nonatomic, strong) NSMutableArray *animatableConstraints;

@end

@implementation CKLoginViewController
{
    UITableView *_tableView;
    NSInteger _countryId;
    NSString *_phoneCode;
    UITextField *_phoneTextField;
    UITextField *_promoTextField;
    CGFloat _keyboardHeight;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];

        self.title = @"Настройка MessMe";
        _countryId = [[CKApplicationModel sharedInstance] countryId];
        

    }
    return self;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // do something before rotation
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // do something after rotation
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = CKClickLightGrayColor;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    UILabel *header = [UILabel labelWithText:@"Введите код страны\nи ваш номер телефона"
                                                   font:[UIFont systemFontOfSize:16.0]
                                              textColor:[UIColor blackColor]
                                          textAlignment:NSTextAlignmentCenter];
    header.numberOfLines = 2;
//    header.frame = self.view.bounds;
    header.backgroundColor = self.view.backgroundColor;
    [header setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CK_STANDART_CONTROL_HEIGHT)];
    
//    [header sizeToFit];
//    CGSize s = header.frame.size;
//    header.frame = CGRectMake(0, 0, s.width, s.height+10);
    _tableView.tableHeaderView = header;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
//    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [self.view addSubview:_tableView];
    [_tableView reloadData];
    [_tableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(self.view.top);
        make.width.equalTo(self.view.width);
        make.height.equalTo(@(_tableView.contentSize.height));
    }];
    
    self.continueButton = [[UIButton alloc] initContinueButton];

    [self.view addSubview:self.continueButton];
    [self.continueButton addTarget:self action:@selector(continue) forControlEvents:UIControlEventTouchUpInside];
    
    float padding = CK_STANDART_CONTROL_PADDING;
    [self.continueButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(CK_STANDART_CONTROL_HEIGHT);
        make.bottom.equalTo(self.view.bottom).offset(-padding);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
    }];
    
    [self.activityIndicatorView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.continueButton.centerX);
        make.bottom.equalTo(self.continueButton.top).offset(-padding);
    }];
}

- (void)continue
{
    
    NSDictionary *countryData = [[CKApplicationModel sharedInstance] countryWithId:_countryId];

    if (![self isPhoneValid]) {
        [_phoneTextField shake];
        return;
    }
    
    [self dismissKeyboard];
    
    
    NSString *title = @"Проверка номера телефона";
    NSString *message = [NSString stringWithFormat:@"Это ваш правильный номер?\n\n+%@ %@\n\nSMS с вашим кодом доступа будет отправлено на этот номер", countryData[@"phonecode"],_phoneTextField.text];
    NSString *cancel = @"Изменить";
    NSString *confirm = @"OK";
    
    UIAlertController *phoneWarning = [UIAlertController alertControllerWithTitle:title
                                                                          message:message
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *a){
                                                             
                                                         }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirm
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *a) {
                                                              [[CKApplicationModel sharedInstance]
                                                                sendUserPhone:[NSString stringWithFormat:@"%@%@", countryData[@"phonecode"], _phoneTextField.text]
                                                                promo:_promoTextField.text
                                                                countryId:_countryId];
                                                          }];
    [phoneWarning addAction:confirmAction];
    [phoneWarning addAction:cancelAction];
    
    [self presentViewController:phoneWarning
                       animated:YES
                     completion:nil];
}


#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 0;
    return CK_STANDART_CONTROL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) return nil;
    UILabel *header = [UILabel labelWithText:@"Код доступа будет выслан вам\nв SMS сообщении"
                                        font:[UIFont systemFontOfSize:16.0]
                                   textColor:[UIColor blackColor]
                               textAlignment:NSTextAlignmentCenter];
    header.numberOfLines = 2;
    header.frame = self.view.bounds;
    header.backgroundColor = self.view.backgroundColor;
//    [header sizeToFit];
     [header setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CK_STANDART_CONTROL_HEIGHT)];
    return header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [@[@2,@1][section] integerValue];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *countryData = [[CKApplicationModel sharedInstance] countryWithId:_countryId];
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                CKCountryCell *cell = [CKCountryCell new];
                cell.title.text = countryData[@"name"];
                cell.countryBall.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", [countryData objectForKey:@"iso"]]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
                break;
            case 1:
            {
                CKTextEntryCell *cell = [CKTextEntryCell new];
                cell.title.text = [NSString stringWithFormat:@"+%@", countryData[@"phonecode"]];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (!_phoneTextField)
                {
                    cell.textField.placeholder = @"Ваш номер телефона";
                    _phoneTextField = cell.textField;
                    _phoneTextField.delegate = self;
                    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
                    _phoneTextField.clearButtonMode = UITextFieldViewModeAlways;
                    
                } else
                {
                    cell.textField = _phoneTextField;
                }
                return cell;
            }
                break;
        }
    }
    if (indexPath.section == 1)
    {
        CKTextEntryCell *cell = [CKTextEntryCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.title.text = @"";
        if (!_promoTextField)
        {
            cell.textField.placeholder = @"Введите промо код";
            _promoTextField = cell.textField;
            _promoTextField.delegate = self;
            _promoTextField.keyboardType = UIKeyboardTypeASCIICapable;
            _promoTextField.returnKeyType = UIReturnKeyDone;

        } else
        {
            cell.textField = _promoTextField;
        }
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 1)
    {
        CKPromoInfoController *controller = [CKPromoInfoController new];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0)
    {
        CKCountrySelectionController *selection = [CKCountrySelectionController new];
        selection.delegate = self;
        [self.navigationController pushViewController:selection animated:YES];
    }
}

- (void)countrySelectionController:(CKCountrySelectionController *)controller didSelectCountryWithId:(NSInteger)id name:(NSString *)name code:(NSNumber *)code
{
    _countryId = id;
    [_tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_phoneTextField.isFirstResponder) {
    
    }
    if (_promoTextField.isFirstResponder) {
        [_promoTextField resignFirstResponder];
    };
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    
    // if it's the phone number textfield format it.
    if(textField == _phoneTextField ) {
        if (range.length == 1) {
            // Delete button was hit.. so tell the method to delete the last char.
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:YES];
        } else {
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:NO ];
        }
        return false;
    }
    
    return YES; 
}

- (NSString*)formatPhoneNumber:(NSString*) simpleNumber deleteLastChar:(BOOL)deleteLastChar {
    if(simpleNumber.length==0) return @"";
    
    NSCharacterSet *setToRemove =
    [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSCharacterSet *setToKeep = [setToRemove invertedSet];
    
    simpleNumber =  [[simpleNumber componentsSeparatedByCharactersInSet:setToKeep] componentsJoinedByString:@""];
    
    
    // check if the number is to long
    if(simpleNumber.length>10) {
        // remove last extra chars.
        simpleNumber = [simpleNumber substringToIndex:10];
    }
    
    if(deleteLastChar) {
        // should we delete the last digit?
        simpleNumber = [simpleNumber substringToIndex:[simpleNumber length] - 1];
    }
    
    // 123 456 7890
    // format the number.. if it's less then 7 digits.. then use this regex.
    if(simpleNumber.length<7)
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                               withString:@"($1) $2"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    
    else   // else do this one..
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"($1) $2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    return simpleNumber;
}

#pragma mark Methods

-(BOOL) isPhoneValid {
    NSString *phoneNumber = [[[[_phoneTextField.text stringByReplacingOccurrencesOfString:@"(" withString:@""]
                              stringByReplacingOccurrencesOfString:@")" withString:@""]
                             stringByReplacingOccurrencesOfString:@"-" withString:@""]
                             stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *phoneRegex = @"[235689][0-9]{6}([0-9]{3})?";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    BOOL matches = [test evaluateWithObject:phoneNumber];
    return matches;
}

#pragma mark Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification
{
    _keyboardHeight =  [self keyboardHeightByKeyboardNotification:notification];;
    [self updateFrames];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    self.tapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.tapRecognizer];
}


- (void)keyboardFrameChanged:(NSNotification *)notification
{
    _keyboardHeight =  [self keyboardHeightByKeyboardNotification:notification];;
    
    [self updateFrames];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    _keyboardHeight = 0;
    
    [self.view removeGestureRecognizer:self.tapRecognizer];
    self.tapRecognizer = nil;
    
    [self updateFrames];
}

-(CGFloat)keyboardHeightByKeyboardNotification:(NSNotification *)notification
{
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    return (_phoneTextField.isFirstResponder) ? CGRectGetHeight(keyboardRect) : 0;
}

- (void)dismissKeyboard
{
    if (_phoneTextField.isFirstResponder) [_phoneTextField resignFirstResponder];
    if (_promoTextField.isFirstResponder) [_promoTextField resignFirstResponder];
}

- (void)updateFrames{
    float padding = CK_STANDART_CONTROL_PADDING;
    [self.continueButton updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom).offset(-padding-_keyboardHeight);
    }];
}




@end
