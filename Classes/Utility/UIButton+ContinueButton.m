//
//  UIButton+ContinueButton.m
//  click
//
//  Created by Дрягин Павел on 25.10.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "UIButton+ContinueButton.h"

@implementation UIButton (ContinueButton)

-(instancetype)initContinueButton{
    if ((self = [self.class buttonWithType:UIButtonTypeCustom])) {
        [self setTitle:@"Продолжить" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor lightTextColor] forState:UIControlStateDisabled];
        self.titleLabel.font = CKButtonFont;
        self.backgroundColor = CKClickBlueColor;
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 4;
    }
    return self;
}

@end
