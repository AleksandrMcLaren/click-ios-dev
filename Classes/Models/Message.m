//
//  Message
//  click
//
//  Created by Дрягин Павел on 26.11.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "Message.h"
#import "CKMessageServerConnection.h"
#import "CKUser.h"
#import "Users.h"
#import "CKUser+Util.h"
#import "utilities.h"

@implementation Message

-(CKUser*)sender{
    CKUser* sender =  [[Users sharedInstance] userWithId:self.userid];
    return sender;
}

-(NSString*)senderName{
    return self.sender.name;
}

- (NSString *)senderLogin
{
    return self.sender.login;
}

-(NSString*)senderInitials{
    return self.sender.initials;
}

-(NSString*)statusName{
    return NSStringFromCKMessageStatus(self.status);
}

-(NSString*)text{
    return self.message;
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dict
{
    Message *model = [Message fromCacheWithId:dict[@"id"]];
    if (model) {
        return model;
    }
    
    model = [Message new];
    [model updateWithDictionary:dict];
    [CKMessageServerConnection sharedInstance].messageModelCache[model.id] = model;
    
    return model;
}

+ (instancetype)fromCacheWithId:(NSString *)ident
{
    return [CKMessageServerConnection sharedInstance].messageModelCache[ident];
}

- (void)updateWithDictionary:(NSDictionary *)dict
{
    self.isOwner = [dict[@"owner"] boolValue];
    self.message = dict[@"message"];
    self.id = dict[@"id"];
    self.status = [dict[@"status"] integerValue];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSZZZZZ"]; //2016-11-22T13:42:38.46505+00:00
    NSString* date = dict[@"date"];
    NSDate* dt = [dateFormatter dateFromString:date];
    self.date = dt;
    
    self.userid = [NSString stringWithFormat:@"%@", dict[@"userid"]];
    self.userlogin = [NSString stringWithFormat:@"%@", dict[@"userlogin"]];
    self.useravatar = [NSString stringWithFormat:@"%@", dict[@"useravatar"]];
    
    NSMutableArray *attachements = [NSMutableArray new];
    
    id attach = dict[@"attach"];
    NSArray* attachments;
    if ([attach isKindOfClass:[NSArray class]]) {
        attachments = (NSArray*)attach;
    }
    if ([attach isKindOfClass:[NSString class]]) {
        NSData *JSONData = [attach dataUsingEncoding:NSUTF8StringEncoding];
        
        attachments = [NSJSONSerialization JSONObjectWithData:JSONData
                                                      options:kNilOptions
                                                        error:nil];
    }
    if (attachments){
        for (NSDictionary *i in attachments){
            CKAttachModel *attach = [CKAttachModel modelWithDictionary:i];
            [attachements addObject:attach];
            if (attach.preview) {
                self.attachPreviewCounter++;
            }
        }
    }
    if (dict[@"entryid"]) {
        self.entryid = dict[@"entryid"];
    }
    if (dict[@"dialogtype"]) {
        self.dialogType = (CKDialogType)[dict[@"dialogtype"] integerValue];
    }
    
    self.attachements = attachements;
    self.timer = [dict[@"timer"] integerValue];
    self.location = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lng"] doubleValue]);
}

- (void)setAttachements:(NSArray *)attachements {
//    [super setAttachements:attachements];
    for (CKAttachModel *attach in attachements) {
        @weakify(self);
        [[RACObserve(attach, preview) skip:1] subscribeNext:^(id x) {
            @strongify(self);
            self.attachPreviewCounter++;
        }];
    }
}

+ (void)updateIncoming:(NSString *)messageId{
    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
}

+ (void)updateStatusWithDictionary:(NSDictionary *)dict
{
    NSDictionary *result = dict[@"result"];
    NSString *ident = result[@"id"];
    NSString *query = [NSString stringWithFormat:@"select * from messages where id='%@'", ident];
    __block Message *message = nil;
    
    [[CKDB sharedInstance].queue inDatabase:^(FMDatabase *db) {
        FMResultSet *data = [db executeQuery:query];
        while ([data next]){
            NSDictionary *resultDictionary = [data resultDictionary];
            
            if(resultDictionary)
                message = [Message modelWithDictionary:[resultDictionary prepared]];
        }
    }];
    
    if(message)
    {
        message.status = [result[@"status"] integerValue];
        [message save];

        if(message.isOwner)
        {
            if(message.updatedStatus)
                message.updatedStatus();
        }
    }
}

+ (void)deleteItem:(NSString *)groupId messageId:(NSString *)messageId
{
    //	FIRDatabaseReference *firebase = [[[[FIRDatabase database] referenceWithPath:FMESSAGE_PATH] child:groupId] child:messageId];
    //	[firebase updateChildValues:@{FMESSAGE_ISDELETED:@YES}];
}

+ (void)deleteItem:(Message *)dbmessage

{
    //	if ([dbmessage.status isEqualToString:TEXT_QUEUED])
    //	{
    //		RLMRealm *realm = [RLMRealm defaultRealm];
    //		[realm beginWriteTransaction];
    //		[realm deleteObject:dbmessage];
    //		[realm commitWriteTransaction];
    //		[NotificationCenter post:NOTIFICATION_REFRESH_MESSAGES1];
    //	}
    //	else [self deleteItem:dbmessage.groupId messageId:dbmessage.objectId];
}

-(void)updateWithSender:(CKUser *)user{
    self.userlogin = user.login;
    self.userid = user.objectId;
}

-(void)updateWithMessage:(Message *)message{
    if (![self.id isEqualToString:message.id]) {
        [Message updateId:self.id withId:message.id];
    }
    self.isOwner = message.isOwner;
    self.message = message.message;
    
    self.id = message.id;
    self.status = message.status;
    self.userid = message.userid;
    self.userlogin = message.userlogin;
    self.useravatar = message.useravatar;
    
    self.attachements = message.attachements;
    self.timer = message.timer;
    self.location = message.location;

    self.date = message.date;
}

- (void)save{
    NSMutableDictionary* dictionary = [NSMutableDictionary new];
    dictionary[@"owner"] = @(self.isOwner);
    dictionary[@"message"] = self.message;
    dictionary[@"id"] = self.id;
    dictionary[@"status"] = @(self.status);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSZZZZZ"]; //2016-11-22T13:42:38.46505+00:00

    dictionary[@"date"] = [dateFormatter stringFromDate:self.date];
    dictionary[@"userid"] = self.userid ;
    dictionary[@"userlogin"] = self.userlogin;
    dictionary[@"useravatar"] = self.useravatar;
    
//    NSMutableArray *attachements = [NSMutableArray new];
    
//TODO сохранять аттачмент
    dictionary[@"attach"] = @"";
  
    dictionary[@"entryid"] = self.entryid;
    dictionary[@"dialogtype"] = @(self.dialogType);
    dictionary[@"timer"]  = @(self.timer);
    dictionary[@"lat"] = @(self.location.latitude);
    dictionary[@"lng"] = @(self.location.longitude);
    [Message update:dictionary];
    
    [Message saveLinkWithUserId:self.dialogIdentifier messageId:self.id];
}

-(NSString*)dialogIdentifier{
    if (_dialogIdentifier) {
        return _dialogIdentifier;
    }
    if (self.dialogType == CKDialogTypeChat) {
        return self.userid;
    }else{
        return _entryid;
    }
}

+(void)update:(NSDictionary *)dictionary{
    [[CKDB sharedInstance] updateTable:@"messages" withValues:dictionary];
}

+ (void)updateId:(NSString*)oldId withId:(NSString*)newId{
    CKDB *ckdb = [CKDB sharedInstance];
    
    [ckdb.queue inDatabase:^(FMDatabase *db) {
        NSString* sql = @"update messages set id = ? where id = ?";
        BOOL success = [db executeUpdate:sql withArgumentsInArray:@[newId, oldId]];
        if (!success) {
            NSLog(@"%@", [db lastError]);
        }
    }];
    
    [ckdb.queue inDatabase:^(FMDatabase *db) {
        NSString* sql = @"update dialogs_messages set messageId = ? where messageId = ?";
        BOOL success = [db executeUpdate:sql withArgumentsInArray:@[newId, oldId]];
        if (!success) {
            NSLog(@"%@", [db lastError]);
        }
    }];
}

+ (void)saveLinkWithUserId:(NSString*)userId messageId:(NSString*)messageId{
    CKDB *ckdb = [CKDB sharedInstance];
    
    [ckdb.queue inDatabase:^(FMDatabase *db) {
        NSString* sql = @"delete from dialogs_messages where dialogId = ? and messageId = ?";
        BOOL success = [db executeUpdate:sql withArgumentsInArray:@[userId, messageId]];
        if (!success) {
            NSLog(@"%@", [db lastError]);
        }
    }];
    
    [ckdb.queue inDatabase:^(FMDatabase *db) {
        NSString* sql = @"insert into dialogs_messages (dialogId, messageId) values (?, ?)";
        BOOL success = [db executeUpdate:sql withArgumentsInArray:@[userId, messageId]];
        if (!success) {
            NSLog(@"%@", [db lastError]);
        }
    }];
}
@end

#pragma mark MessageSent

@implementation MessageSent

-(instancetype)init{
    if (self = [super init]) {
        [self updateWithSender:[CKUser currentUser]];
        self.status = CKMessageStatusSent;
        self.date = [NSDate new];
        self.id = [[NSUUID UUID] UUIDString];
        self.useravatar = [CKUser currentUser].avatarName;
        self.userid = [CKUser currentUser].id;
        self.userlogin = [CKUser currentUser].login;
        self.isOwner = YES;
    }
    return self;
}

@end

#pragma mark MessageReceived

@implementation MessageReceived

@end

#pragma mark Other

NSString* NSStringFromCKMessageStatus(CKMessageStatus status){
    switch (status) {
        case CKMessageStatusSent:
            return @"Отправлено";
            break;
        case CKMessageStatusDelivered:
            return @"Доставлено";
        case CKMessageStatusRead:
            return @"Прочтено";
        default:
            return @"-";
            break;
    }
}


//attach =         (
//);
//date = "2016-12-06T15:37:12.255685+00:00";
//dialogstate = 0;
//dialogtype = 0;
//entryid = "00000000-0000-0000-0000-000000000000";
//id = "2557be28-9644-4e95-ad89-0adc808269eb";
//lat = 0;
//lng = 0;
//message = "\U042f 'M \U0438\U0437\U0432\U0438\U043d\U0438\U0442\U0435 ";
//owner = 0;
//status = 0;
//timer = 0;
//type = 0;
//useravatar = "";
//userid = 1000;
//userlist = "<null>";
//userlogin = click;
//username = "\U041d\U0438\U043a\U043e\U043b\U044c";
//userstatus = 1;
//usersurname = "";
//};
