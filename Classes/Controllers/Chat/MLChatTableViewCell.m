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

@interface MLChatTableViewCell () <MLChatCellContentViewControllerDelegate>

@property (nonatomic, strong) MLChatAvaViewController *avaVC;
@property (nonatomic, strong) MLChatBaloonView *balloonView;
@property (nonatomic, strong) MLChatCellContentViewController *contentVC;

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
    }
    
    return self;
}

- (void)updateConstraints
{
    CGSize boundsSize = self.contentView.frame.size;
    CGFloat avaInsetTop = 5.f;
    CGFloat avaInsetLeft = 5.f;
    CGFloat blnInsetTop = avaInsetTop;
    CGFloat blnInsetLeft = avaInsetLeft;
    CGFloat blnInsetBottom = 5.f;
    CGFloat blnWidth = self.contentSize.width;
    CGFloat blnHeight = self.contentSize.height;
    
    if(self.message.isOwner)
    {
        avaInsetLeft = boundsSize.width - self.avaVC.diameter - avaInsetLeft;
        blnInsetLeft = boundsSize.width - blnWidth - blnInsetLeft;
    }
    
    if(self.message.isFirst)
    {
        [self.avaVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(avaInsetTop);
            make.left.equalTo(avaInsetLeft);
            make.width.equalTo(self.avaVC.diameter);
            make.height.equalTo(self.avaVC.diameter);
        }];

        blnInsetTop = self.avaVC.diameter + 2;
    }

    [self.contentVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(0);
        make.left.equalTo(0);
        make.width.equalTo(self.contentSize.width);
        make.height.equalTo(self.contentSize.height);
    }];
    
    UIEdgeInsets blnInset = UIEdgeInsetsMake(blnInsetTop,
                                             blnInsetLeft,
                                             blnInsetBottom,
                                             boundsSize.width - blnWidth - blnInsetLeft);
    
    [self.balloonView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).with.insets(blnInset);
//        make.top.equalTo(blnInsetTop);
//        make.bottom.equalTo(-blnInsetBottom);
//        make.left.equalTo(blnInsetLeft);
        make.width.equalTo(blnWidth);
        make.height.equalTo(blnHeight);
    }];

    [super updateConstraints];
}

- (void)setMessage:(MLChatMessage *)message
{
    _message = message;

    self.balloonView.isFirst = self.message.isFirst;
    self.balloonView.isOwner = self.message.isOwner;
    
    if(self.balloonView.isFirst)
    {
        self.avaVC.view.hidden = NO;
        self.avaVC.imageUrl = self.message.imageUrl;
    }
    else
    {
        self.avaVC.view.hidden = YES;
    }
    
    [self.contentVC.view removeFromSuperview];
    self.contentVC = nil;
    
    self.contentVC = [[MLChatCellTextViewController alloc] init];
    self.contentVC.delegate = self;
    [self.balloonView addSubview:self.contentVC.view];
    
    self.contentVC.message = self.message;
}

#pragma mark - MLChatCellContentViewControllerDelegate

- (void)chatCellContentViewControllerNeedsSize:(CGSize)size
{
    self.contentSize = size;
    [self setNeedsUpdateConstraints];
}

@end


