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
    Message *model = [CKMessageServerConnection sharedInstance].messageModelCache[dict[@"id"]];
    if (model) {
        return model;
    }
    
    model = [Message new];
    model.isOwner = [dict[@"owner"] boolValue];
    model.message = dict[@"message"];
    model.id = dict[@"id"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSZZZZZ"]; //2016-11-22T13:42:38.46505+00:00
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTF"];
    
    NSString* date = dict[@"date"];
    NSDate* dt = [dateFormatter dateFromString:date];
    model.date = dt;
    
    model.userid = [NSString stringWithFormat:@"%@", dict[@"userid"]];
    model.userlogin = [NSString stringWithFormat:@"%@", dict[@"userlogin"]];
    
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
                model.attachPreviewCounter++;
            }
        }
    }
    if (dict[@"entryid"]) {
        model.entryid = dict[@"entryid"];
    }
    if (dict[@"dialogtype"]) {
        model.dialogType = (CKDialogType)[dict[@"dialogtype"] integerValue];
    }
  
    model.attachements = attachements;
    model.timer = [dict[@"timer"] integerValue];
    model.location = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lng"] doubleValue]);
    [CKMessageServerConnection sharedInstance].messageModelCache[model.id] = model;
    return model;
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
    
//    [Message updateStatus:@"-" messageId:messageId];
}

+ (void)updateStatus:(NSString *)groupId messageId:(NSString *)messageId
{
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
    self.date = message.date;
    self.userid = message.userid;
    self.userlogin = message.userlogin;
    
    self.attachements = message.attachements;
    self.timer = message.timer;
    self.location = message.location;
}

- (void)save{
    NSMutableDictionary* dictionary = [NSMutableDictionary new];
    dictionary[@"owner"] = @(self.isOwner);
    dictionary[@"message"] = self.message;
    dictionary[@"id"] = self.id;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSZZZZZ"]; //2016-11-22T13:42:38.46505+00:00
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTF"];
    
    dictionary[@"date"] = [dateFormatter stringFromDate:self.date];
    dictionary[@"userid"] = self.userid ;
    dictionary[@"userlogin"] = self.userlogin;
    
    NSMutableArray *attachements = [NSMutableArray new];
    
//TODO сохранять аттачмент
    dictionary[@"attach"] = @"";
  
    dictionary[@"entryid"] = self.entryid;
    dictionary[@"dialogtype"] = @(self.dialogType);
    dictionary[@"timer"]  = @(self.timer);
    dictionary[@"lat"] = @(self.location.latitude);
    dictionary[@"lng"] = @(self.location.longitude);
    [Message update:dictionary];
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
        self.userid = [CKUser currentUser].id;
        self.userlogin = [CKUser currentUser].login;
        
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
