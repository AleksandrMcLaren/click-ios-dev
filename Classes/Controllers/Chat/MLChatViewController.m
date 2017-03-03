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
#import "MLChatMenuAttachViewController.h"

@interface MLChatViewController () <MLChatMessageBarViewControllerDelegate, MLChatMessageListViewControllerDelegate>

@property (nonatomic, strong) CKChatModel *chat;
@property (nonatomic, strong) MLChatMessageListViewController *messageVC;
@property (nonatomic, strong) MLChatMessageBarViewController *messageBarVC;
@property (nonatomic, strong) MLChatMenuAttachViewController *menuAttachVC;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) MLChatMessage *lastMessage;

@property (nonatomic) CGFloat addedViewHeight;
@property (nonatomic) CGFloat messageBarHeight;
@property (nonatomic) BOOL lockChangeFrame;

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
        self.messageVC.delegate = self;
        
        self.messageBarHeight = 46.f;
        self.messageBarVC = [[MLChatMessageBarViewController alloc] init];
        self.messageBarVC.delegate = self;
        
        self.menuAttachVC = [[MLChatMenuAttachViewController alloc] init];
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
    [self.view addSubview:self.menuAttachVC.view];
    [self.view addSubview:self.messageBarVC.view];
    
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
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"ident = %@", msg.id];
        MLChatMessage *existMessage = [self.messages filteredArrayUsingPredicate:pred].firstObject;
        
        if(existMessage)
        {
            existMessage.status = (NSInteger)msg.status;
            [self updateStatusMessage:existMessage];
        }
        else
        {
            MLChatMessage *message = [self createFromMessage:msg];
            [self.messages addObject:message];
            
            [self.messageVC addMessage:message];
        }
    }];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    CGSize boundsSize = self.view.bounds.size;
    CGFloat messageBarBottomOffset = self.addedViewHeight;
    
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
        make.height.equalTo(boundsSize.height - messageBarBottomOffset - self.messageBarHeight);
        //  make.bottom.equalTo(self.messageBarVC.view.top);
    }];
    
    
    [self.menuAttachVC.view updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.top.equalTo(self.messageBarVC.view.bottom);
        make.height.equalTo(self.addedViewHeight);
    }];
    
    [super updateViewConstraints];
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
    
    if(!self.lastMessage || self.lastMessage.isOwner != message.isOwner)
        message.isFirst = YES;
    
    self.lastMessage = message;
    
    return message;
}

- (void)messageSend:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio
{
    [self.chat send:text Video:video Picture:picture Audio:audio];
}

- (void)updateStatusMessage:(MLChatMessage *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:mlchat_message_update_status(message.ident)
                                                        object:message
                                                      userInfo:nil];
}

- (void)resendMessage:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MLChatMessage *message = notification.object;
        [self messageSend:message.text Video:nil Picture:nil Audio:nil];
    });
}

#pragma mark - NSNotification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self changeViewFramesWithAddedViewTop:kbRect.origin.y];
}

- (void)changeViewFramesWithAddedViewTop:(CGFloat)top
{
    if(self.lockChangeFrame)
    {
        self.lockChangeFrame = NO;
        return;
    }
    
    CGSize boundsSize = self.view.bounds.size;
    self.addedViewHeight = boundsSize.height - top;
    
    CGRect messageBarFrame = self.messageBarVC.view.frame;
    messageBarFrame.origin.y = boundsSize.height - self.addedViewHeight - messageBarFrame.size.height;
    
    CGRect messageListFrame = self.messageVC.view.frame;
    messageListFrame.size.height = boundsSize.height - (boundsSize.height - messageBarFrame.origin.y);
    
    CGRect menuAttachFrame = self.menuAttachVC.view.frame;
    menuAttachFrame.origin.y = messageBarFrame.origin.y + messageBarFrame.size.height;

    CGFloat messageListOffset = 0;
    
    if(boundsSize.height != top)
    {  // открывается
        CGFloat diff = self.messageVC.view.frame.size.height - messageListFrame.size.height;
        messageListOffset = self.messageVC.contentOffSet + diff;
        
        menuAttachFrame.size.height = self.addedViewHeight;
    }
    else
    {   // закрывается
        CGFloat diff = messageListFrame.size.height - self.messageVC.view.frame.size.height;
        messageListOffset = self.messageVC.contentOffSet - diff;
    }
    
    NSLog(@"%@", NSStringFromCGRect(self.view.frame));
    NSLog(@"%@", NSStringFromCGRect(messageBarFrame));
    NSLog(@"%@", NSStringFromCGRect(messageListFrame));
    NSLog(@"%@", NSStringFromCGRect(menuAttachFrame));
    NSLog(@"%f", self.messageVC.contentOffSet);

    self.messageBarVC.view.frame = messageBarFrame;
    self.menuAttachVC.view.frame = menuAttachFrame;
    
    self.messageVC.contentOffSet = messageListOffset;
    self.messageVC.view.frame = messageListFrame;
  

    return;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.messageBarVC.view.frame = messageBarFrame;
                         self.menuAttachVC.view.frame = menuAttachFrame;
                         
                         self.messageVC.contentOffSet = messageListOffset;
                         self.messageVC.view.frame = messageListFrame;
                         
                     } completion:^(BOOL finished) {
                         
                         NSLog(@"-- %@", NSStringFromCGRect(self.messageBarVC.view.frame));
                         [self.view setNeedsUpdateConstraints];
                     }];
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

- (void)chatMessageBarTappedAttachButton
{
    [self openMenuAttach];
}

#pragma mark - Menu Attach

- (void)openMenuAttach
{
    if(self.addedViewHeight)
    {   // клавиатура открыта, закроется из messageBarVC, под ней должно быть меню
        self.lockChangeFrame = YES;
        [self.view setNeedsUpdateConstraints];
    }
    else
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             [self changeViewFramesWithAddedViewTop:self.view.bounds.size.height - 258.f];
                         } completion:^(BOOL finished) {
                             [self.view setNeedsUpdateConstraints];
                         }];
    }
}

- (void)closeMenuAttach
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self changeViewFramesWithAddedViewTop:self.view.bounds.size.height];
                     } completion:^(BOOL finished) {
                         [self.view setNeedsUpdateConstraints];
                     }];
    
}

#pragma mark - MLChatMessageListViewControllerDelegate

- (void)chatMessageListViewControllerTapped
{
    if(!self.addedViewHeight)
        return;
    
    if(self.messageBarVC.textEditing)
        [self.view endEditing:YES];
    else
        [self closeMenuAttach];
    
    [self.messageBarVC endEditing];
}

@end
