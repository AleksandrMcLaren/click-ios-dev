//
//  CKUserAvatarView.m
//  click
//
//  Created by Igor Tetyuev on 01.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKUserAvatarView.h"

@implementation CKUserAvatarView

- (instancetype)initWithUser:(CKUserModel *)user
{
    if (self = [super init])
    {
        self.user = user;
    }
    return self;
}

- (void)setUser:(CKUserModel *)user
{
    _user = user;
    [self setAvatarFile:user.avatarName fallbackName:[user letterName]];
}

@end
