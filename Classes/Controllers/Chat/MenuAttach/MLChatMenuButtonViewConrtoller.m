//
//  MLChatMenuButtonViewConrtoller.m
//  click
//
//  Created by Александр on 26.02.17.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatMenuButtonViewConrtoller.h"

@interface MLChatMenuButtonViewConrtoller ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation MLChatMenuButtonViewConrtoller

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.button = [[UIButton alloc] init];
        [self.button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.button.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.button.layer.masksToBounds = YES;
        self.button.layer.borderColor = [UIColor colorWithHue:0.58 saturation:0.02 brightness:0.86 alpha:1.00].CGColor;
        self.button.layer.borderWidth = 0.5f;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:13];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.button.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.button];
    [self.view addSubview:self.titleLabel];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGSize boundsSize = self.view.bounds.size;

    self.button.frame = CGRectMake(0, 0, boundsSize.width, boundsSize.width);
    self.button.layer.cornerRadius = self.button.frame.size.width / 4;
    
    self.titleLabel.frame = CGRectMake(0, boundsSize.height - self.titleLabel.font.lineHeight, boundsSize.width, self.titleLabel.font.lineHeight);
}

- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    
    [self.button setImage:[UIImage imageNamed:self.imageName] forState:UIControlStateNormal];
}

- (void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    
    self.titleLabel.text = self.titleText;
}

#pragma mark - Acions

- (void)buttonTapped
{
    
}

@end
