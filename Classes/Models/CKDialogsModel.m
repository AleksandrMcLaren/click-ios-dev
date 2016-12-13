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
//        [dateFormatter setDateFormat:@"YYYY-MM-DDThh:mm:ss"];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSZZZZZ"];
        model.date = [dateFormatter dateFromString:dict[@"date"]];
    }
    
    model.dialogAvatarId = dict[@"dlgavatar"];
    model.dialogDescription = dict[@"dlgdesc"];
    model.dialogName = dict[@"dlgname"];
    model.dialogId = dict[@"entryid"];
    model.location = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lon"] doubleValue]);
    model.userLogin = dict[@"login"];
    model.message =  [NSString stringWithFormat:@"%@", dict[@"message"] ];
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

-(instancetype)initWithUser:(CKUser*)user{
    if (self = [self init]) {
        self.userAvatarId = user.avatarName;
        self.attachCount = 0;
        self.onlineUsersCount = 0;
        self.userCount = 1;
        self.date = [NSDate new];
        self.dialogAvatarId = user.avatarName;
        self.dialogDescription = @"";
        self.dialogName = user.login;
        self.dialogId = @"";
        self.userLogin = user.login;
        self.message =  @"";
        self.messageId = @"";
        self.messageStatus = 0;
        self.messagesTotal = 0;
        self.messageType = 0;
        self.messagesUnread = 0;
        self.userName = user.name;
        self.userSurname = user.surname;
        self.isOwner = NO;
        self.state = 0;
        self.status = 0;
        self.type = CKDialogTypeChat;
        self.userId = user.id;
    }
    return self;
}

#pragma mark - Clear methods


+ (void)clearCounter:(CKDialogModel *)dialog{
    dialog.messagesUnread = 0;
    [[CKDB sharedInstance].queue inDatabase:^(FMDatabase *db) {
        BOOL success =  [db executeUpdate:@"update dialogs set msgunread = 0 where entryid =?", dialog.dialogId];
        if (!success) {
            NSLog(@"%@", [db lastError]);
        }
    }];
}

+ (void)updateDialog:(CKDialogModel *)dialog withMessage:(Message*)message{
    if (message) {
        dialog.messageStatus = message.status;
        dialog.messageType = message.type;
        dialog.message = message.message;
        dialog.messageId = message.id;
        dialog.date = message.date;
        
        [[CKDB sharedInstance].queue inDatabase:^(FMDatabase *db) {
            BOOL success =  [db executeUpdate:@"update dialogs set message = ?, msgid = ?, date = ?, msgstatus =?, msgtype = ? where entryid =?",
                             message.text,
                             message.id ,
                             [NSDate stringWithDate:  message.date],
                             @(message.status),
                             @(message.type),
                             dialog.dialogId];
            if (!success) {
                NSLog(@"%@", [db lastError]);
            }
        }];
    }
    
}

-(NSString*)dialogidentifier{
    if (self.type == CKDialogTypeChat) {
        return _userId;
    }
    return _dialogId;
}

-(void)save{
//    NSMutableDictionary* dictionary = [NSMutableDictionary new];
//    [dictionary setObject:self.userAvatarId forKey:@"avatar"];
//    [dictionary setObject:self.attachCount forKey:@"cntattach"];
//    [dictionary setObject:self.onlineUsersCount forKey:@"cntonline"];
//    [dictionary setObject:self.userCount forKey:@"cnttotal"];
//    [dictionary setObject:[NSDate stringWithDate:self.date] forKey:@"date"];
//    [dictionary setObject:self.dialogAvatarId forKey:@"dlgavatar"];
//    [dictionary setObject:self.dialogDescription forKey:@"dlgdesc"];
//    [dictionary setObject:self.dialogName forKey:@"dlgname"];
//    [dictionary setObject:self.dialogName forKey:@"dlgname"];
//    [dictionary setObject:self.dialogId forKey:@"entryid"];
//    [dictionary setObject:self.location.latitude forKey:@"lat"];
//    [dictionary setObject:self.location.longitude forKey:@"lon"];
//    [dictionary setObject:self.message forKey:@"message"];
//    [dictionary setObject:self.messageId forKey:@"msgid"];
//    [dictionary setObject:self.messageStatus forKey:@"msgstatus"];
//    [dictionary setObject:self.messagesTotal forKey:@"msgtotal"];
//    [dictionary setObject:self.messageType forKey:@"msgtype"];
//    [dictionary setObject:self.messagesUnread forKey:@"msgunread"];
//    [dictionary setObject:self.userName forKey:@"name"];
//    [dictionary setObject:self.userSurname forKey:@"surname"];
//    [dictionary setObject:self.isOwner forKey:@"owner"];
//    [dictionary setObject:self.state forKey:@"state"];
//    [dictionary setObject:self.status forKey:@"status"];
//    [dictionary setObject:self.type forKey:@"type"];
//    [dictionary setObject:self.userId forKey:@"userid"];
}

-(void)delete{
    
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
    NSString *query = @"select * from dialogs where isDeleted = 0";
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
        if ([result socketMessageStatus] == S_OK) {
            [self saveDialogsWithDictionary:result];
        }
    }];
}

-(void)saveDialogsWithDictionary:(NSDictionary*)result{
    [self delete];
    for (NSDictionary *i in result[@"result"]){
        [self saveDialog:i];
        if ( [i[@"type"] integerValue ] == 0) {
            [[Users sharedInstance] saveUserWithDialog:i];
        }
    }
    [self reloadDialogList];

}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)saveDialog:(NSDictionary*)dialog{
    NSMutableDictionary* dictionary = dialog.mutableCopy;
    [dictionary setObject:@"0" forKey:@"isDeleted"];
    [[CKDB sharedInstance] updateTable:@"dialogs" withValues:dictionary];
}

- (CKDialogModel*)getWithUser:(CKUser*)user{
    CKDialogModel* result = nil;
    for (CKDialogModel* model in self.dialogs) {
        if ((model.type == CKDialogTypeChat) && ([model.userId isEqualToString:user.id])) {
            result = model;
        }
    }
    if (!result) {
        result = [[CKDialogModel alloc] initWithUser:user];
        self.dialogs = [self.dialogs arrayByAddingObject:result];
    }
    return result;
}

- (void)deleteDialog:(CKDialogModel*)dialog{
    [[CKMessageServerConnection sharedInstance] cleanallHistory:^(NSDictionary *result) {
         [self loadDialogList];
    }];
}

-(void)delete{
    [[CKDB sharedInstance].queue inDatabase:^(FMDatabase *db) {
        BOOL success =  [db executeUpdate:@"update dialogs set isDeleted = 1"];
        if (!success) {
            NSLog(@"%@", [db lastError]);
        }
    }];
}

@end
