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
@property (nonatomic) UIEdgeInsets insets;

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
        
        self.insets = UIEdgeInsetsMake(15, 10, 15, 10);
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
    
    self.label.frame = CGRectMake(self.insets.left, self.insets.top, self.textSize.width, self.textSize.height);
}

- (void)setMessage:(MLChatMessageModel *)message
{
    [super setMessage:message];
    
  //  NSLog(@"---- %@ | %@ | %@", self, self.label.text, self.message);
    
    self.label.text = self.message.text;
    
    self.textSize = [self.label.text boundingRectWithSize:CGSizeMake(250, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:self.label.font}
                                                  context:nil].size;
    [self.view setNeedsLayout];
    
    CGSize size = CGSizeMake(self.insets.left + self.textSize.width + self.insets.right, self.insets.top + self.textSize.height + self.insets.bottom);
    [self.delegate chatCellContentViewControllerNeedsSize:size];
}

@end
