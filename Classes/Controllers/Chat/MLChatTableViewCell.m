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

@interface MLChatTableViewCell ()

@property (nonatomic, strong) MLChatAvaViewController *avaVC;
@property (nonatomic, strong) MLChatBaloonView *balloonView;

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
    CGFloat blnWidth = 250;
    CGFloat blnHeight = 80.f;
    
    if(!self.message.isReceived)
    {
        avaInsetLeft = boundsSize.width - self.avaVC.height - avaInsetLeft;
        blnInsetLeft = boundsSize.width - blnWidth - blnInsetLeft;
    }
    
    if(self.message.isFirst)
    {
        [self.avaVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(avaInsetTop);
            make.left.equalTo(avaInsetLeft);
            make.width.equalTo(self.avaVC.height);
            make.height.equalTo(self.avaVC.height);
        }];

        blnInsetTop = self.avaVC.height + 2;
    }
    
    UIEdgeInsets blnInset = UIEdgeInsetsMake(blnInsetTop,
                                             blnInsetLeft,
                                             5.f,
                                             boundsSize.width - blnWidth - blnInsetLeft);
    
    [self.balloonView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).with.insets(blnInset);
        make.width.equalTo(blnWidth);
        make.height.equalTo(blnHeight);
    }];
    
    [super updateConstraints];
}

- (void)setMessage:(MLChatMessageModel *)message
{
    _message = message;

    self.balloonView.isFirst = self.message.isFirst;
    self.balloonView.isReceived = self.message.isReceived;
    
    if(self.balloonView.isFirst)
    {
        if(!self.avaVC)
        {
            self.avaVC = [[MLChatAvaViewController alloc] init];
            [self.contentView addSubview:self.avaVC.view];
        }
        
        self.avaVC.imageUrl = self.message.imageUrl;
    }
    
    [self setNeedsUpdateConstraints];
}

@end

@implementation MLChatMessageModel

@end
