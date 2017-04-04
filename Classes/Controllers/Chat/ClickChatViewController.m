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
#import "MLChatLib.h"

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
        
        [self createBarAvatarView];
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
            {   // нужно обновлять список сообщений для переотправленных
                // проверка, что пришли не те же сообщения что и в БД
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

- (void)createBarAvatarView
{
    NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", CK_URL_AVATAR, self.chat.dialog.userAvatarId];
    NSString *name = ((self.chat.dialog.userName && self.chat.dialog.userName.length) ? self.chat.dialog.userName : self.chat.dialog.userLogin);
    NSString *date = nil;
    NSString *onlineText = @"В сети";
    
    CKUser *user = [[Users sharedInstance] userWithId:self.chat.dialog.userId];

    if(user && user.statusDate)
    {
        date = [NSString stringWithFormat:@"%@ в %@", [[MLChatLib formatterDate_yyyy_MM_dd] stringFromDate:user.statusDate], [[MLChatLib formatterDate_HH_mm] stringFromDate:user.statusDate]];
    }

    CGSize nameSize = [name boundingRectWithSize:CGSizeMake(180, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}
                                               context:nil].size;
    CGFloat allWidth = 40 + 7 + nameSize.width;
    
    // не в сети
    CGFloat minWidth = 135.f;
    
    if(user.status == 1)
    {   // в сети
        CGSize textSize = [onlineText boundingRectWithSize:CGSizeMake(180, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}
                                                   context:nil].size;
        minWidth = 40 + 7 + textSize.width;
    }
    
    if(allWidth < minWidth)
        allWidth = minWidth;
    
    self.avaVC = [[MLChatBarAvaViewController alloc] init];
    self.avaVC.view.frame = CGRectMake(0, 0, allWidth, 40);
    self.avaVC.avatarUrl = avatarUrl;
    self.avaVC.titleText = name;
    
    if(user.status == 1)
    {
        self.avaVC.online = YES;
        self.avaVC.subtitleText = onlineText;
    }
    else
    {
        self.avaVC.online = NO;
        self.avaVC.subtitleText = date;
    }

    self.navigationItem.titleView = self.avaVC.view;
}

@end
