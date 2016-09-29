//
//  CKChatController.m
//  click
//
//  Created by Igor Tetyuev on 07.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKChatController.h"

@implementation CKChatController


- (void)setChat:(CKChatModel *)chat
{
    if (_chat)
    {
        [_chat removeObserver:self forKeyPath:@"messages"];
    }
    _chat = chat;
    [self.chat addObserver:self forKeyPath:@"messages" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)dealloc
{
    [self.chat removeObserver:self forKeyPath:@"messages"];
}

- (void)viewDidLoad
{
    self.messagesList = [CKMessagesListController new];
    [self.view addSubview:self.messagesList.view];
    [self addChildViewController:self.messagesList];
    [self.messagesList.view makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(0);
        make.top.equalTo(0);
        make.width.equalTo(self.view.width);
        make.height.equalTo(self.view.height);
    }];
    if (self.messagesList) self.messagesList.messages = self.chat.messages;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) return;
    NSLog(@"%@", change);
    if ([keyPath isEqualToString:@"messages"]) self.messagesList.messages = self.chat.messages;
}

@end
