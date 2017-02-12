//
//  MLChatMessage.h
//  click
//
//  Created by Александр on 11.02.17.
//  Copyright © 2017 Click. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *mlchat_message_needs_resend = @"mlchat_message_needs_resend";

#define mlchat_message_update_status(v) [NSString stringWithFormat:@"mlchat_message_update_status_%@", v]

typedef NS_ENUM(NSInteger, MLChatMessageStatus)
{
    MLChatMessageStatusSent,
    MLChatMessageStatusDelivered,
    MLChatMessageStatusRead
};

@interface MLChatMessage : NSObject

@property (nonatomic, strong) NSString *ident;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, assign) NSString *text;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) MLChatMessageStatus status;

@end
