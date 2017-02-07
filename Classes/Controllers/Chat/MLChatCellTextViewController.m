//
//  MLChatCellTextViewController.m
//  click
//
//  Created by Aleksandr on 07/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatCellTextViewController.h"

@interface MLChatCellTextViewController ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic) CGSize textSize;

@end


@implementation MLChatCellTextViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.label = [[UILabel alloc] init];
        self.label.textColor = [UIColor blackColor];
        self.label.font = [UIFont systemFontOfSize:16];
        self.label.numberOfLines = 0;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.label];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.label.frame = CGRectMake(0, 0, self.textSize.width, self.textSize.height);
}

- (void)setMessage:(MLChatMessageModel *)message
{
    [super setMessage:message];
    
    self.label.text = self.message.text;
    
    self.textSize = [self.label.text boundingRectWithSize:CGSizeMake(250, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:self.label.font}
                                                  context:nil].size;
    [self.view setNeedsLayout];
    
    [self.delegate chatCellContentViewControllerNeedsSize:self.textSize];
}

@end
