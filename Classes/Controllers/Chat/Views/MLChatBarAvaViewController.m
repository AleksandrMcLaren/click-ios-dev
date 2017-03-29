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
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation MLChatBarAvaViewController

- (id)initWithAvatarUrl:(NSString *)avatarUrl name:(NSString *)name
{
    self = [super init];
    
    if(self)
    {
        self.avaVC = [[MLChatAvaViewController alloc] init];
        [self.avaVC setImageUrl:avatarUrl name:name];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:16];
        self.nameLabel.text = name;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.avaVC.view];
    [self.view addSubview:self.nameLabel];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize boundsSize = self.view.bounds.size;
    
    self.avaVC.view.frame = CGRectMake(0, (boundsSize.height - self.avaVC.diameter) / 2, self.avaVC.diameter, self.avaVC.diameter);
    
    self.nameLabel.frame = CGRectMake(self.avaVC.diameter + 5, (boundsSize.height - self.nameLabel.font.lineHeight) / 2, boundsSize.width - (self.avaVC.diameter + 5), self.nameLabel.font.lineHeight);
}

@end
