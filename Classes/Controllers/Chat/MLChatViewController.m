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
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    CGSize boundsSize = self.view.bounds.size;
    
//    [self.messageVC.view updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view.left);
//        make.right.equalTo(self.view.right);
//        make.top.equalTo(self.view.top);
//        make.height.equalTo(boundsSize.height);
//       // make.height.equalTo(boundsSize.height - self.messageBarHeight - self.addedViewHeight);
//        //  make.bottom.equalTo(self.messageBarVC.view.top);
//    }];
    
    [self.messageBarVC.view updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.bottom.equalTo(self.view.bottom).offset(-self.addedViewHeight);
        make.height.equalTo(self.messageBarHeight);
    }];
    
    [self.menuAttachVC.view updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.top.equalTo(self.messageBarVC.view.bottom);
        make.height.equalTo(self.addedViewHeight);
    }];
    
    self.messageVC.contentInsetBottom = self.messageBarHeight + self.addedViewHeight;
    
    [super updateViewConstraints];
}

- (void)setMessageBarHeight:(CGFloat)messageBarHeight
{
    _messageBarHeight = messageBarHeight;
}

#pragma mark -

- (void)addMessages:(NSArray *)messages
{
    [self.messageVC addMessages:messages];
}

- (void)addMessage:(MLChatMessage *)message
{
    [self.messageVC addMessage:message];
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
        self.sendMessage(message.text);
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
    
//    CGRect messageListFrame = self.messageVC.view.frame;
//    messageListFrame.size.height = boundsSize.height - (boundsSize.height - messageBarFrame.origin.y);
    
    CGRect menuAttachFrame = self.menuAttachVC.view.frame;
    menuAttachFrame.origin.y = messageBarFrame.origin.y + messageBarFrame.size.height;

  //  CGFloat messageListOffset = 0;
    
    if(boundsSize.height != top)
    {  // открывается
      //  CGFloat diff = self.messageVC.view.frame.size.height - messageListFrame.size.height;
      //  messageListOffset = self.messageVC.contentOffSet + diff;
        
        menuAttachFrame.size.height = self.addedViewHeight;
    }
    else
    {   // закрывается
      //  CGFloat diff = messageListFrame.size.height - self.messageVC.view.frame.size.height;
      //  messageListOffset = self.messageVC.contentOffSet - diff;
    }

    self.messageBarVC.view.frame = messageBarFrame;
    self.menuAttachVC.view.frame = menuAttachFrame;
    
  //  self.messageVC.contentOffSet = messageListOffset;
  //  self.messageVC.view.frame = messageListFrame;
    
    
  //  CGFloat newBottom = messageBarFrame.size.height + self.addedViewHeight;
   // CGFloat contentOffSet = messageBarFrame.size.height + self.addedViewHeight;
    
//    if(newBottom < bottom)
//    {
//        contentOffSet *= -1;
//        
////        CGFloat contentInsetHeight = self.messageVC.tableView.contentSize.height;
////        
////        if(contentInsetHeight < (self.messageVC.view.frame.size.height - messageBarFrame.size.height))
////            contentOffSet += (self.messageVC.view.frame.size.height - messageBarFrame.size.height) - contentInsetHeight;
//    }
    
    CGFloat bottom = self.messageVC.contentInsetBottom;
    self.messageVC.contentInsetBottom = self.messageBarHeight + self.addedViewHeight;
    CGFloat newBottom = self.messageVC.contentInsetBottom;

    if(newBottom > bottom)
    {
        self.messageVC.contentOffSet += (newBottom - bottom);
        
//        CGFloat contentSizeHeight = self.messageVC.tableView.contentSize.height;
//        CGFloat viewHeight = self.messageVC.tableView.frame.size.height - self.messageVC.tableView.contentInset.top - self.messageVC.tableView.contentInset.bottom;
//        
//        if(contentSizeHeight >= viewHeight)
//        {
//        NSLog(@"%f", newBottom - bottom)
//           self.messageVC.contentOffSet += (newBottom - bottom);
//        }
    }
    
    [self.view setNeedsUpdateConstraints];
//    else
//    {
////        CGFloat offset = bottom - newBottom;
//        CGFloat contentSizeHeight = self.messageVC.tableView.contentSize.height;
//       
////        if(offset > maxOffset)
////            offset = maxOffset;
//        
//        NSLog(@"%f %f %f %f", newBottom, bottom, self.messageVC.contentOffSet, contentSizeHeight);
//        self.messageVC.contentOffSet += 100;
//        
//    }

  //  self.messageVC.contentOffSet = contentOffSet;
    
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
