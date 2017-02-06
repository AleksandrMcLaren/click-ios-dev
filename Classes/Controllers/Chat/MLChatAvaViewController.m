//
//  MLChatAvaViewController.m
//  click
//
//  Created by Aleksandr on 06/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatAvaViewController.h"

@interface MLChatAvaViewController ()
@property (nonatomic, strong) UIImageView *imView;

@end


@implementation MLChatAvaViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.view.layer.masksToBounds = YES;
        
        self.imView = [[UIImageView alloc] init];
        self.imView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.height = 30;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];

    [self.view addSubview:self.imView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.view.layer.cornerRadius = self.view.bounds.size.width / 2;
    
    self.imView.frame = self.view.bounds;
}

- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
}

- (void)setHeight:(CGFloat)height
{
    _height = height;
}

@end
