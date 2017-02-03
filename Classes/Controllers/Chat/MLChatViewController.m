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
        
        self.messageBarHeight = 54.f;
        
        self.messageVC = [[MLChatMessageListViewController alloc] init];
        
        self.messageBarVC = [[MLChatMessageBarViewController alloc] init];
        self.messageBarVC.delegate = self;
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.messageVC.view.backgroundColor = [UIColor grayColor];
    
    [self.view addSubview:self.messageVC.view];
    [self.view addSubview:self.messageBarVC.view];
    
    [self.chat.messagesDidChanged subscribeNext:^(NSArray *msgs) {

    }];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    CGFloat messageBarBottomOffset = self.keyboardHeight;
    
    [self.messageBarVC.view updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(20);
        make.right.equalTo(self.view.right).offset(20);
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
    [self.view setNeedsUpdateConstraints];
}

#pragma mark - MLChatMessageBarViewControllerDelegate

- (void)chatMessageBarNeedsHeight:(CGFloat)height
{
    self.messageBarHeight = height;
    [self.view setNeedsUpdateConstraints];
}

@end
