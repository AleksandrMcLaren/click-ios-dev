//
//  CKMessageServerConnection.m
//  click
//
//  Created by Igor Tetyuev on 26.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//
#import "utilities.h"
#import "CKMessageServerConnection.h"

@implementation CKUserFilterModel

- (instancetype)init
{
    if (self = [super init])
    {
        self.userlist = @[];
        self.mask = @"";
        self.sex = @"";
    }
    return self;
}


+ (CKUserFilterModel *)filterWithAllFriends
{
    CKUserFilterModel *filter = [CKUserFilterModel new];
    //filter.isFriend = YES
    filter.isFriend = 1;
    filter.status = -1;
    return filter;
}

+ (CKUserFilterModel *)filterWithLocation
{
    CKUserFilterModel *filter = [CKUserFilterModel new];
    filter.status = -1;
    filter.isFriend = -1;
    return filter;
}


- (NSDictionary *)getDictionary
{
    return @{@"userlist":self.userlist,
             @"status":@(self.status),
             @"locale":@"ru",
             @"isfriend":@((NSInteger)self.isFriend),
             @"country":@(self.country),
             @"city":@(self.city),
             @"sex":self.sex,
             @"minage":@(self.minAge),
             @"maxage":@(self.maxAge),
             @"mask":self.mask,
             @"lat1":@(self.area.center.latitude - self.area.span.latitudeDelta/2),
             @"lng1":@(self.area.center.longitude - self.area.span.longitudeDelta/2),
             @"lat2":@(self.area.center.latitude + self.area.span.latitudeDelta/2),
             @"lng2":@(self.area.center.longitude + self.area.span.longitudeDelta/2)};
}

@end

 @interface CKMessageServerConnection(){
    BOOL refreshUserInterface1;
    BOOL refreshUserInterface2;
    BOOL playMessageReceivedSound;
}

@end

@implementation CKMessageServerConnection

- (instancetype)init {
    if (self = [super init]) {
        self.messageModelCache = [NSMutableDictionary new];
        self.attachmentModelCache = [NSMutableDictionary new];
    }
    return self;
}

-(NSString*)entryPoint{
    return @"Message";
}

+ (instancetype)sharedInstance
{
    static CKMessageServerConnection *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [CKMessageServerConnection new];
    });
    
    return instance;
}

// xxx obsolete
- (void)getDialogListWithCallback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"dialog.list", @"options":@{@"locale":@"ru"}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)addFriends:(NSArray *)friendPhoneList callback:(CKServerConnectionExecutedStatus)callback
{
    [self sendData:@{@"action":@"user.addfriend", @"options":@{@"userlist":friendPhoneList}} completion:^(NSDictionary *result) {
        callback( (CKStatusCode) [result[@"status"] integerValue]);
    }];
}

- (void)getUserListWithFilter:(CKUserFilterModel *)model callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"user.list", @"options":[model getDictionary]} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)getDialogWithId:(NSString *)dialogId page:(NSInteger)page pageSize:(NSInteger)pageSize callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"dialog.message", @"options":@{@"userid":@(0), @"entryid":dialogId, @"page":@(page), @"size":@(pageSize), @"dialogtype":@1}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)getDialogWithUser:(NSString *)userId page:(NSInteger)page pageSize:(NSInteger)pageSize callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"dialog.message", @"options":@{@"userid":userId, @"entryid":@"00000000-0000-0000-0000-000000000000", @"page":@(page), @"size":@(pageSize), @"dialogtype":@0}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)getDialogWithGroup:(NSString *)groupId page:(NSInteger)page pageSize:(NSInteger)pageSize callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"groupchat.messagelist", @"options":@{@"id":groupId, @"page":@(page), @"size":@(pageSize)}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)sendMessage:(NSString *)message attachements:(NSArray *)attachements toUser:(NSString *)user callback:(CKServerConnectionExecuted)callback {
    [self sendData:@{@"action":@"dialog.send", @"options":@{@"userlist":@[user], @"entryid":@"00000000-0000-0000-0000-000000000000", @"message":message, @"type":@(0), @"dialogtype":@(0), @"attach":attachements?attachements:@[]}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)sendMessage:(NSString *)message toGroup:(NSString *)group dialogType:(CKDialogType)dialogType callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"groupchat.send", @"options":@{@"id":group, @"message":message, @"type":@(0), @"dialogtype":@(dialogType), @"attach":@[]}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)createGroupChatWithName:(NSString *)title avatar:(NSString *)avatar description:(NSString *)description users:(NSArray *)userlist callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"groupchat.create", @"options":@{@"name":title, @"description":description, @"avatar":avatar, @"userlist":userlist}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

//getUserClasters
- (void) getUserClasters: (NSNumber *)status withFriendStatus: (NSNumber *)isfriend withCountry: (NSNumber *)country withCity: (NSNumber *)city withSex: (NSString *)sex withMinage: (NSNumber *)minage andMaxAge: (NSNumber *)maxage withMask: (NSString *)mask withBottomLeftLatitude:(NSNumber *) bottomLeftLatitude withBottomLeftLongtitude: (NSNumber*) bottomLeftLongtitude withtopCoordinate: (NSNumber *)topRightLatitude withTopRigthLongtitude:(NSNumber *)topRightLongtitde withCallback: (CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"user.geocluster", @"options":@{@"status":[NSNumber numberWithInteger: [status integerValue]], @"isfriend":[NSNumber numberWithInteger:[isfriend integerValue]], @"country":[NSNumber numberWithInteger:[country integerValue]], @"city":[NSNumber numberWithInteger:[city integerValue]], @"sex":sex, @"minage":[NSNumber numberWithInteger:[minage integerValue]], @"maxage":[NSNumber numberWithInteger:[maxage integerValue] ],                                                                                                                                                                                 @"mask":mask, @"lat1": [NSNumber numberWithDouble: [bottomLeftLatitude doubleValue]],@"lng1":[NSNumber numberWithDouble:[bottomLeftLongtitude doubleValue]],@"lat2":[NSNumber numberWithDouble:[topRightLatitude doubleValue]],@"lng2":[NSNumber numberWithDouble:[topRightLongtitde doubleValue]],}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)uploadAttachements:(NSArray<CKAttachModel *>*)attachements completion:(CKServerConnectionExecuted)callback {
    NSMutableArray *userDataArr = [NSMutableArray new];
    NSMutableArray *uuids = [NSMutableArray new];
    for (CKAttachModel *i in attachements) {
        if (!i.contentType) continue;
        [userDataArr addObject:@{@"id":i.uuid, @"type":@(i.type), @"title":@"", @"description":@""}];
        [uuids addObject:i.uuid];
    }
    if (uuids.count == 0) {
        callback(nil);
        return;
    }
    //
    NSURL* url = [NSURL URLWithString:@"http://click.httpx.ru:8102/message/"];
    //
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    NSString* headerJson = [[NSString alloc] initWithData:
                            [NSJSONSerialization dataWithJSONObject:userDataArr
                                                            options:0
                                                              error:nil]
                                                 encoding:NSUTF8StringEncoding];
    [request setValue:headerJson forHTTPHeaderField:@"User-Data"];
    [request setHTTPMethod:@"POST"];

    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *fullContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:fullContentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"--%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    for (CKAttachModel *i in attachements) {
        NSString *blockheader = [NSString stringWithFormat:@"\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", i.filename, i.filename];
        [postbody appendData:[blockheader dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", i.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[NSData dataWithData:i.data]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    [postbody appendData:[@"--\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    NSString *s = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"postbody.bin"];
//    NSLog(@"%@", s);
//    [postbody writeToFile:s atomically:YES];
    [request setHTTPBody:postbody];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable err) {
        if(err) {
            NSLog(@"UPLOAD ERROR: %@", err.description);
            return;
        }
        if(data) {
            NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"RESPONSE: %@", response);
            callback(@{@"uuids":uuids});
        }
    }];
}

- (void)processIncomingEvent:(NSDictionary *)eventData
{
    if ([eventData[@"action"] isEqualToString:@"onmessage"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CKMessageServerConnectionReceived object:self userInfo:eventData[@"result"]];
        NSString *messageId = eventData[@"result"][@"id"];
        [Message updateIncoming:messageId];
    }
}

- (void)cleanallHistory:(CKServerConnectionExecuted)callback{
    [self sendData:@{@"action":@"user.cleanallhistory"} completion:^(NSDictionary *result) {
        callback(result);
    }];
}


/*
 [15.12.16, 21:32:13] Егоров Александр: если лист пустой для dialogtype=0 установятся статусы для всех сообщений
 [15.12.16, 21:32:21] Егоров Александр: dialogtype обязательно передавать надо
 [15.12.16, 21:32:28] Егоров Александр: и entryid еще
 [15.12.16, 21:32:37] Егоров Александр: вроде иил нет не помню
 [15.12.16, 21:32:43] Егоров Александр: вроде нет... не надо
 а это не тестили еще, седни только попросили сделать
 */
//- (void)setMessagesStatus:(CKMessageStatus)status dialogtype:(NSInteger*)dialogtype enteryId:(NSString*) callback:(CKServerConnectionExecuted)callback
//{
//    [self sendData:@{@"action":@"dialog.setstatus", @"options":@{@"list":messagesIdents, @"status":@(status)}} completion:^(NSDictionary *result) {
//        callback(result);
//    }];
//}

- (void)setMessagesStatus:(CKMessageStatus)status messagesIdents:(NSArray *)messagesIdents callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"dialog.setstatus", @"options":@{@"list":messagesIdents, @"status":@(status)}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)clearhistory:(CKDialogModel*)dialog callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"dialog.clearhistory", @"options":@{@"dialogtype":@(dialog.type), @"entryid": dialog.dialogId, @"userid":dialog.userId}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

#pragma mark - Notification methods


- (void)refreshUserInterface

{
    if (refreshUserInterface1)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NotificationCenter post:NOTIFICATION_REFRESH_MESSAGES1];
            refreshUserInterface1 = NO;
        });
    }
    
    if (refreshUserInterface2)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NotificationCenter post:NOTIFICATION_REFRESH_MESSAGES2];
            refreshUserInterface2 = NO;
        });
    }
    
    if (playMessageReceivedSound)
    {
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        playMessageReceivedSound = NO;
    }
}




@end
