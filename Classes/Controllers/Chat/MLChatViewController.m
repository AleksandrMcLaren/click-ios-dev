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

// высота клавиатуры с выключенным автокомплитом
static CGFloat keyboardLastHeight = 224.f;

@interface MLChatViewController () <MLChatMessageBarViewControllerDelegate, MLChatMessageListViewControllerDelegate>

@property (nonatomic, strong) MLChatMessageListViewController *messageVC;
@property (nonatomic, strong) MLChatMessageBarViewController *messageBarVC;
@property (nonatomic, strong) MLChatMenuAttachViewController *menuAttachVC;

@property (nonatomic) CGFloat addedViewHeight;
@property (nonatomic) CGFloat messageBarHeight;
@property (nonatomic) BOOL lockChangeFrame;

@end

@implementation MLChatViewController

- (id)init
{
    self = [super init];
    
    if(self)
    {
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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pbg"]];

    [self.view addSubview:self.messageVC.view];
    [self.view addSubview:self.menuAttachVC.view];
    [self.view addSubview:self.messageBarVC.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateViewFrames];
}

- (void)updateViewFrames
{
    CGSize boundsSize = self.view.bounds.size;
    
    self.messageVC.view.frame = CGRectMake(0, 0, boundsSize.width, boundsSize.height - self.messageBarHeight - self.addedViewHeight);
    self.messageBarVC.view.frame = CGRectMake(0, boundsSize.height - self.messageBarHeight - self.addedViewHeight, boundsSize.width, self.messageBarHeight);
    self.menuAttachVC.view.frame = CGRectMake(0, boundsSize.height - self.addedViewHeight, boundsSize.width, self.addedViewHeight ? self.addedViewHeight : keyboardLastHeight);
}

- (void)setMessageBarHeight:(CGFloat)messageBarHeight
{
    _messageBarHeight = messageBarHeight;
}

#pragma mark -

- (void)reloadMessages:(NSArray *)messages animated:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageVC reloadMessages:messages animated:animated];
    });
}

- (void)addMessage:(MLChatMessage *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageVC addMessage:message];
    });
}

- (void)resendMessage:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MLChatMessage *message = notification.object;
        self.sendMessage(message.text);
    });
}

- (void)beginRefreshing
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageVC beginRefreshing];
    });
}

- (void)endRefreshing
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageVC endRefreshing];
    });
}

#pragma mark - NSNotification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize boundsSize = self.view.bounds.size;
    
    if(kbRect.origin.y != boundsSize.height)
        keyboardLastHeight = boundsSize.height - kbRect.origin.y;
    
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

    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.messageBarVC.view.frame = messageBarFrame;
                         self.menuAttachVC.view.frame = menuAttachFrame;
                         
                         self.messageVC.contentOffSet = messageListOffset;
                         self.messageVC.view.frame = messageListFrame;
                         
                     } completion:^(BOOL finished) {

                         [self updateViewFrames];
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

    [self updateViewFrames];
}

- (void)chatMessageBarViewControllerTappedSend:(NSString *)text
{
    [self.messageBarVC clearText];
    self.sendMessage(text);
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
        [self updateViewFrames];
    }
    else
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             [self changeViewFramesWithAddedViewTop:self.view.bounds.size.height - keyboardLastHeight];
                         } completion:^(BOOL finished) {
                             [self updateViewFrames];
                         }];
    }
}

- (void)closeMenuAttach
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self changeViewFramesWithAddedViewTop:self.view.bounds.size.height];
                     } completion:^(BOOL finished) {
                         [self updateViewFrames];
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

- (void)chatMessageListViewControllerNeedsReloadData
{
    if(self.reloadMessages)
        self.reloadMessages();
}

@end
