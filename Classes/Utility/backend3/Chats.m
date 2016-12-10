//
//  Chats.m
//  click
//
//  Created by Дрягин Павел on 10.12.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "Chats.h"

@interface Chats()
{
    NSMutableDictionary* _chats;
}
@end

@implementation Chats

+ (Chats *)sharedInstance

{
    static dispatch_once_t once;
    static Chats *chats;
    
    dispatch_once(&once, ^{ chats = [[Chats alloc] init]; });
    
    return chats;
}

- (CKChatModel*)getWithDialog:(CKDialogModel*)dialog{
    CKChatModel* result;
    if ([_chats objectForKey:dialog.dialogId]) {
        result = [_chats objectForKey:dialog.dialogId];
    }
    return result;
}

@end
