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
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = CKClickLightGrayColor;
    
    _clickSetupLabel = [UILabel labelWithText:@"Настройка Click" font:[UIFont boldSystemFontOfSize:16.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_clickSetupLabel];

    _alreadyRegisteredLabel = [UILabel labelWithText:@"Вы уже зарегистрированы в Click" font:[UIFont systemFontOfSize: 15.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_alreadyRegisteredLabel];
    
    _avatar = [[UIImageView alloc] init];
    _avatar.image = [[CKApplicationModel sharedInstance] userProfile].avatar;
    
    _avatar.layer.cornerRadius = 60.0;
    _avatar.layer.borderColor = [[UIColor whiteColor] CGColor];
    _avatar.layer.borderWidth = 3.0;
    _avatar.clipsToBounds = YES;
    
    [self.view addSubview:_avatar];
    
    _nameLabel = [UILabel labelWithText:[[CKApplicationModel sharedInstance] userProfile].name font:CKButtonFont textColor:CKClickBlueColor textAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_nameLabel];
    
    _nickPhoneLabel = [UILabel labelWithText:nil font:[UIFont systemFontOfSize: 12.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentCenter];
    
    NSMutableAttributedString *nickPhoneString = [NSMutableAttributedString new];
    [nickPhoneString appendAttributedString:[NSMutableAttributedString withImageName:@"person" geometry:CGRectMake(0, -2, 12, 12)]];
    [nickPhoneString appendAttributedString:[NSMutableAttributedString withString:[NSString stringWithFormat:@" %@ | ", [[CKApplicationModel sharedInstance] userProfile].login]]];
    [nickPhoneString appendAttributedString:[NSMutableAttributedString withImageName:@"phone" geometry:CGRectMake(0, -2, 12, 12)]];
    [nickPhoneString appendAttributedString:[NSMutableAttributedString withString:[NSString stringWithFormat:@" +%@", [[CKApplicationModel sharedInstance] userProfile].id]]];
    
    _nickPhoneLabel.attributedText = nickPhoneString;
    [self.view addSubview:_nickPhoneLabel];
    
    _restoreLabel = [UILabel labelWithText:@"Восстановить историю переписки и чатов?" font:[UIFont systemFontOfSize: 14.0] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentCenter];
    _restoreLabel.numberOfLines = 2;
    [self.view addSubview:_restoreLabel];
    
    _restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_restoreButton setTitle:@"Восстановить" forState:UIControlStateNormal];
    [_restoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _restoreButton.titleLabel.font = CKButtonFont;
    _restoreButton.backgroundColor = CKClickBlueColor;
    _restoreButton.clipsToBounds = YES;
    _restoreButton.layer.cornerRadius = 4;
    [self.view addSubview:_restoreButton];
    [_restoreButton addTarget:self action:@selector(restore) forControlEvents:UIControlEventTouchUpInside];
    
    _abandonButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_abandonButton setTitle:@"Не восстанавливать" forState:UIControlStateNormal];
    [_abandonButton setTitleColor:CKClickBlueColor forState:UIControlStateNormal];
    _abandonButton.titleLabel.font = CKButtonFont;
    _abandonButton.backgroundColor = [UIColor whiteColor];
    _abandonButton.layer.borderColor = [CKClickBlueColor CGColor];
    _abandonButton.layer.borderWidth = 2.0;
    _abandonButton.clipsToBounds = YES;
    _abandonButton.layer.cornerRadius = 4;
    [self.view addSubview:_abandonButton];
    [_abandonButton addTarget:self action:@selector(abandon) forControlEvents:UIControlEventTouchUpInside];
    
    [_clickSetupLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top).offset(25);
        make.left.equalTo(self.view.left).offset(15);
        make.right.equalTo(self.view.right).offset(-15);
    }];
    
    [_alreadyRegisteredLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(_clickSetupLabel.bottom).offset(10);
        make.top.lessThanOrEqualTo(_clickSetupLabel.bottom).offset(25);
        make.left.equalTo(self.view.left).offset(15);
        make.right.equalTo(self.view.right).offset(-15);
    }];
    
    [_avatar makeConstraints:^(MASConstraintMaker *make) {
        make.top.lessThanOrEqualTo(_alreadyRegisteredLabel.bottom).offset(25);
        make.centerX.equalTo(self.view.centerX);
        make.width.equalTo(120.0);
        make.height.equalTo(120.0);
    }];
    
    [_nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.lessThanOrEqualTo(_avatar.bottom).offset(25);
        make.left.equalTo(self.view.left).offset(15);
        make.right.equalTo(self.view.right).offset(-15);
    }];
    
    [_nickPhoneLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.lessThanOrEqualTo(_nameLabel.bottom).offset(25);
        make.left.equalTo(self.view.left).offset(15);
        make.right.equalTo(self.view.right).offset(-15);
    }];
    
    [_restoreLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(_nickPhoneLabel.bottom).offset(10.0);
        make.bottom.greaterThanOrEqualTo(_restoreButton.top).offset(-25);
        make.left.equalTo(self.view.left).offset(15);
        make.right.equalTo(self.view.right).offset(-15);
    }];
    
    [_restoreButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.bottom.equalTo(_abandonButton.top).offset(-10);
        make.left.equalTo(self.view.left).offset(15);
        make.right.equalTo(self.view.right).offset(-15);
    }];
    
    [_abandonButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.bottom.equalTo(self.view.bottom).offset(-15);
        make.left.equalTo(self.view.left).offset(15);
        make.right.equalTo(self.view.right).offset(-15);
    }];
}

- (void)restore
{
    [[CKMessageServerConnection sharedInstance] getDialogListWithCallback:^(NSDictionary *result) {
        NSMutableArray *dialogs = [NSMutableArray new];
        for (NSDictionary *dictionary in result[@"result"])
        {
            CKDialogListEntryModel *model = [CKDialogListEntryModel modelWithDictionary:dictionary];
            [dialogs addObject:model];
        }
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
        _restoreButton.hidden = YES;
        [_abandonButton setTitle:@"Продолжить" forState:UIControlStateNormal];
        [_abandonButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
        _abandonButton.backgroundColor = CKClickBlueColor;
        
    }];
    
//    [[CKApplicationModel sharedInstance] restoreHistory];
}

- (void)abandon
{
    [[CKApplicationModel sharedInstance] abandonHistory];
}

@end
