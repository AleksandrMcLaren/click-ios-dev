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
#import "MLChatTableViewCell.h"

@interface MLChatViewController () <MLChatMessageBarViewControllerDelegate>

@property (nonatomic, strong) CKChatModel *chat;
@property (nonatomic, strong) MLChatMessageListViewController *messageVC;
@property (nonatomic, strong) MLChatMessageBarViewController *messageBarVC;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

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
        
        self.messageBarHeight = 51.f;
        
        self.messageVC = [[MLChatMessageListViewController alloc] init];
        
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

    MLChatMessageModel *msg = [[MLChatMessageModel alloc] init];
    msg.isFirst = YES;
    msg.isReceived = YES;
    msg.imageUrl = @"sdfg";
    
    MLChatMessageModel *msg2 = [[MLChatMessageModel alloc] init];
    msg2.isFirst = NO;
    msg2.isReceived = YES;
    msg2.imageUrl = @"sdfg";
    
    MLChatMessageModel *msg3 = [[MLChatMessageModel alloc] init];
    msg3.isFirst = YES;
    msg3.isReceived = NO;
    msg2.imageUrl = @"sdfg";
    
    MLChatMessageModel *msg4 = [[MLChatMessageModel alloc] init];
    msg4.isFirst = NO;
    msg4.isReceived = NO;
    msg4.imageUrl = @"sdfg";
    
    MLChatMessageModel *msg5 = [[MLChatMessageModel alloc] init];
    msg5.isFirst = NO;
    msg5.isReceived = NO;
    msg5.imageUrl = @"sdfg";
    
    [self.messageVC addMessages:@[msg, msg2, msg3, msg4, msg5, msg3, msg4, msg5]];
    
//    [self.chat.messagesDidChanged subscribeNext:^(NSArray *msgs) {
//        
//        MLChatMessageModel *msg = [[MLChatMessageModel alloc] init];
//        msg.isFisrt = YES;
//        msg.ava
//        
//        [self.messageVC addMessages:msgs];
//    }];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    CGFloat messageBarBottomOffset = self.keyboardHeight;
    
    [self.messageBarVC.view updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(20);
        make.right.equalTo(self.view.right).offset(-20);
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
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.messageBarVC.view.frame = messageBarFrame;
                         self.messageVC.view.frame = messageListFrame;
                         
//                         if(boundsSize.height != kbRect.origin.y)
//                         {  // открывается
//                             self.messageVC.contentOffSet = self.messageVC.contentOffSet + kbRect.origin.y;
//                         }

                         
                     } completion:^(BOOL finished) {
                         [self.view setNeedsUpdateConstraints];
                     }];
}

- (void)tapped
{
    [self.view endEditing:YES];
}

#pragma mark - MLChatMessageBarViewControllerDelegate

- (void)chatMessageBarNeedsHeight:(CGFloat)height
{
    if(height > self.messageBarHeight)
        self.messageVC.contentOffSet = self.messageVC.contentOffSet + (height - self.messageBarHeight);
    else
        self.messageVC.contentOffSet = self.messageVC.contentOffSet - (self.messageBarHeight - height);
    
    self.messageBarHeight = height;
    
    [self.view setNeedsUpdateConstraints];
}

@end
