//
//  CKDialogChatModel.m
//  click
//
//  Created by Igor Tetyuev on 07.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKDialogChatModel.h"
#import "CKMessageServerConnection.h"
#import "CKAttachModel.h"

@interface CKDialogChatModel()

@end

@implementation CKDialogChatModel

- (instancetype)initWithDialogId:(NSString *)dialogId;
{
    if (self = [super init])
    {
        _dialogId = dialogId;
        self.attachements = @[];
        [[CKMessageServerConnection sharedInstance] getDialogWithId:dialogId page:1 pageSize:20 callback:^(NSDictionary *result) {
            NSMutableArray *messages = [NSMutableArray new];
            for (NSDictionary *i in result[@"result"])
            {
                [messages addObject:[CKReceivedMessageModel modelWithDictionary:i]];
            }
            [messages sortUsingComparator:^NSComparisonResult(CKReceivedMessageModel *obj1, CKReceivedMessageModel *obj2) {
                return [obj1.date compare:obj2.date];
            }];
            self.messages = messages;
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:CKMessageServerConnectionReceived object:nil];
    }
    return self;
}

- (instancetype)initWithUserId:(NSString *)userId;
{
    if (self = [super init])
    {
        _userId = userId;
        _attachements = [NSMutableArray new];
        [[CKMessageServerConnection sharedInstance] getDialogWithUser:userId page:1 pageSize:20 callback:^(NSDictionary *result) {
            NSMutableArray *messages = [NSMutableArray new];
            for (NSDictionary *i in result[@"result"])
            {
                [messages addObject:[CKReceivedMessageModel modelWithDictionary:i]];
            }
            [messages sortUsingComparator:^NSComparisonResult(CKReceivedMessageModel *obj1, CKReceivedMessageModel *obj2) {
                return [obj1.date compare:obj2.date];
            }];
            self.messages = messages;
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:CKMessageServerConnectionReceived object:nil];
    }
    return self;
}

- (void)messageReceived:(NSNotification *)notif
{
    CKReceivedMessageModel *message = [CKReceivedMessageModel modelWithDictionary:notif.userInfo];
    if (![message.fromUserID isEqualToString:_userId]) return;
    self.messages = [self.messages arrayByAddingObject:message];
}

- (void)addAttachement:(CKAttachModel *)attach {
    self.attachements = [self.attachements arrayByAddingObject:attach];
}

- (void)deleteAttachementAt:(NSInteger)pos {
    NSMutableArray *arr = self.attachements.mutableCopy;
    [arr removeObjectAtIndex:pos];
    self.attachements = arr;
}


- (void)sendMessage:(NSString *)message
{
    [[CKMessageServerConnection sharedInstance] uploadAttachements:_attachements completion:^(NSDictionary *result) {
        self.attachements = @[];
        [[CKMessageServerConnection sharedInstance] sendMessage:message
                                                   attachements:result[@"uuids"]
                                                         toUser:_userId
                                                       callback:^(NSDictionary *result) {
            CKReceivedMessageModel *message = [CKReceivedMessageModel modelWithDictionary:result[@"result"]];
            self.messages = [self.messages arrayByAddingObject:message];
        }];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
