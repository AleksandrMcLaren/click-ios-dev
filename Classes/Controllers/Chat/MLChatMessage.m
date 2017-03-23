//
//  MLChatMessage.m
//  click
//
//  Created by Александр on 11.02.17.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatMessage.h"

@implementation MLChatMessage

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.ident = @"";
    }
    
    return self;
}

@end
