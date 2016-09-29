//
//  CKGroupChatModel.m
//  click
//
//  Created by Igor Tetyuev on 23.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKGroupChatModel.h"

@implementation CKGroupChatModel

- (instancetype)initWithName:(NSString *)name avatar:(NSString *)avatar description:(NSString *)description userIDs:(NSArray *)userIds
{
    if (self = [super init])
    {
        [[CKMessageServerConnection sharedInstance] createGroupChatWithName:name avatar:avatar description:description users:userIds callback:^(NSDictionary *result) {
            _groupId = result[@"result"][@"id"];
        }];
        _dialogType = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:CKMessageServerConnectionReceived object:nil];
    }
    return self;
}

- (instancetype)initWithGroupID:(NSString *)groupId;
{
    if (self = [super init])
    {
        _groupId = groupId;
        [[CKMessageServerConnection sharedInstance] getDialogWithGroup:groupId page:1 pageSize:20 callback:^(NSDictionary *result) {
            NSMutableArray *messages = [NSMutableArray new];
            for (NSDictionary *i in result[@"result"])
            {
                [messages addObject:[CKReceivedMessageModel modelWithDictionary:i]];
            }
            self.messages = messages;
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:CKMessageServerConnectionReceived object:nil];
    }
    return self;
}

- (void)messageReceived:(NSNotification *)notif
{
//    CKReceivedMessageModel *message = [CKReceivedMessageModel modelWithDictionary:notif.userInfo];
//    if (![message.fromUserID isEqualToString:_userId]) return;
//    self.messages = [self.messages arrayByAddingObject:message];
}

- (void)sendMessage:(NSString *)message
{
    [[CKMessageServerConnection sharedInstance] sendMessage:message toGroup:_groupId dialogType:_dialogType callback:^(NSDictionary *result) {
        CKReceivedMessageModel *message = [CKReceivedMessageModel modelWithDictionary:result[@"result"]];
        self.messages = [self.messages arrayByAddingObject:message];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
