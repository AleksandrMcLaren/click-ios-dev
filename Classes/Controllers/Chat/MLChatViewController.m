//
//  MLChatViewController.m
//  click
//
//  Created by Aleksandr on 02/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatViewController.h"
#import "MLChatMessageListViewController.h"
#import "MLChatMessageBarViewController.h"


@interface MLChatViewController () <MLChatMessageBarViewControllerDelegate>

@property (nonatomic, strong) CKChatModel *chat;
@property (nonatomic, strong) MLChatMessageListViewController *messageVC;
@property (nonatomic, strong) MLChatMessageBarViewController *messageBarVC;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) MLChatMessage *lastMessage;
@property (nonatomic, strong) UILabel *chatNameLabel;

@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) CGFloat messageBarHeight;

@end


@implementation MLChatViewController

- (id)initWithChat:(CKChatModel *)chat
{
    self = [super init];
    
    if(self)
    {
        self.chat = chat;
        
        self.title = self.chat.dialog.userName;
        
        self.messages = [[NSMutableArray alloc] init];
        
        self.messageVC = [[MLChatMessageListViewController alloc] init];
        
        self.messageBarHeight = 51.f;
        self.messageBarVC = [[MLChatMessageBarViewController alloc] init];
        self.messageBarVC.delegate = self;
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        
//        self.chatNameLabel = [[UILabel alloc] init];
//        self.chatNameLabel.textColor = [UIColor blackColor];
//        self.chatNameLabel.text = self.chat.dialog.userName;
//        self.chatNameLabel.font = [UIFont systemFontOfSize:16];
//        [self.chatNameLabel sizeToFit];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resendMessage:)
                                                 name:mlchat_message_needs_resend
                                               object:nil];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgwhite"]];

    [self.view addSubview:self.messageVC.view];
    [self.view addSubview:self.messageBarVC.view];
    [self.view addGestureRecognizer:self.tapRecognizer];
   // [self.navigationController.view addSubview:self.chatNameLabel];

    [self.chat.messagesDidChanged subscribeNext:^(NSArray *msgs) {

        if(self.messages.count)
            return;

        for(Message *msg in msgs)
        {
            MLChatMessage *message = [self createFromMessage:msg];
            [self.messages addObject:message];
        }

        [self.messageVC addMessages:self.messages];
    }];
    
    [self.chat.lastMessageDidChanged subscribeNext:^(Message *msg) {
        
        MLChatMessage *message = [self createFromMessage:msg];
        [self.messages addObject:message];
        
        [self.messageVC addMessage:message];
    }];
    
    [self.view setNeedsUpdateConstraints];
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
    
    /*
    if(message.isOwner)
        ;
    else
        message.avatarUrl = self.chat.dialog.userAvatarId;
    */
    
    NSLog(@"qqq %@", message.userLogin);
    
    
    if(!self.lastMessage || self.lastMessage.isOwner != message.isOwner)
        message.isFirst = YES;
    
    self.lastMessage = message;
    
    return message;
}

- (void)updateViewConstraints
{
//    CGSize boundsSize = self.navigationController.view.bounds.size;
//
//    [self.chatNameLabel updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo((boundsSize.width - self.chatNameLabel.frame.size.width) / 2);
//        make.top.equalTo((boundsSize.height - self.chatNameLabel.frame.size.height) / 2);
////        make.bottom.equalTo(self.view.bottom).offset(-messageBarBottomOffset);
////        make.height.equalTo(self.messageBarHeight);
//    }];
    
    CGFloat messageBarBottomOffset = self.keyboardHeight;
    
    [self.messageBarVC.view updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.bottom.equalTo(self.view.bottom).offset(-messageBarBottomOffset);
        make.height.equalTo(self.messageBarHeight);
    }];
    
    [self.messageVC.view updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.top.equalTo(self.view.top);
        make.bottom.equalTo(self.messageBarVC.view.top);
    }];
    
    [super updateViewConstraints];
}

- (void)messageSend:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio
{
    [self.chat send:text Video:video Picture:picture Audio:audio];
}

#pragma mark - NSNotification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize boundsSize = self.view.bounds.size;
    
    self.keyboardHeight = boundsSize.height - kbRect.origin.y;
    
    CGRect messageBarFrame = self.messageBarVC.view.frame;
    messageBarFrame.origin.y = boundsSize.height - self.keyboardHeight - messageBarFrame.size.height;
    
    CGRect messageListFrame = self.messageVC.view.frame;
    messageListFrame.size.height = boundsSize.height - (boundsSize.height - messageBarFrame.origin.y);
    
    CGFloat messageListOffset = 0;
    
    if(boundsSize.height != kbRect.origin.y)
    {  // открывается
        CGFloat diff = self.messageVC.view.frame.size.height - messageListFrame.size.height;
        messageListOffset = self.messageVC.contentOffSet + diff;
    }
    else
    {   // закрывается
        CGFloat diff = messageListFrame.size.height - self.messageVC.view.frame.size.height;
        messageListOffset = self.messageVC.contentOffSet - diff;
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         // offset присвоим до изменения фрейма
                         self.messageVC.contentOffSet = messageListOffset;
                         
                         self.messageBarVC.view.frame = messageBarFrame;
                         self.messageVC.view.frame = messageListFrame;
                         
                     } completion:^(BOOL finished) {
                         [self.view setNeedsUpdateConstraints];
                     }];
}

- (void)resendMessage:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MLChatMessage *message = notification.object;
        [self messageSend:message.text Video:nil Picture:nil Audio:nil];
    });
}

#pragma mark - NSNotification Actions

- (void)tapped
{
    [self.view endEditing:YES];
}

#pragma mark - MLChatMessageBarViewControllerDelegate

- (void)chatMessageBarViewControllerNeedsHeight:(CGFloat)height
{
    if(height > self.messageBarHeight)
        self.messageVC.contentOffSet = self.messageVC.contentOffSet + (height - self.messageBarHeight);
    else
        self.messageVC.contentOffSet = self.messageVC.contentOffSet - (self.messageBarHeight - height);
    
    self.messageBarHeight = height;
    
    [self.view setNeedsUpdateConstraints];
}

- (void)chatMessageBarViewControllerTappedSend:(NSString *)text
{
    [self.messageBarVC clearText];
    [self messageSend:text Video:nil Picture:nil Audio:nil];
}

@end
