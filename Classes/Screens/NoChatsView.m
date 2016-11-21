//
//  NoChatsView.m
//  click
//
//  Created by Дрягин Павел on 18.11.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "NoChatsView.h"

@interface NoChatsView(){
    UILabel *_noChatsLabel;
    UILabel *_createLabel;
    UIButton *_createChatButton;
    UIImageView *_logo;
}

@end

@implementation NoChatsView

-(instancetype)init{
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgwhite"]];
    
    _noChatsLabel = [UILabel labelWithText:@"У вас нет диалогов групп и рассылок"
                                      font:[UIFont systemFontOfSize:20.0]
                                 textColor:[UIColor blackColor]
                             textAlignment:NSTextAlignmentCenter];
    _noChatsLabel.numberOfLines = 2;
    [self addSubview:_noChatsLabel];
    
    _logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-blue"]];
    _logo.contentMode = UIViewContentModeCenter;
    
    [self addSubview:_logo];
    
    _createLabel = [UILabel labelWithText:@"Создайте диалог, группу или рассылку для участников из вашего списка Контактов" font:[UIFont systemFontOfSize: 18.0] textColor:[UIColor colorFromHexString:@"#67696b"] textAlignment:NSTextAlignmentCenter];
    _createLabel.numberOfLines = 3;
    [self addSubview:_createLabel];
    
    _createChatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_createChatButton setTitle:@"Создать" forState:UIControlStateNormal];
    [_createChatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _createChatButton.titleLabel.font = CKButtonFont;
    _createChatButton.backgroundColor = CKClickBlueColor;
    _createChatButton.clipsToBounds = YES;
    _createChatButton.layer.cornerRadius = 4;
    [_createChatButton addTarget:self action:@selector(newChat) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_createChatButton];
    
    [self makeConstraints];
    
}

- (void)makeConstraints
{
    CGFloat padding = CK_STANDART_CONTROL_PADDING;
    
    [_noChatsLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top).offset(padding*2);
        make.left.equalTo(self.left).offset(padding*2);
        make.right.equalTo(self.right).offset(-padding*2);
        
    }];
    
    [_logo makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_noChatsLabel.bottom).offset(padding);
        make.height.greaterThanOrEqualTo(160).priorityHigh();
        make.centerX.equalTo(self.centerX);
    }];
    
    [_createLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_logo.bottom).offset(10.0);
        make.bottom.lessThanOrEqualTo(_createChatButton.top).offset(-24).with.priorityLow();
        make.left.equalTo(self.left).offset(padding);
        make.right.equalTo(self.right).offset(-padding);
    }];
    
    [_createChatButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.bottom.equalTo(self.bottom).offset(-padding);
        make.left.equalTo(self.left).offset(padding);
        make.right.equalTo(self.right).offset(-padding);
    }];

}

- (void)newChat{
}

@end
