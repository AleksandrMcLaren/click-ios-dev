//
//  ClickChatViewController.m
//  click
//
//  Created by Александр on 16.03.17.
//  Copyright © 2017 Click. All rights reserved.
//

#import "ClickChatViewController.h"
#import "CKApplicationModel.h"

@interface ClickChatViewController ()

@property (nonatomic, strong) CKChatModel *chat;
@property (nonatomic, strong) MLChatMessage *lastMessage;
@property (nonatomic, strong) NSMutableArray *messages;

@end

@implementation ClickChatViewController

- (id)initWithChat:(CKChatModel *)chat
{
    self = [super init];
    
    if(self)
    {
        self.chat = chat;
        self.title = self.chat.dialog.userName;
        self.messages = [[NSMutableArray alloc] init];

        __weak typeof(self.chat) _weakChat = self.chat;
        self.sendMessage = ^(NSString *text){
            
            if(_weakChat)
                [_weakChat send:text Video:nil Picture:nil Audio:nil];
        };
        
        __weak typeof(self) _weakSelf = self;
        self.reloadMessages = ^{
           
            if(_weakSelf)
                [_weakChat loadMessages];
        };
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addBackendSubscribes];
    [self reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [[CKApplicationModel sharedInstance] stopChat];
}

#pragma mark -

- (void)addBackendSubscribes
{
    __weak typeof(self) _weakSelf = self;
    [self.chat.messagesDidChanged subscribeNext:^(NSArray *msgs) {
        
        if(_weakSelf)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_weakSelf endRefreshing];
            });
            
            BOOL animated = !self.messages.count;
            
            [_weakSelf.messages removeAllObjects];
            
            for(Message *msg in msgs)
            {
                MLChatMessage *message = [self createFromMessage:msg];
                [_weakSelf.messages addObject:message];
            }
            
            [_weakSelf reloadMessages:self.messages animated:animated];
        }
    }];
    
    [self.chat.messageDidChanged subscribeNext:^(Message *msg) {
        
        if(_weakSelf)
        {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"ident = %@", msg.id];
            MLChatMessage *existMessage = [_weakSelf.messages filteredArrayUsingPredicate:pred].firstObject;
            
            if(!existMessage)
            {
                MLChatMessage *message = [_weakSelf createFromMessage:msg];
                [_weakSelf.messages addObject:message];
                
                [_weakSelf addMessage:message];
            }
        }
    }];

}

- (void)reloadData
{
    NSArray *messages = [self.chat getMessages];
    
    if(messages.count)
    {
        for(Message *msg in messages)
        {
            MLChatMessage *message = [self createFromMessage:msg];
            [self.messages addObject:message];
        }
        
        [self reloadMessages:self.messages animated:NO];
    }
    else
    {
        [self beginRefreshing];
        [self.chat loadMessages];
    }
}

#pragma mark - Message

- (MLChatMessage *)createFromMessage:(Message *)msg
{
    MLChatMessage *message = [[MLChatMessage alloc] init];
    message.ident = msg.id;
    message.isOwner = msg.isOwner;
    message.text = msg.text;
    message.date = msg.date;
    message.status = (NSInteger)msg.status;
    message.userLogin = msg.senderName;
    message.avatarUrl = msg.avatar;
    
    if(!message.userLogin || !message.userLogin.length)
        message.userLogin = msg.senderLogin;
    
    if(!self.lastMessage || self.lastMessage.isOwner != message.isOwner)
        message.isFirst = YES;
    
    __weak typeof(message) _weakMessage = message;
    __weak typeof(msg) _weakMsg = msg;
    msg.updatedIdentifier = ^(){
        
        if(_weakMessage && _weakMsg)
            _weakMessage.ident = _weakMsg.id;
    };
    
    __weak typeof(self) _weakSelf = self;
    msg.updatedStatus = ^(){
        
        if(_weakMessage && msg && _weakSelf)
        {
            _weakMessage.status = (int)_weakMsg.status;
            
            if(_weakMessage.updatedStatus)
                _weakMessage.updatedStatus();
        }
    };
    
    self.lastMessage = message;
    
    return message;
}

@end
