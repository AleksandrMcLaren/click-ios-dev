//
//  MLChatBarAvaViewController.m
//  click
//
//  Created by Aleksandr on 28/03/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatBarAvaViewController.h"
#import "MLChatAvaViewController.h"

@interface MLChatBarAvaViewController ()

@property (nonatomic, strong) MLChatAvaViewController *avaVC;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIView *onlineView;

@end

@implementation MLChatBarAvaViewController

- (id)init
{
    self = [super init];
    
    if(self)
    {
        self.avaVC = [[MLChatAvaViewController alloc] init];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        
        self.subtitleLabel = [[UILabel alloc] init];
        self.subtitleLabel.font = [UIFont systemFontOfSize:10];
        self.subtitleLabel.textColor = [UIColor grayColor];
        
        self.onlineView = [[UIView alloc] init];
        self.onlineView.backgroundColor = [UIColor greenColor];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.avaVC.view];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.subtitleLabel];
    [self.view addSubview:self.onlineView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize boundsSize = self.view.bounds.size;
    
    self.avaVC.view.frame = CGRectMake(0, (boundsSize.height - self.avaVC.diameter) / 2, self.avaVC.diameter, self.avaVC.diameter);
    
    if(!self.onlineView.hidden)
    {
        self.titleLabel.frame = CGRectMake(self.avaVC.diameter + 7, boundsSize.height / 2 - self.titleLabel.font.lineHeight + 3, boundsSize.width - (self.avaVC.diameter + 5), self.titleLabel.font.lineHeight);
        
        self.subtitleLabel.frame = CGRectMake(self.avaVC.diameter + 15, boundsSize.height / 2 + 4, boundsSize.width - (self.avaVC.diameter + 15), self.subtitleLabel.font.lineHeight);

        self.onlineView.frame = CGRectMake(self.avaVC.diameter + 7, self.subtitleLabel.frame.origin.y + 4, 5, 5);
        self.onlineView.layer.cornerRadius = self.onlineView.frame.size.width / 2;
    }
    else if(self.subtitleLabel.text && self.subtitleLabel.text.length)
    {
        self.titleLabel.frame = CGRectMake(self.avaVC.diameter + 7, boundsSize.height / 2 - self.titleLabel.font.lineHeight + 3, boundsSize.width - (self.avaVC.diameter + 5), self.titleLabel.font.lineHeight);
        
        self.subtitleLabel.frame = CGRectMake(self.avaVC.diameter + 7, boundsSize.height / 2 + 4, boundsSize.width - (self.avaVC.diameter + 5), self.subtitleLabel.font.lineHeight);
    }
    else
    {
        self.titleLabel.frame = CGRectMake(self.avaVC.diameter + 7, (boundsSize.height - self.titleLabel.font.lineHeight) / 2, boundsSize.width - (self.avaVC.diameter + 5), self.titleLabel.font.lineHeight);
    }
}

- (void)setAvatarUrl:(NSString *)avatarUrl
{
    _avatarUrl = avatarUrl;
    [self.avaVC setImageUrl:self.avatarUrl name:self.titleText];
}

- (void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    [self.avaVC setImageUrl:self.avatarUrl name:self.titleText];
    self.titleLabel.text = self.titleText;
    [self.view setNeedsLayout];
}

- (void)setSubtitleText:(NSString *)subtitleText
{
    _subtitleText = subtitleText;
    self.subtitleLabel.text = self.subtitleText;
    [self.view setNeedsLayout];
}

- (void)setOnline:(BOOL)online
{
    _online = online;
    self.onlineView.hidden = !self.online;
    [self.view setNeedsLayout];
}

@end
