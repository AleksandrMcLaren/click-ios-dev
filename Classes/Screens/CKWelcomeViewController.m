//
//  CKWelcomeViewController.m
//  click
//
//  Created by Igor Tetyuev on 09.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKWelcomeViewController.h"
#import "UIColor+hex.h"
#import "CKApplicationModel.h"
#import "UILabel+utility.h"

@interface CKWelcomeViewController ()

@end

@implementation CKWelcomeViewController
{
    UILabel *_welcomeText;
    UIImageView *_logo;
    UILabel *_aboutText;
    UIImageView *_logoIOS;
    UIImageView *_logoDroid;
    UIImageView *_logoWin;
    UIButton *_termsButton;
    UIButton *_acceptButton;
    
    UIWebView *_termsView;
    CGFloat _padding;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = CKClickBlueColor;
    _padding = 15.0;

    _welcomeText = [UILabel labelWithText:@"Добро пожаловать\nв MessMe"
                                     font:[UIFont systemFontOfSize:16.0]
                                textColor:[UIColor whiteColor]
                            textAlignment:NSTextAlignmentCenter];
    _welcomeText.numberOfLines = 2;
    
    
    [self.view addSubview:_welcomeText];
    
    _logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    [self.view addSubview:_logo];
    
    _aboutText = [UILabel labelWithText:@"Кросс-платформенная мобильная\nсистема обмена сообщениями\nс друзьями по всему миру"
                                   font:[UIFont systemFontOfSize:14.0]
                              textColor:[UIColor whiteColor]
                          textAlignment:NSTextAlignmentCenter];
    _aboutText.numberOfLines = 3;

    [self.view addSubview:_aboutText];
    
    _logoIOS = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_ios"]];
    [self.view addSubview:_logoIOS];
    _logoDroid = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_android"]];
    [self.view addSubview:_logoDroid];
    _logoWin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_windows"]];
    [self.view addSubview:_logoWin];
    
    _termsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_termsButton setTitle:@"Условия предоставления услуг" forState:UIControlStateNormal];
    [_termsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _termsButton.titleLabel.font = CKButtonFont;
    [self.view addSubview:_termsButton];
    [_termsButton addTarget:self action:@selector(showTerms) forControlEvents:UIControlEventTouchUpInside];
    
    _acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_acceptButton setTitle:@"Принять и продолжить" forState:UIControlStateNormal];
    [_acceptButton setTitleColor:self.view.backgroundColor forState:UIControlStateNormal];
    _acceptButton.titleLabel.font = CKButtonFont;
    _acceptButton.backgroundColor = [UIColor whiteColor];
    _acceptButton.clipsToBounds = YES;
    _acceptButton.layer.cornerRadius = 4;
    [self.view addSubview:_acceptButton];
    [_acceptButton addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
    
    _welcomeText.alpha = 0.0;
    _aboutText.alpha = 0.0;
    _logoWin.alpha = 0.0;
    _logoIOS.alpha = 0.0;
    _logoDroid.alpha = 0.0;
    _acceptButton.alpha = 0.0;
    _termsButton.alpha = 0.0;
    
    [_logo makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@136);
        make.height.equalTo(@136);
        make.centerX.equalTo(@0);
        make.centerY.equalTo(@0);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    CGFloat padding = _padding;

    [_welcomeText makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self.view.top).greaterThanOrEqualTo(padding*2);
        make.left.equalTo(self.view.left).offset(padding*2);
        make.right.equalTo(self.view.right).offset(-padding*2);
        
    }];
    
    [_logo remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@136);
        make.height.equalTo(@136);
        make.centerX.equalTo(@0);
        make.top.equalTo(_welcomeText.bottom).offset(padding);
    }];
    
    [_aboutText makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_logo.bottom).offset(padding);
        make.left.equalTo(self.view.left).offset(padding*2);
        make.right.equalTo(self.view.right).offset(-padding*2);
        
    }];
    
    [_logoDroid makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_aboutText.bottom).offset(padding/2);
        make.centerX.equalTo(@0);
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];

    [_logoIOS makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_logoDroid.top);
        make.right.equalTo(_logoDroid.left).offset(-padding);
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];
    [_logoWin makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_logoDroid.top);
        make.left.equalTo(_logoDroid.right).offset(padding);
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];
    
    [_acceptButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.bottom.equalTo(self.view.bottom).offset(-padding);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
    }];
    
    [_termsButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_acceptButton.top).offset(-padding);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
    }];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];

    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.4 animations:^{
            _welcomeText.alpha = 1.0;
            _aboutText.alpha = 1.0;
            _logoWin.alpha = 1.0;
            _logoIOS.alpha = 1.0;
            _logoDroid.alpha = 1.0;
            _acceptButton.alpha = 1.0;
            _termsButton.alpha = 1.0;
        }];
        
    }];
    
    
}

- (void) showTerms
{
    CGFloat padding = _padding;

    _termsView = [[UIWebView alloc] init];
    _termsView.backgroundColor = [UIColor whiteColor];
    _termsView.layer.borderColor = [[UIColor whiteColor] CGColor];
    _termsView.layer.cornerRadius = 4.0;
    _termsView.layer.borderWidth = 2.0;
    _termsView.clipsToBounds = YES;
    [self.view addSubview:_termsView];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"terms" withExtension:@"html"];
    NSString *html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [_termsView loadHTMLString:html baseURL:baseUrl];
    [_termsView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top).offset(24);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
        make.bottom.equalTo(_acceptButton.top).offset(-padding);
    }];
}

- (void) accept
{
    [[CKApplicationModel sharedInstance] userDidAcceptTerms];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
