//
//  MLChatBaloonView.m
//  click
//
//  Created by Aleksandr on 06/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatBaloonView.h"

@interface MLChatBaloonView ()

@property (nonatomic, strong) UIImageView *shadow;

@end


@implementation MLChatBaloonView

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {

    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.maskView.frame = self.bounds;
    self.shadow.frame = self.frame;
}

- (void)setIsFirst:(BOOL)isFirst
{
    _isFirst = isFirst;
    
    if (self.isFirst)
    {
        self.maskView = [[UIImageView alloc] initWithImage:
                         [[UIImage imageNamed:@"cellMask"] resizableImageWithCapInsets:UIEdgeInsetsMake(21, 16, 16, 16)
                                                                          resizingMode:UIImageResizingModeStretch]];
//        
//        self.shadow = [[UIImageView alloc] initWithImage:
//                               [[UIImage imageNamed:@"cellMaskShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 16, 20, 20)
//                                                                                      resizingMode:UIImageResizingModeStretch]];
    }
    else
    {
        self.maskView = [[UIImageView alloc] initWithImage:
                         [[UIImage imageNamed:@"secondaryCellMask"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 20, 16)
                                                                                   resizingMode:UIImageResizingModeStretch]];
//        
//        self.shadow = [[UIImageView alloc] initWithImage:
//                               [[UIImage imageNamed:@"secondaryCellMaskShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 20, 16)
//                                                                                               resizingMode:UIImageResizingModeStretch]];
        
    }
    
//    self.shadow = UIViewContentModeScaleToFill;
//    [self addSubview:self.shadow];
}

- (void)setIsReceived:(BOOL)isReceived
{
    _isReceived = isReceived;
    
    if (self.isReceived)
    {
        self.maskView.transform = CGAffineTransformIdentity;
      //  self.shadow.transform = CGAffineTransformIdentity;
        self.backgroundColor = [UIColor whiteColor];
    } else
    {
        self.maskView.transform = CGAffineTransformMakeScale(-1, 1);
      //  self.shadow.transform = CGAffineTransformMakeScale(-1, 1);
        self.backgroundColor = [UIColor colorWithRed:0.81 green:0.91 blue:0.98 alpha:1.00];
    }
    
   // self.layer.cornerRadius = 2
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.5, 4.0); //Here your control your spread
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 5.0;
}

@end
