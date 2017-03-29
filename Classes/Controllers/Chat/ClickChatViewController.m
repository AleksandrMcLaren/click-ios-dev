//
//  ClickChatViewController.m
//  click
//
//  Created by Александр on 16.03.17.
//  Copyright © 2017 Click. All rights reserved.
//

#import "ClickChatViewController.h"
#import "CKApplicationModel.h"
#import "MLChatBarAvaViewController.h"

@interface ClickChatViewController ()

@property (nonatomic, strong) CKChatModel *chat;
@property (nonatomic, strong) MLChatMessage *lastMessage;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) MLChatBarAvaViewController *avaVC;

@end

@implementation ClickChatViewController

- (id)initWithChat:(CKChatModel *)chat
{
    self = [super init];
    
    if(self)
    {
        self.chat = chat;
        self.messages = [[NSMutableArray alloc] init];

        __weak typeof(self.chat) _weakChat = self.chat;
        self.sendMessage = ^(NSString *text){
            
            if(_weakChat)
                [_weakChat send:text Video:nil Picture:nil Audio:nil];
        };
        
//        __weak typeof(self) _weakSelf = self;
//        self.reloadMessages = ^{
//           
//           // if(_weakSelf)
//           //     [_weakChat loadMessages];
//        };
        
        [self createNavigationAvatarView];
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
        [self createMessages:messages];
        [self reloadMessages:self.messages animated:NO];
    }
    else
    {
        [self beginRefreshing];
    }

    [self loadMessages];
}

- (void)loadMessages
{
    __weak typeof(self) _weakSelf = self;
    [self.chat loadMessagesWithSuccess:^(NSArray *msgs) {
        
        if(_weakSelf)
        {
            [_weakSelf endRefreshing];
            
            if(_weakSelf.messages.count)
            {   // нужно обновлять список сообщений
                // проверка, что пришли не те же сообщения
                BOOL changedMessage = NO;
                
                for(NSInteger i = 0; i < _weakSelf.messages.count; i++)
                {
                    MLChatMessage *message = _weakSelf.messages[i];
                    Message *msg = msgs[i];
                    
                    if(![message.ident isEqualToString:msg.id] ||
                       message.status != (int)msg.status)
                    {
                        changedMessage = YES;
                        break;
                    }
                }
                
                if(!changedMessage)
                    return;
            }

            BOOL animated = !_weakSelf.messages.count;
            
            [_weakSelf createMessages:msgs];
            [_weakSelf reloadMessages:_weakSelf.messages animated:animated];
        }
    }];
}
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

- (void)createNavigationAvatarView
{
    NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", CK_URL_AVATAR, self.chat.dialog.userAvatarId];
    NSString *name = ((self.chat.dialog.userName && self.chat.dialog.userName.length) ? self.chat.dialog.userName : self.chat.dialog.userLogin);
    
    CGSize textSize = [name boundingRectWithSize:CGSizeMake(190, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}
                                               context:nil].size;
    
    self.avaVC = [[MLChatBarAvaViewController alloc] initWithAvatarUrl:avatarUrl name:name];
    self.avaVC.view.frame = CGRectMake(0, 0, 40 + 5 + textSize.width, 40);
    self.navigationItem.titleView = self.avaVC.view;
}

@end
