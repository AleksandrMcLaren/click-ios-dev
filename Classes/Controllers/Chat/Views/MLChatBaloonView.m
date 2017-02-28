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

@end


@implementation MLChatBaloonView

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.mask = [[UIImageView alloc] init];
      //  self.mask.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.mask];
        
        UILongPressGestureRecognizer * recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [recognizer setMinimumPressDuration:1.0f];
        [self addGestureRecognizer:recognizer];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.mask.frame = self.bounds;
}

- (void)setMessage:(MLChatMessage *)message
{
    _message = message;
    
    if(self.message.isOwner)
    {
        if(self.message.isFirst)
        {
            self.mask.image = [[UIImage imageNamed:@"baloon_out_tick"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 16, 16, 16)
                                                                                      resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            self.mask.image = [[UIImage imageNamed:@"baloon_out"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16)
                                                                                 resizingMode:UIImageResizingModeStretch];
        }
    }
    else
    {
        if(self.message.isFirst)
        {
            self.mask.image = [[UIImage imageNamed:@"baloon_in_tick"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 16, 16, 16)
                                                                                  resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            self.mask.image = [[UIImage imageNamed:@"baloon_in"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16)
                                                                                resizingMode:UIImageResizingModeStretch];
        }
    }
}

#pragma mark -
#pragma mark UIGestureRecognizer-Handling

-(void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer {
    /*When a LongPress is recognized, the copy-menu will be displayed.*/
//    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
//        [self updateSelectedBackground];
//    } else {
//        [self updateBackground];
//    }
    
    if ([self becomeFirstResponder] == NO) {
        return;
    }
    
    /*Display UIMenuController.*/
  //  UIMenuController * menu = [UIMenuController sharedMenuController];
   // [menu setTargetRect:self.balloonView.frame inView:self];
   // [menu setMenuVisible:YES animated:YES];
}

-(BOOL)canBecomeFirstResponder {
    /*This cell can become first-responder*/
    return YES;
}


#pragma mark -
#pragma mark Action-Handler

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    /*Allows the copy-Action on this cell.*/
    if (action == @selector(copy:)) {
        return YES;
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

-(void)copy:(id)sender {
    /**Copys the messageString to the clipboard.*/
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:@"la la la"];
}


/*
- (void)setMessage:(MLChatMessage *)message
{
    _message = message;

    if (self.message.isFirst)
    {
        self.mask = [[UIImageView alloc] initWithImage:
                         [[UIImage imageNamed:@"cellMask"] resizableImageWithCapInsets:UIEdgeInsetsMake(21, 16, 16, 16)
                                                                          resizingMode:UIImageResizingModeStretch]];
    }
    else
    {
        self.mask = [[UIImageView alloc] initWithImage:
                         [[UIImage imageNamed:@"secondaryCellMask"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16)
                                                                                   resizingMode:UIImageResizingModeStretch]];
    }
    
    [self addSubview:self.mask];
    
    
    self.mask.contentMode = UIViewContentModeScaleToFill;
    self.maskView = self.mask;
    //self.clipsToBounds = YES;

//    self.mask.layer.masksToBounds = NO;
//    self.mask.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.mask.layer.shadowOffset = CGSizeMake(10, 5); //Here your control your spread
//    self.mask.layer.shadowOpacity = 0.5;
//    self.mask.layer.shadowRadius = 5.0;
//    self.shadow = UIViewContentModeScaleToFill;
//    [self addSubview:self.shadow];


    if (self.message.isOwner)
    {
        self.mask.transform = CGAffineTransformMakeScale(-1, 1);
        //  self.shadow.transform = CGAffineTransformMakeScale(-1, 1);
        self.backgroundColor = [UIColor colorWithRed:0.81 green:0.91 blue:0.98 alpha:1.00];
        
    } else
    {
        self.mask.transform = CGAffineTransformIdentity;
        //  self.shadow.transform = CGAffineTransformIdentity;
        self.backgroundColor = [UIColor whiteColor];
    }
}
*/

@end
