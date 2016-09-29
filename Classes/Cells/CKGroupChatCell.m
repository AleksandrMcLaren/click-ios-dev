//
//  CKGroupChatCell.m
//  click
//
//  Created by Igor Tetyuev on 01.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKGroupChatCell.h"

@implementation CKGroupChatCell
{
    NSTimer *_dateTimer;
}

- (instancetype)init
{
    if (self = [super initWithReuseIdentifier:@"CKGroupChatCell"])
    {
        self.backgroundColor = [UIColor whiteColor];
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

- (void)setModel:(CKDialogListEntryModel *)model
{
    [super setModel:model];
    [_dateTimer invalidate];
    if (model) _dateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
    self.title.attributedText = [NSMutableAttributedString withString:model.dialogName];
    self.subtitle.text = model.message;
    self.activity.text = [model.date readableMessageTimestampString];
    if (model.messagesUnread == 0)
    {
        self.title.textColor = [UIColor blackColor];
        self.subtitle.textColor = CKClickProfileGrayColor;
        self.activity.textColor = CKClickProfileGrayColor;
    } else
    {
        self.title.textColor = CKClickBlueColor;
        self.subtitle.textColor = CKClickBlueColor;
        self.activity.textColor = CKClickBlueColor;
    }
}


@end
