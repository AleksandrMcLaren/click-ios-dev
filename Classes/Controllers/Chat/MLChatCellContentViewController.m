//
//  MLChatCellContentViewController.m
//  click
//
//  Created by Aleksandr on 07/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatCellContentViewController.h"

@interface MLChatCellContentViewController ()

@end

@implementation MLChatCellContentViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.maxWidth = 250.f;
    }
    
    return self;
}

- (void)setMaxWidth:(CGFloat)maxWidth
{
    _maxWidth = maxWidth;
}

@end


@implementation MLChatMessage

@end
