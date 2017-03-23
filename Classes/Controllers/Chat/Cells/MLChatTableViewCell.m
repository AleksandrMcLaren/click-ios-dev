//
//  MLChatTableViewCell.m
//  click
//
//  Created by Aleksandr on 03/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatTableViewCell.h"
#import "MLChatAvaViewController.h"
#import "MLChatBaloonView.h"
#import "MLChatCellTextViewController.h"
#import "MLChatStatusViewController.h"

@interface MLChatTableViewCell () <MLChatCellContentViewControllerDelegate>

@property (nonatomic, strong) MLChatAvaViewController *avaVC;
@property (nonatomic, strong) MLChatBaloonView *balloonView;
@property (nonatomic, strong) MLChatCellContentViewController *contentVC;
@property (nonatomic, strong) MLChatStatusViewController *statusVC;

@property (nonatomic) CGSize contentSize;

@end

@implementation MLChatTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.avaVC = [[MLChatAvaViewController alloc] init];
        [self.contentView addSubview:self.avaVC.view];
        
        self.balloonView = [[MLChatBaloonView alloc] init];
        [self.contentView addSubview:self.balloonView];

        self.statusVC = [[MLChatStatusViewController alloc] init];
        [self.contentView addSubview:self.statusVC.view];
    }
    
    return self;
}

- (void)updateConstraints
{
    CGSize boundsSize = self.contentView.frame.size;
    CGFloat insetLeft = 5.f;
    
    CGFloat avaInsetTop = 0;
    CGFloat avaInsetLeft = insetLeft;
    
    CGFloat blnInsetTop = 2.f;
    CGFloat blnInsetLeft = insetLeft;
    CGFloat blnInsetBottom = 0.f;
    CGSize blnSize = CGSizeMake(self.contentSize.width, self.contentSize.height);
    CGFloat tailHeight = 6.f;
    
    if(self.message.showBalloonTail)
    {   // учтем хвостик
        blnSize.height += tailHeight;
    }
    
    CGSize statusSize = CGSizeMake(self.message.isOwner ? 60 : 48, 20);
    
    if(self.message.isOwner)
        blnInsetLeft = boundsSize.width - blnSize.width - blnInsetLeft;
    
    if(!self.avaVC.view.hidden)
    {
        blnInsetTop = avaInsetTop + self.avaVC.diameter - 3;
    
        if(self.message.isOwner)
            avaInsetLeft = boundsSize.width - insetLeft - self.avaVC.diameter;
            
        [self.avaVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(avaInsetTop);
            make.left.equalTo(avaInsetLeft);
            make.width.equalTo(self.avaVC.diameter);
            make.height.equalTo(self.avaVC.diameter);
        }];
    }

    [self.contentVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.message.showBalloonTail ? tailHeight / 2 : 0);
        make.left.equalTo(0);
        make.width.equalTo(self.contentSize.width);
        make.height.equalTo(self.contentSize.height);
    }];

    UIEdgeInsets blnInset = UIEdgeInsetsMake(blnInsetTop,
                                             blnInsetLeft,
                                             -blnInsetBottom,
                                             boundsSize.width - blnSize.width - blnInsetLeft);
    
    [self.balloonView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).with.insets(blnInset);
        make.width.equalTo(blnSize.width);
        make.height.equalTo(blnSize.height);
    }];

    [self.statusVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.balloonView).offset(-5);
        make.bottom.equalTo(self.balloonView).offset(-9);
        make.width.equalTo(statusSize.width);
        make.height.equalTo(statusSize.height);
    }];
    
    [super updateConstraints];
}

#pragma mark -

- (void)setMessage:(MLChatMessage *)message
{
    _message = message;

    [self updateBaloon];
    [self updateAvatar];
    [self updateContent];
    [self updateStatus];
}

- (void)updateBaloon
{
    self.balloonView.message = self.message;
}

- (void)updateAvatar
{
    if(self.message.showAvatar)
    {
        self.avaVC.view.hidden = NO;
        self.avaVC.message = self.message;
    }
    else
    {
        self.avaVC.view.hidden = YES;
        self.avaVC.message = nil;
    }
}

- (void)updateContent
{
    [self.contentVC.view removeFromSuperview];
    self.contentVC = nil;
    
    self.contentVC = [[MLChatCellTextViewController alloc] init];
    self.contentVC.delegate = self;
    [self.balloonView addSubview:self.contentVC.view];
    
    self.contentVC.message = self.message;
}

- (void)updateStatus
{
    self.statusVC.message = self.message;
}

#pragma mark - MLChatCellContentViewControllerDelegate

- (void)chatCellContentViewControllerNeedsSize:(CGSize)size
{
    self.contentSize = size;
    [self setNeedsUpdateConstraints];
}

@end


