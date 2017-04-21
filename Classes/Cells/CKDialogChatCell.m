//
//  CKDialogChatCell.m
//  click
//
//  Created by Igor Tetyuev on 01.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKDialogChatCell.h"

@implementation CKDialogChatCell
{
    NSTimer *_dateTimer;
}

- (instancetype)init
{
    if (self = [super initWithReuseIdentifier:@"CKDialogChatCell"])
    {
        self.backgroundColor = CKClickLightGrayColor;
    }
    return self;
}

- (void)dealloc
{
    [_dateTimer invalidate];
}

- (void)timerEvent
{
    if (!self.model) return;
    self.activity.text = [self.model.date readableMessageTimestampString];
}

- (void)setModel:(CKDialogModel *)model
{
    [super setModel:model];
    [_dateTimer invalidate];
    if (model) _dateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
    
    [self.avatar setAvatarFile:model.userAvatarId fallbackName:[self letterNameWithName:model.userName surname:model.userSurname login:model.userLogin]];
    
    if(!model.userName.length && !model.userSurname.length)
        self.title.attributedText = [NSMutableAttributedString withName:model.userLogin surname:nil size:16.0];
    else
        self.title.attributedText = [NSMutableAttributedString withName:model.userName surname:model.userSurname size:16.0];
    
    self.subtitle.text = model.message ? model.message : @"";
    self.activity.text = [model.date readableMessageTimestampString];

    if (model.messagesUnread == 0)
    {
        self.title.textColor = [UIColor blackColor];
        self.subtitle.textColor = [UIColor blackColor];
        self.activity.textColor = CKClickProfileGrayColor;
    } else
    {
        self.title.textColor = CKClickBlueColor;
        self.subtitle.textColor = CKClickBlueColor;
        self.activity.textColor = CKClickBlueColor;
    }
}


@end
