//
//  Chats.h
//  click
//
//  Created by Дрягин Павел on 10.12.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKChatModel.h"
#import "CKDialogChatModel.h"

@interface Chats : NSObject

+ (Chats *)sharedInstance;

- (CKChatModel*)getWithDialog:(CKDialogChatModel*)dialog;

@end
