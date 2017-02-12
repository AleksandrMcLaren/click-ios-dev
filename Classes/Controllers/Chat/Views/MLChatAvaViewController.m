//
//  MLChatAvaViewController.m
//  click
//
//  Created by Aleksandr on 06/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatAvaViewController.h"
#import "MLChatLib.h"

@interface MLChatAvaViewController ()

@property (nonatomic, strong) UIImageView *imView;
@property (nonatomic, strong) UILabel *nameLabel;

@end


@implementation MLChatAvaViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.imView = [[UIImageView alloc] init];
        self.imView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:20.0];
        self.nameLabel.textColor = [UIColor whiteColor];
        
        self.diameter = 30;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.layer.masksToBounds = YES;
    self.view.backgroundColor = [UIColor colorFromHexString:@"#008ce1"];
    
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.imView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.view.layer.cornerRadius = self.view.bounds.size.width / 2;
    
    self.imView.frame = self.view.bounds;
    
    if(!self.nameLabel.hidden)
    {
        CGSize boundsSize = self.view.bounds.size;
        CGSize textSize = [MLChatLib textSizeLabel:self.nameLabel withWidth:boundsSize.width];
        self.nameLabel.frame = CGRectMake((boundsSize.width - textSize.width) / 2, (boundsSize.height - textSize.height) / 2, textSize.width, textSize.height);
    }
}

- (void)setMessage:(MLChatMessage *)message
{
    _message = message;
    
    if(self.message.userLogin && self.message.userLogin.length > 1)
        self.nameLabel.text = [self.message.userLogin substringToIndex:1];
    else
        self.nameLabel.text = nil;
    
    [self.view setNeedsLayout];
}

- (void)setDiameter:(CGFloat)diameter
{
    _diameter = diameter;
}

@end
