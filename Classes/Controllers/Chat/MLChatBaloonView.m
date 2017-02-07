//
//  MLChatBaloonView.m
//  click
//
//  Created by Aleksandr on 06/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatBaloonView.h"

@interface MLChatBaloonView ()

@property (nonatomic, strong) UIImageView *mask;
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
    
    self.mask.frame = self.bounds;
    
    self.shadow.frame = self.frame;
}

- (void)setIsFirst:(BOOL)isFirst
{
    _isFirst = isFirst;
    
    if (self.isFirst)
    {
        self.mask = [[UIImageView alloc] initWithImage:
                         [[UIImage imageNamed:@"cellMask"] resizableImageWithCapInsets:UIEdgeInsetsMake(21, 16, 16, 16)
                                                                          resizingMode:UIImageResizingModeStretch]];
        
//        
//        self.shadow = [[UIImageView alloc] initWithImage:
//                               [[UIImage imageNamed:@"cellMaskShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 16, 20, 20)
//                                                                                      resizingMode:UIImageResizingModeStretch]];
    }
    else
    {
        self.mask = [[UIImageView alloc] initWithImage:
                         [[UIImage imageNamed:@"secondaryCellMask"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 20, 16)
                                                                                   resizingMode:UIImageResizingModeStretch]];
//        
//        self.shadow = [[UIImageView alloc] initWithImage:
//                               [[UIImage imageNamed:@"secondaryCellMaskShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 20, 16)
//                                                                                               resizingMode:UIImageResizingModeStretch]];
        
    }
    
    self.mask.contentMode = UIViewContentModeScaleToFill;
    self.maskView = self.mask;
    
//    self.maskView.layer.masksToBounds = NO;
//    self.maskView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.maskView.layer.shadowOffset = CGSizeMake(10, 5); //Here your control your spread
//    self.maskView.layer.shadowOpacity = 0.5;
//    self.maskView.layer.shadowRadius = 5.0;
//    self.shadow = UIViewContentModeScaleToFill;
//    [self addSubview:self.shadow];

}

- (void)setIsReceived:(BOOL)isReceived
{
    _isReceived = isReceived;
    
    if (self.isReceived)
    {
        self.mask.transform = CGAffineTransformIdentity;
      //  self.shadow.transform = CGAffineTransformIdentity;
        self.backgroundColor = [UIColor whiteColor];
    } else
    {
        self.mask.transform = CGAffineTransformMakeScale(-1, 1);
      //  self.shadow.transform = CGAffineTransformMakeScale(-1, 1);
        self.backgroundColor = [UIColor colorWithRed:0.81 green:0.91 blue:0.98 alpha:1.00];
    }
    
   // self.layer.cornerRadius = 2
    
}

@end
