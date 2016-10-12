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
    UILabel *_timerLabel;
    UIButton *_resendButton;
    UIButton *_continueButton;
    
    CGFloat _keyboardHeight;
    
    int _secondsLeft;
    NSTimer* _timer;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
        tapRecognizer.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:tapRecognizer];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self requestAuthenticationCode];
}

- (void)viewWillDisappear:(BOOL)animated
{
}


- (void)viewDidLoad
{
    _secondsLeft = 10;
    
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
    _codeEntry.clearButtonMode = UITextFieldViewModeAlways;

//    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
//    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
//                                                                      style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
//    toolBar.items = @[barButtonDone];
//    _codeEntry.inputAccessoryView = toolBar;
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
    [_resendButton setTitleColor:CKClickProfileGrayColor forState:UIControlStateDisabled];
    
    _resendButton.titleLabel.font = CKButtonFont;
    
    _timerLabel = [UILabel labelWithText:@"60"
                                     font:[UIFont systemFontOfSize:12]
                                textColor:CKClickProfileGrayColor
                            textAlignment:NSTextAlignmentCenter];
    _timerLabel.numberOfLines = 1;
    _timerLabel.backgroundColor = CKClickLightGrayColor;
    _timerLabel.hidden = YES;
    [self.view addSubview:_timerLabel];

    
    [self.view addSubview:_resendButton];
    [_resendButton addTarget:self action:@selector(requestAuthenticationCode) forControlEvents:UIControlEventTouchUpInside];
    
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

    [_topLabel2 makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top).offset(padding);
        make.left.equalTo(self.view.left).offset(0);
        make.right.equalTo(self.view.right).offset(0);
    }];
    [_codeEntry makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topLabel2.bottom).offset(padding);
        make.height.equalTo(@44);
        make.left.equalTo(self.view.left).offset(0);
        make.right.equalTo(self.view.right).offset(0);
    }];
    [_bottomLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_codeEntry.bottom).offset(padding*.5);
        make.left.equalTo(self.view.left).offset(0);
        make.right.equalTo(self.view.right).offset(0);
    }];
    [_resendButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.top.equalTo(_bottomLabel.bottom).offset(padding*.5);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
    }];
    [_timerLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_resendButton.bottom).offset(0);
        make.centerX.equalTo(self.view);
    }];
    [_continueButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.bottom.equalTo(self.view.bottom).offset(-padding);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
    }];
}

- (void)continue
{
    [[CKApplicationModel sharedInstance] sendPhoneAuthenticationCode:_codeEntry.text];
}

- (void)requestAuthenticationCode
{
    [self startBlockResentButton];
    [[CKApplicationModel sharedInstance] requestAuthentication];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Keyboard events

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

- (void)dismissKeyboard
{
    if (_codeEntry.isFirstResponder) [_codeEntry resignFirstResponder];
}

- (void)updateFrames{
    float padding = CONTROL_PADDING;
    [_continueButton updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom).offset(-padding-_keyboardHeight);
    }];
}

- (void) viewTapped {
    [self dismissKeyboard];
}

#pragma mark NSTimer

-(void)startBlockResentButton{
    _resendButton.enabled = NO;
    _timerLabel.hidden = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                target:self
                                            selector:@selector(timerTick:)
                                            userInfo:nil
                                             repeats:YES];
    
}

- (void)timerTick:(NSTimer *)timer
{
    _secondsLeft--;

    [self updateTimerLabel];
    
    if (_secondsLeft == 0) {
        [_timer invalidate];
        _timer = nil;
        _secondsLeft = 60;
        _resendButton.enabled = YES;
        _timerLabel.hidden = YES;
        [self updateTimerLabel];
    }
}

-(void)updateTimerLabel{
    int hours, minutes, seconds;
    
    hours = _secondsLeft / 3600;
    minutes = (_secondsLeft % 3600) / 60;
    seconds = (_secondsLeft %3600) % 60;
    NSString* text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    _timerLabel.text = text;
    
}


@end
