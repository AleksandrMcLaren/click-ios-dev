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

#define CONTROL_PADDING  15.0;

@interface CKLoginViewController()<CKCountrySelectionControllerDelegate, UITextFieldDelegate>


@end

@implementation CKLoginViewController
{
    UITableView *_tableView;
    NSInteger _countryId;
    NSString *_phoneCode;
    UITextField *_phoneTextField;
    UITextField *_promoTextField;
    CGFloat _keyboardHeight;
    UIButton *_continueButton;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateFrames
{
//    _tableView.contentOffset = CGPointMake(0, _keyboardHeight);

    float padding = CONTROL_PADDING;
    [_continueButton updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom).offset(-padding-_keyboardHeight);
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGFloat keyboardHeight = [self keyboardHeightByKeyboardNotification:notification];
    _keyboardHeight = keyboardHeight;
    [self updateFrames];
}

- (void)keyboardFrameChanged:(NSNotification *)notification
{
    CGFloat keyboardHeight = [self keyboardHeightByKeyboardNotification:notification];
    _keyboardHeight = keyboardHeight;
    
    [self updateFrames];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    _keyboardHeight = 0;
    [self updateFrames];
}

-(CGFloat)keyboardHeightByKeyboardNotification:(NSNotification *)notification
{
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    return CGRectGetHeight(keyboardRect);
}

- (void) viewDidLoad
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = CKClickLightGrayColor;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    UILabel *header = [UILabel labelWithText:@"Введите код страны\nи ваш номер телефона"
                                                   font:[UIFont systemFontOfSize:20.0]
                                              textColor:[UIColor blackColor]
                                          textAlignment:NSTextAlignmentCenter];
    header.numberOfLines = 2;
    header.frame = self.view.bounds;
    header.backgroundColor = self.view.backgroundColor;
    [header sizeToFit];
    CGSize s = header.frame.size;
    header.frame = CGRectMake(0, 0, s.width, s.height+10);
    _tableView.tableHeaderView = header;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
    [_tableView reloadData];
    [_tableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(self.view.top);
        make.width.equalTo(self.view.width);
        make.height.equalTo(@(_tableView.contentSize.height));
    }];
    
    _continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_continueButton setTitle:@"Продолжить" forState:UIControlStateNormal];
    [_continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _continueButton.titleLabel.font = CKButtonFont;
    _continueButton.backgroundColor = CKClickBlueColor;
    _continueButton.clipsToBounds = YES;
    _continueButton.layer.cornerRadius = 4;
    [self.view addSubview:_continueButton];
    [_continueButton addTarget:self action:@selector(continue) forControlEvents:UIControlEventTouchUpInside];
    
    float padding = CONTROL_PADDING;
    [_continueButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.bottom.equalTo(self.view.bottom).offset(-padding);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
    }];
}

- (void)continue
{
    NSDictionary *countryData = [[CKApplicationModel sharedInstance] countryWithId:_countryId];

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
                                                              [[CKApplicationModel sharedInstance] sendUserPhone:[NSString stringWithFormat:@"%@%@", countryData[@"phonecode"], _phoneTextField.text] promo:_promoTextField.text];
                                                          }];
    [phoneWarning addAction:confirmAction];
    [phoneWarning addAction:cancelAction];
    
    [self presentViewController:phoneWarning
                       animated:YES
                     completion:nil];
}

- (void)dismissKeyboard
{
    if (_phoneTextField.isFirstResponder) [_phoneTextField resignFirstResponder];
    if (_promoTextField.isFirstResponder) [_promoTextField resignFirstResponder];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 0;
    return 54;
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
    [header sizeToFit];
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

                    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
                    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                      style:UIBarButtonItemStyleDone
                                                                                     target:self
                                                                                     action:@selector(dismissKeyboard)];
                    
                    UIBarButtonItem *barButtonCencel = [[UIBarButtonItem alloc]initWithTitle:@"Cancel"
                                                                                       style:UIBarButtonItemStyleDone
                                                                                      target:self
                                                                                      action:@selector(dismissKeyboard)];
                    [toolBar sizeToFit];
                    toolBar.items = @[barButtonCencel, barButtonDone];
                    _phoneTextField.inputAccessoryView = toolBar;
                    
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
    [textField resignFirstResponder];
    return NO;
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
    // use regex to remove non-digits(including spaces) so we are left with just the numbers
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];
    
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

@end
