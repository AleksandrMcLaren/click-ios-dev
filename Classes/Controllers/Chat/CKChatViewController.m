//
//  KCChatViewController.m
//  click
//
//  Created by Александр on 16.03.17.
//  Copyright © 2017 Click. All rights reserved.
//

#import "CKChatViewController.h"
#import "CKApplicationModel.h"
#import "MLChatBarAvaViewController.h"
#import "MLChatBarAvaViewController+CKConfigureForChat.h"

@interface CKChatViewController ()

@property (nonatomic, strong) CKChatModel *chat;
@property (nonatomic, strong) MLChatMessage *lastMessage;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) MLChatBarAvaViewController *avaVC;

@property (nonatomic) NSInteger page;

@end

@implementation CKChatViewController

- (id)initWithChat:(CKChatModel *)chat
{
    self = [super init];
    
    if(self)
    {
        self.chat = chat;
        self.messages = [[NSMutableArray alloc] init];
        self.page = 1;
        
        [self addSubscribes];
        [self createBarAvatarView];
    }
    
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [[CKApplicationModel sharedInstance] stopChat];
}

#pragma mark -

- (void)addSubscribes
{
    __weak typeof(self.chat) _weakChat = self.chat;
    __weak typeof(self) _weakSelf = self;
    
    self.sendMessage = ^(NSString *text){
        
        if(_weakChat)
            [_weakChat send:text Video:nil Picture:nil Audio:nil];
    };
    
    self.reloadMessages = ^{
        
        if(_weakSelf)
        {
            if(_weakChat.messages.count)
                [_weakSelf loadPrevMessages];
            else
                [_weakSelf reloadData];
        }
    };
    
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
    /*
     *  Нужно поставить сообщения из базы,
     *  затем обновить с сообщения сервера
     */
    
    NSMutableArray *messages = [[self.chat getMessages] mutableCopy];
    
    if(messages.count > INSERT_MESSAGES)
    {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, messages.count - INSERT_MESSAGES)];
        [messages removeObjectsAtIndexes:indexSet];
    }
         
    if(messages.count)
    {
        [self createMessages:messages];
        [self reloadMessages:self.messages animated:NO];
    }

    [self loadMessages];
    
    // сбосим счетчики
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [CKDialogModel clearCounter:self.chat.dialog];
        [self.chat clearCounter:nil];
    });
}

- (void)loadMessages
{
    /*
     *  Загрузка последних сообщений
     */
    
    self.page = 1;
    
    __weak typeof(self) _weakSelf = self;
    [self.chat loadMessagesWithSuccess:^(NSArray *msgs) {
        
        if(_weakSelf && msgs && msgs.count)
        {
            if(_weakSelf.messages.count)
            {   // сообщения уже есть, обновим статусы и добавим те которых нет в диалоге
                NSMutableArray *missedMsgs = [[NSMutableArray alloc] init];
                
                for(NSInteger i = 0; i < msgs.count; i++)
                {
                    Message *msg = msgs[i];
                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"ident = %@", msg.id];
                    MLChatMessage *existMessage = [_weakSelf.messages filteredArrayUsingPredicate:pred].firstObject;
                    
                    if(existMessage)
                    {
                        if((NSInteger)msg.status != existMessage.status)
                        {
                            existMessage.status = (NSInteger)msg.status;
                            
                            if(existMessage.updatedStatus)
                                existMessage.updatedStatus(msg.status);
                        }
                    }
                    else
                    {
                        [missedMsgs addObject:msg];
                    }
                }
                
                if(missedMsgs.count)
                {
                    for(Message *msg in missedMsgs)
                    {
                        MLChatMessage *message = [self createFromMessage:msg];
                        [_weakSelf.messages addObject:message];
                        [_weakSelf addMessage:message];
                    }
                }
            }
            else
            {   // все сообщения новые
                [_weakSelf createMessages:msgs];
                [_weakSelf reloadMessages:_weakSelf.messages animated:YES];
            }
        }
    }];
}

- (void)loadPrevMessages
{
    /*
     *  Загрузка предыдущих сообщений постранично
     */
    
    [self.chat loadMessagesWithPage:self.page + 1
                            success:^(NSArray *messages) {
                                
                                self.page++;
                                
                                if(!messages || !messages.count)
                                {
                                    [self insertTopMessages:nil];
                                    return;
                                }
                                
                                self.lastMessage = nil;
                                
                                NSMutableArray *topMessages = [[NSMutableArray alloc] init];
                                
                                for(Message *msg in messages)
                                {
                                    MLChatMessage *message = [self createFromMessage:msg];
                                    [topMessages addObject:message];
                                }
                                
                                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, topMessages.count)];
                                [self.messages insertObjects:topMessages atIndexes:indexSet];
                                self.lastMessage = self.messages.lastObject;
                                
                                [self insertTopMessages:topMessages];
                            }];
}

#pragma mark - Message

- (void)createMessages:(NSArray *)inMessages
{
    self.lastMessage = nil;
    [self.messages removeAllObjects];
    
    for(Message *msg in inMessages)
    {
        MLChatMessage *message = [self createFromMessage:msg];
        [self.messages addObject:message];
    }
}

- (MLChatMessage *)createFromMessage:(Message *)msg
{
    MLChatMessage *message = [[MLChatMessage alloc] init];
    message.ident = msg.id;
    message.isOwner = msg.isOwner;
    message.text = msg.text;
    message.date = msg.date;
    message.status = (NSInteger)msg.status;
    message.userLogin = msg.senderName;
    
    if(msg.useravatar && msg.useravatar.length)
       message.avatarUrl = [NSString stringWithFormat:@"%@%@", CK_URL_AVATAR, msg.useravatar];

    if(!message.userLogin || !message.userLogin.length)
        message.userLogin = msg.senderLogin;
    
    if(!self.lastMessage || self.lastMessage.isOwner != message.isOwner)
    {
        message.showAvatar = NO; // аватар показываем в групповых чатах
        message.showBalloonTail = YES;
    }

    __weak typeof(self) _weakSelf = self;
    __weak typeof(message) _weakMessage = message;
    __weak typeof(msg) _weakMsg = msg;
    
    msg.updatedIdentifier = ^(){
        
        if(_weakSelf && _weakMessage && _weakMsg)
            _weakMessage.ident = _weakMsg.id;
    };
    
    msg.updatedStatus = ^(){
        
        if(_weakSelf && _weakMessage && msg)
        {
            _weakMessage.status = (int)_weakMsg.status;
            
            if(_weakMessage.updatedStatus)
                _weakMessage.updatedStatus();
        }
    };
    
    self.lastMessage = message;
    
    return message;
}

#pragma mark - Bar

- (void)createBarAvatarView
{
    self.avaVC = [[MLChatBarAvaViewController alloc] init];
    [self.avaVC configureForChat:self.chat];
    self.navigationItem.titleView = self.avaVC.view;
}

@end
