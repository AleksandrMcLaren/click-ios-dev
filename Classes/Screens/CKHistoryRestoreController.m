//
//  CKHistoryRestoreController.m
//  click
//
//  Created by Igor Tetyuev on 11.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKHistoryRestoreController.h"
#import "CKApplicationModel.h"
#import "UIColor+hex.h"
#import "UILabel+utility.h"
#import "CKMessageServerConnection.h"
#import "CKCache.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIButton+ContinueButton.h"

@implementation CKHistoryRestoreController
{
    UILabel *_clickSetupLabel;
    UILabel *_alreadyRegisteredLabel;
    UIImageView *_avatar;
    UILabel *_nameLabel;
    UILabel *_nickPhoneLabel;
    UILabel *_restoreLabel;
    UIButton *_restoreButton;
    UIButton *_abandonButton;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = CKClickLightGrayColor;
    
    _clickSetupLabel = [UILabel labelWithText:@"Настройка Click" font:[UIFont boldSystemFontOfSize:16.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_clickSetupLabel];

    _alreadyRegisteredLabel = [UILabel labelWithText:@"Вы уже зарегистрированы в Click" font:[UIFont systemFontOfSize: 15.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_alreadyRegisteredLabel];
    
    
    _avatar = [[UIImageView alloc] init];
    _avatar.image = [[Users sharedInstance] currentUser].avatar;
    
    CKUser* userProfile = [[Users sharedInstance] currentUser];
    
    if (userProfile.avatarName && (userProfile.avatarName.length > 0)) {
        [_avatar sd_setImageWithURL:[NSURL URLWithString:[[Users sharedInstance] currentUser].avatarURLString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [[CKCache sharedInstance] putImage:image withURLString:[[Users sharedInstance] currentUser].avatarURLString];
            userProfile.avatar = image;
        }];
    }else{
        UIImage* image = [UIImage imageNamed:@"ic_photo_contact"];
        [_avatar setImage:image];
    }
    
    
    //Работа через кеш
//    int _iteration = 0;
    
//    NSData *avatarData = [[CKCache sharedInstance] dataWithURLString:[NSString stringWithFormat:@"%@%@", CK_URL_AVATAR, [[CKApplicationModel sharedInstance] userProfile].avatarName]
//                                                          completion:^(NSData *result, NSDictionary *userdata) {
//                                                              if (_iteration != [userdata[@"iteration"] integerValue]) return;
//                                                              if (!result)
//                                                              {
//                                                                  _avatar.hidden = YES;
//                                                              } else
//                                                              {
//                                                                  _avatar.hidden = NO;
//                                                                  UIImage *img = [UIImage imageWithData:result];
//                                                                  _avatar.image = img;
//                                                              }
//                                                          } userData:@{@"iteration":@(_iteration)}];
//    if (avatarData)
//    {
//        _avatar.image = [UIImage imageWithData:avatarData];
//        _avatar.hidden = NO;
//    }
    _avatar.layer.cornerRadius = 60.0;
    _avatar.layer.borderColor = [[UIColor whiteColor] CGColor];
    _avatar.layer.borderWidth = 3.0;
    _avatar.clipsToBounds = YES;
    
    [self.view addSubview:_avatar];
    
    _nameLabel = [UILabel labelWithText:[[Users sharedInstance] currentUser].name font:CKButtonFont textColor:CKClickBlueColor textAlignment:NSTextAlignmentCenter];
    _nameLabel.numberOfLines = 5;
    [self.view addSubview:_nameLabel];
    
    _nickPhoneLabel = [UILabel labelWithText:nil font:[UIFont systemFontOfSize: 12.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentCenter];
    _nickPhoneLabel.numberOfLines = 5;
    NSMutableAttributedString *nickPhoneString = [NSMutableAttributedString new];
    [nickPhoneString appendAttributedString:[NSMutableAttributedString withImageName:@"person" geometry:CGRectMake(0, -2, 12, 12)]];
    [nickPhoneString appendAttributedString:[NSMutableAttributedString withString:[NSString stringWithFormat:@" %@ | ", [[Users sharedInstance] currentUser].login]]];
    [nickPhoneString appendAttributedString:[NSMutableAttributedString withImageName:@"phone" geometry:CGRectMake(0, -2, 12, 12)]];
    [nickPhoneString appendAttributedString:[NSMutableAttributedString withString:[NSString stringWithFormat:@" +%@", [[Users sharedInstance] currentUser].id ? [[Users sharedInstance] currentUser].id : @""]]];
    
    _nickPhoneLabel.attributedText = nickPhoneString;
    [self.view addSubview:_nickPhoneLabel];
    
    _restoreLabel = [UILabel labelWithText:@"Восстановить историю переписки и чатов?" font:[UIFont systemFontOfSize: 14.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentCenter];
    _restoreLabel.numberOfLines = 2;
    
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.5;
    [_restoreLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    
    [self.view addSubview:_restoreLabel];
    
    _restoreButton = [[UIButton alloc] initContinueButton];
    [_restoreButton setTitle:@"Восстановить" forState:UIControlStateNormal];
    [self.view addSubview:_restoreButton];
    [_restoreButton addTarget:self action:@selector(restore) forControlEvents:UIControlEventTouchUpInside];
    
    
    _abandonButton = [[UIButton alloc] initContinueButton];
    _abandonButton.tag = 0;
    [_abandonButton setTitle:@"Не восстанавливать" forState:UIControlStateNormal];
    [self.view addSubview:_abandonButton];
    [_abandonButton.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    [_abandonButton addTarget:self action:@selector(restoreProfile:) forControlEvents:UIControlEventTouchUpInside];
    
    float padding = CK_STANDART_CONTROL_PADDING;
    
    [_clickSetupLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top).offset(25);
        make.left.equalTo(self.view.left).offset(15);
        make.right.equalTo(self.view.right).offset(-15);
    }];
    
    [_alreadyRegisteredLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(_clickSetupLabel.bottom).offset(10);
        make.top.lessThanOrEqualTo(_clickSetupLabel.bottom).offset(25);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
    }];
    
    [_avatar makeConstraints:^(MASConstraintMaker *make) {
        make.top.lessThanOrEqualTo(_alreadyRegisteredLabel.bottom).offset(25);
        make.centerX.equalTo(self.view.centerX);
        make.width.equalTo(120.0);
        make.height.equalTo(120.0);
    }];
    
    [_nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.lessThanOrEqualTo(_avatar.bottom).offset(25);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
    }];
    
    [_nickPhoneLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.lessThanOrEqualTo(_nameLabel.bottom).offset(25);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
    }];
    
    [_restoreLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(_nickPhoneLabel.bottom).offset(padding/2);
        make.bottom.greaterThanOrEqualTo(_restoreButton.top).offset(-25);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
    }];
    
    [_restoreButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.bottom.equalTo(_abandonButton.top).offset(-padding/2);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
    }];
    
    [_abandonButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.bottom.equalTo(self.view.bottom).offset(-padding);
        make.left.equalTo(self.view.left).offset(padding);
        make.right.equalTo(self.view.right).offset(-padding);
    }];
    
    [self.activityIndicatorView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_restoreLabel.centerX);
        make.bottom.equalTo(_restoreLabel.top).offset(-padding);
    }];
}

- (void)restore
{
    _abandonButton.enabled = NO;
    _restoreButton.enabled = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _restoreButton.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         _restoreButton.hidden = YES;
                     }];

    [_abandonButton setTitle:@"Продолжить" forState:UIControlStateNormal];

    
    [self beginOperation:@"restoreHistory"];
    [[CKApplicationModel sharedInstance] restoreHistoryWithCallback:^(NSDictionary *result) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _abandonButton.enabled = YES;
            _restoreButton.enabled = YES;
            _abandonButton.tag = 1;
            
            [self endOperation:@"restoreHistory"];
            [[CKDialogsModel sharedInstance] saveDialogsWithDictionary:result];
            NSArray *dialogs = [[CKDialogsModel sharedInstance] dialogs];
            
            NSString* text;
            if (dialogs.count) {
                text = [NSString stringWithFormat:@"Поздаравляем!\nУспешно %@ %d %@",
                        [NSString terminationForValue:(int)dialogs.count withWords: @[@"восстановлено", @"восстановлено", @"восстановлен"]],
                        (int)dialogs.count,
                        [NSString terminationForValue:(int)dialogs.count withWords: @[@"чатов", @"чата", @"чат"]]];
            }else{
                text = @"Нет доступных для восстановления чатов";
            }
            _restoreLabel.text =  text;
            
            [_abandonButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
            _abandonButton.backgroundColor = CKClickBlueColor;
        });
    }];
}

- (void)restoreProfile:(UIButton*)sender
{
    [[CKApplicationModel sharedInstance] restoreProfile:(sender.tag != 0)];
}


@end
