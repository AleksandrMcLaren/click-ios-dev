//
//  CKDialogsModel.m
//  click
//
//  Created by Igor Tetyuev on 25.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKDialogsModel.h"
#import "CKMessageServerConnection.h"
#import "CKDialogChatController.h"

@implementation CKDialogModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dict
{
    CKDialogModel *model = [CKDialogModel new];
    
    model.userAvatarId = dict[@"avatar"];
    model.attachCount = [dict[@"cntattach"] integerValue];
    model.onlineUsersCount = [dict[@"cntonline"] integerValue];
    model.userCount = [dict[@"cnttotal"] integerValue];
    
    if ([((NSString *)dict[@"date"]) isEqualToString:@"0001-01-01T00:00:00"]) {
        model.date = nil;
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTF"];
        [dateFormatter setDateFormat:@"YYYY-MM-DDThh:mm:ss"];
        model.date = [dateFormatter dateFromString:dict[@"date"]];
    }
    
    model.dialogAvatarId = dict[@"dlgavatar"];
    model.dialogDescription = dict[@"dlgdesc"];
    model.dialogName = dict[@"dlgname"];
    model.dialogId = dict[@"entryid"];
    model.location = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lon"] doubleValue]);
    model.userLogin = dict[@"login"];
    model.message = dict[@"message"];
    model.messageId = dict[@"msgid"];
    model.messageStatus = [dict[@"msgstatus"] integerValue];
    model.messagesTotal = [dict[@"msgtotal"] integerValue];
    model.messageType = [dict[@"msgtype"] integerValue];
    model.messagesUnread = [dict[@"msgunread"] integerValue];
    model.userName = dict[@"name"];
    model.userSurname = dict[@"surname"];
    model.isOwner = [dict[@"owner"] integerValue];
    model.state = [dict[@"state"] integerValue];
    model.status = [dict[@"status"] integerValue];
    model.type = [dict[@"type"] integerValue];
    model.userId = [NSString stringWithFormat:@"%@", dict[@"userid"]];

    
    return model;
}

#pragma mark - Clear methods


+ (void)clearCounter:(NSString *)dialogId{
    [[CKDB sharedInstance].queue inDatabase:^(FMDatabase *db) {
        BOOL success =  [db executeUpdate:@"update dialogs set msgunread = 0 where entryid =?", dialogId];
        if (!success) {
            NSLog(@"%@", [db lastError]);
        }
    }];
}

+ (void)updateDialog:(NSString *)dialogId withMessage:(Message*)message{
    [[CKDB sharedInstance].queue inDatabase:^(FMDatabase *db) {
        BOOL success =  [db executeUpdate:@"update dialogs set message = ?, msgid = ?  where entryid =?", message.text, message.id ,dialogId];
        if (!success) {
            NSLog(@"%@", [db lastError]);
        }
    }];
}


@end

@interface CKDialogsModel()

@property (nonatomic, strong) NSArray *dialogs;

@end

@implementation CKDialogsModel

+ (instancetype)sharedInstance
{
    static CKDialogsModel *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [CKDialogsModel new];
    });
    
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _dialogsDidChanged = [RACObserve(self, dialogs) ignore:nil];
    }
    return self;
}

- (void)run
{
    _dialogs = [NSMutableArray new];
    [self loadDialogList];
    [self reloadDialogList];
}

- (void)reloadDialogList
{
    NSString *query = @"select * from dialogs";
    __block NSMutableArray *result = [NSMutableArray new];
    [[CKDB sharedInstance].queue inDatabase:^(FMDatabase *db) {
        FMResultSet *data = [db executeQuery:query];
        while ([data next])
        {
            NSDictionary* resultDictionary = [data resultDictionary];
            CKDialogModel *model = [CKDialogModel modelWithDictionary:[resultDictionary prepared]];
            [result addObject:model];
        }
    }];
    self.dialogs = result.copy;
}

-(void)loadDialogList{
    [[CKMessageServerConnection sharedInstance] getDialogListWithCallback:^(NSDictionary *result) {
        for (NSDictionary *i in result[@"result"]){
            [self saveDialog:i];
            if ( [i[@"type"] integerValue ] == 0) {
                [[Users sharedInstance] saveUserWithDialog:i];
            }
        }
        [self reloadDialogList];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)saveDialog:(NSDictionary*)dialog{
    [[CKDB sharedInstance] updateTable:@"dialogs" withValues:dialog];
}


@end
