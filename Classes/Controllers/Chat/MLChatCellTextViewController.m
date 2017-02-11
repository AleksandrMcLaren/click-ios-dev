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
@property (nonatomic) CGFloat minWidth;

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
        self.minWidth = 120;
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

- (void)setMessage:(MLChatMessage *)message
{
    [super setMessage:message];
    
  //  NSLog(@"---- %@ | %@ | %@", self, self.label.text, self.message);
    
    self.label.text = self.message.text;
    
    self.textSize = [self.label.text boundingRectWithSize:CGSizeMake(self.maxWidth, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:self.label.font}
                                                  context:nil].size;
    
    if(self.textSize.width < self.minWidth)
        self.textSize = CGSizeMake(self.minWidth, self.textSize.height);
    
    [self.view setNeedsLayout];
    
    CGSize size = CGSizeMake(self.insets.left + self.textSize.width + self.insets.right, self.insets.top + self.textSize.height + self.insets.bottom);
    [self.delegate chatCellContentViewControllerNeedsSize:size];
}

@end
