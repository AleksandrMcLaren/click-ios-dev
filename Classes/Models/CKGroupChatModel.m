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

@implementation CKGroupModel

- (void) initialize
{
    self.adminid = @"";
    self.avatar = @"";
    self.date = nil;
    self.groupDescription = @"";
    self.groupId = @"";
    self.issecret = false;
    self.name = @"";
    self.password = @"";
    self.userid = @"";
    self.userlist = nil;
}

+ (instancetype) modelWithDictionary:(NSDictionary *)sourceDict
{
    CKGroupModel *model = [CKGroupModel new];
    
    @try {
        model.adminid = [NSString stringWithFormat:@"%@", sourceDict[@"adminid"]];
        model.avatar = [NSString stringWithFormat:@"%@", sourceDict[@"avatar"]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss"];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTF"];
        
        model.date = [sourceDict[@"date"] isEqualToString:@"0001-01-01T00:00:00"] ? nil : [dateFormatter dateFromString:sourceDict[@"date"]];
        model.groupDescription = [NSString stringWithFormat:@"%@", sourceDict[@"description"]];
        model.groupId = [NSString stringWithFormat:@"%@", sourceDict[@"id"]];
        model.issecret = [sourceDict[@"issecret"] boolValue];
        model.name = [NSString stringWithFormat:@"%@", sourceDict[@"name"]];
        model.password = [NSString stringWithFormat:@"%@", sourceDict[@"password"]];
        model.userid = [NSString stringWithFormat:@"%@", sourceDict[@"userid"]];
        model.userlist = [NSArray arrayWithObjects: sourceDict[@"userlist"], nil];
    } @catch (NSException *exception) {
        return nil; // bad model
    }
    
    return model;
}

@end
