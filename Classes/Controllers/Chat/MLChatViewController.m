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
        self.messages = [[NSMutableArray alloc] init];
        
        self.messageVC = [[MLChatMessageListViewController alloc] init];
        
        self.messageBarHeight = 51.f;
        self.messageBarVC = [[MLChatMessageBarViewController alloc] init];
        self.messageBarVC.delegate = self;
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgwhite"]];

    [self.view addSubview:self.messageVC.view];
    [self.view addSubview:self.messageBarVC.view];
    [self.view addGestureRecognizer:self.tapRecognizer];
/*
    MLChatMessageModel *msg = [[MLChatMessageModel alloc] init];
    msg.isFirst = YES;
   // msg.isReceived = YES;
    msg.imageUrl = @"sdfg";
    msg.text = @"sdlkgj lsdfkgj sdflgkj!!!";
    
    MLChatMessageModel *msg2 = [[MLChatMessageModel alloc] init];
    msg2.isFirst = NO;
  //  msg2.isReceived = YES;
    msg2.imageUrl = @"sdfg";
    msg2.text = @"sdlkgj lsdfkgj sdflgkj!!!";
    
    MLChatMessageModel *msg3 = [[MLChatMessageModel alloc] init];
    msg3.isFirst = YES;
  //  msg3.isReceived = NO;
    msg3.imageUrl = @"sdfg";
    msg3.text = @"sdlkgj lsdfkgj sdflgkj sdlfkjha;sdif a;dskflgj as;ldfgjk !!!";
    
    MLChatMessageModel *msg4 = [[MLChatMessageModel alloc] init];
    msg4.isFirst = NO;
   // msg4.isReceived = NO;
    msg4.imageUrl = @"sdfg";
    msg4.text = @"sdlkgj lsdfkgj sdflgkj!!!";
    
    MLChatMessageModel *msg5 = [[MLChatMessageModel alloc] init];
    msg5.isFirst = NO;
   // msg5.isReceived = NO;
    msg5.imageUrl = @"sdfg";
    msg5.text = @"sdlkgj lsdfkgj sdflgkj sdlfkjha;sdif a;dskflgj as;ldfgjk sdlkgj lsdfkgj sdflgkj sdlfkjha;sdif a;dskflgj as;ldfgjk sdlkgj lsdfkgj sdflgkj sdlfkjha;sdif a;dskflgj as;ldfgjk sdlkgj lsdfkgj sdflgkj sdlfkjha;sdif a;dskflgj as;ldfgjk sdlkgj lsdfkgj sdflgkj sdlfkjha;sdif a;dskflgj as;ldfgjk sdlkgj lsdfkgj sdflgkj sdlfkjha;sdif a;dskflgj as;ldfgjk sdlkgj lsdfkgj sdflgkj sdlfkjha;sdif a;dskflgj as;ldfgjk sdlkgj lsdfkgj sdflgkj sdlfkjha;sdif a;dskflgj as;ldfgjk!!!";
    
  // [self.messageVC addMessages:@[msg, msg2, msg3, msg4, msg5, msg3, msg4, msg5]];

//     [self.messageVC addMessages:@[msg, msg2]];
 */
    
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
    
    if(!self.lastMessage || self.lastMessage.isOwner != message.isOwner)
        message.isFirst = YES;
    
    self.lastMessage = message;
    
    return message;
}

- (void)updateViewConstraints
{
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

#pragma mark - Actions

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
