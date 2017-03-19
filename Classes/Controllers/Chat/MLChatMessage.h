//
//  MLChatMessage.h
//  click
//
//  Created by Александр on 11.02.17.
//  Copyright © 2017 Click. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *mlchat_message_needs_resend = @"mlchat_message_needs_resend";

typedef NS_ENUM(NSInteger, MLChatMessageStatus)
{
    MLChatMessageStatusSent,
    MLChatMessageStatusDelivered,
    MLChatMessageStatusRead,
    MLChatMessageStatusNotSent
};

@interface MLChatMessage : NSObject

@property (nonatomic, strong) NSString *ident;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *userLogin;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic) BOOL isFirst;
@property (nonatomic) BOOL isOwner;
@property (nonatomic) MLChatMessageStatus status;

@property (copy) void (^updatedStatus)();

@end
