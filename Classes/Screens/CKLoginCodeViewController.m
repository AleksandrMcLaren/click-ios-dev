//
//  CKLoginCodeViewController.m
//  click
//
//  Created by Igor Tetyuev on 10.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKLoginCodeViewController.h"
#import "CKApplicationModel.h"
#import "UIColor+hex.h"
#import "UILabel+utility.h"

@implementation CKLoginCodeViewController
{
    UILabel *_topLabel1;
    UILabel *_topLabel2;
    
    UITextField *_codeEntry;
    
    UILabel *_bottomLabel;
    UIButton *_resendButton;
    UIButton *_continueButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[CKApplicationModel sharedInstance] requestAuthentication];
}

- (void)viewWillDisappear:(BOOL)animated
{
}


- (void)viewDidLoad
{
    self.title = @"Подтверждение номера";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = CKClickLightGrayColor;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_left_blue"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
//    _topLabel1 = [UILabel labelWithText:@"Подтверждение номера"
//                                        font:[UIFont boldSystemFontOfSize:20.0]
//                                   textColor:[UIColor blackColor]
//                               textAlignment:NSTextAlignmentCenter];
//    _topLabel1.numberOfLines = 1;
//    _topLabel1.backgroundColor = CKClickLightGrayColor;
//    [self.view addSubview:_topLabel1];
    
    _topLabel2 = [UILabel labelWithText:@"Введите код доступа\nиз SMS сообщения"
                                   font:[UIFont systemFontOfSize:20.0]
                              textColor:[UIColor blackColor]
                          textAlignment:NSTextAlignmentCenter];
    _topLabel2.numberOfLines = 2;
    _topLabel2.backgroundColor = CKClickLightGrayColor;
    [self.view addSubview:_topLabel2];
    
    _codeEntry = [UITextField new];
    _codeEntry.font = [UIFont systemFontOfSize:17.0];
    _codeEntry.placeholder = @"Введите код доступа";
    _codeEntry.textAlignment = NSTextAlignmentCenter;
    _codeEntry.backgroundColor = [UIColor whiteColor];
    _codeEntry.keyboardType = UIKeyboardTypeNumberPad;

    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    toolBar.items = @[barButtonDone];
    _codeEntry.inputAccessoryView = toolBar;
    [self.view addSubview:_codeEntry];

    _bottomLabel = [UILabel labelWithText:@"Код доступа выслан вам в SMS.\nВведите полученный код"
                                   font:[UIFont systemFontOfSize:20.0]
                              textColor:[UIColor blackColor]
                          textAlignment:NSTextAlignmentCenter];
    _bottomLabel.numberOfLines = 2;
    _bottomLabel.backgroundColor = CKClickLightGrayColor;
    [self.view addSubview:_bottomLabel];
    
    _resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_resendButton setTitle:@"Выслать код повторно" forState:UIControlStateNormal];
    [_resendButton setTitleColor:CKClickBlueColor forState:UIControlStateNormal];
    _resendButton.titleLabel.font = CKButtonFont;
    [self.view addSubview:_resendButton];
    [_resendButton addTarget:self action:@selector(resend) forControlEvents:UIControlEventTouchUpInside];
    
    _continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_continueButton setTitle:@"Продолжить" forState:UIControlStateNormal];
    [_continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _continueButton.titleLabel.font = CKButtonFont;
    _continueButton.backgroundColor = CKClickBlueColor;
    _continueButton.clipsToBounds = YES;
    _continueButton.layer.cornerRadius = 4;
    [self.view addSubview:_continueButton];
    [_continueButton addTarget:self action:@selector(continue) forControlEvents:UIControlEventTouchUpInside];
    

    
//    [_topLabel1 makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view.top).offset(28);
//        make.left.equalTo(self.view.left).offset(0);
//        make.right.equalTo(self.view.right).offset(0);
//    }];
    [_topLabel2 makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top).offset(16);
        make.left.equalTo(self.view.left).offset(0);
        make.right.equalTo(self.view.right).offset(0);
    }];
    [_codeEntry makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topLabel2.bottom).offset(16);
        make.height.equalTo(@44);
        make.left.equalTo(self.view.left).offset(0);
        make.right.equalTo(self.view.right).offset(0);
    }];
    [_bottomLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_codeEntry.bottom).offset(8);
        make.left.equalTo(self.view.left).offset(0);
        make.right.equalTo(self.view.right).offset(0);
    }];
    [_resendButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.top.equalTo(_bottomLabel.bottom).offset(8);
        make.left.equalTo(self.view.left).offset(15);
        make.right.equalTo(self.view.right).offset(-15);
    }];
    [_continueButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.bottom.equalTo(self.view.bottom).offset(-15);
        make.left.equalTo(self.view.left).offset(15);
        make.right.equalTo(self.view.right).offset(-15);
    }];
}

- (void)dismissKeyboard
{
    [_codeEntry resignFirstResponder];
}

- (void)continue
{
    [[CKApplicationModel sharedInstance] sendPhoneAuthenticationCode:_codeEntry.text];
}

- (void)resend
{
    [[CKApplicationModel sharedInstance] requestAuthentication];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
