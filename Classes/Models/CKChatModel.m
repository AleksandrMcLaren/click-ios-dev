//
//  CKChatModel.m
//  click
//
//  Created by Igor Tetyuev on 06.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKChatModel.h"
#import "AppDelegate.h"

@interface CKChatModel(){
    NSMutableArray* _messages;
    CKDialogModel* _dialog;
}
@end

@implementation CKChatModel

-(instancetype)init{
    if (self = [super init]) {
        _messages = [NSMutableArray new];
        _messagesDidChanged = [RACObserve(self, messages) ignore:nil];
    }
    return self;
}

- (instancetype)initWithDialog:(CKDialogModel*) dialog;
{
    if (self = [self init])
    {
        _dialog = dialog;
        self.attachements = @[];
        [self loadMessages];
    }
    return self;
}

//fetch from local
- (void)reloadMessages
{
    __block NSMutableArray *result = [NSMutableArray new];
    [[CKDB sharedInstance].queue inDatabase:^(FMDatabase *db) {
        FMResultSet *data = [db executeQuery:[self query]];
        while ([data next]){
            NSDictionary* resultDictionary = [data resultDictionary];
            Message *model = [Message modelWithDictionary:[resultDictionary prepared]];
            [result addObject:model];
        }
    }];
    [result sortUsingComparator:^NSComparisonResult(Message *obj1, Message *obj2) {
        return [obj1.date compare:obj2.date];
    }];
    self.messages = result.copy;
}

-(NSString*)identifier{
    return _dialog.dialogId;
}

-(NSArray*)messages{
    return _messages.copy;
}

-(void)addMessage:(Message*)message{
    [_messages addObject:message];
}

- (void)send:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio

{
    Message *message = [self newMessage];
    
    if (text != nil)	[self sendTextMessage:message Text:text];
    if (picture != nil)	[self sendPictureMessage:message Picture:picture];
    if (video != nil)	[self sendVideoMessage:message Video:video];
    if (audio != nil)	[self sendAudioMessage:message Audio:audio];
    if ((text == nil) && (picture == nil) && (video == nil) && (audio == nil)) [self sendLoactionMessage:message];
}


- (void)sendTextMessage:(Message *)message Text:(NSString *)text{
    message.message = text;
    [self sendMessage:message] ;
}


- (void)sendPictureMessage:(Message *)message Picture:(UIImage *)picture{
}


- (void)sendVideoMessage:(Message *)message Video:(NSURL *)video{
}


- (void)sendAudioMessage:(Message *)message Audio:(NSString *)audio{
}


- (void)sendLoactionMessage:(Message *)message
{
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    message.location = app.coordinate;
    message.message = @"[Location message]";
    message.type = CKMessageTypeNormal; 
    [self sendMessage:message];
}


- (void)messageReceived:(NSNotification *)notif{

}



-(void)clearCounter{
    [CKDialogModel clearCounter:_dialog.dialogId];
    [CKDialogModel updateDialog:_dialog.dialogId withMessage:[self.messages lastObject]];
}

- (BOOL)messageMatch:(Message*)message{
    if (message.dialogType == CKDialogTypeChat) {
        return [message.userid isEqualToString:self.dialog.userId];
    }else{
        return [_dialog.dialogId isEqualToString:message.entryid];
    }
    return NO;
}

//ovverite
-(Message*)newMessage{
    return nil;
}

//ovverite
-(NSString*)query{
    NSString *query = [NSString stringWithFormat:@"select * from messages where id in (select messageId from dialogs_messages where dialogId = '%@')", _dialog.dialogidentifier];
    return query;
}

//fetch from server
-(void)loadMessages{
}

- (void)sendMessage:(Message *)message{
    [message save];
    [self reloadMessages];
}

-(void)recivedMesagesArray:(NSArray*)messages{
    for (NSDictionary *diactionary in messages){
        Message* message = [Message modelWithDictionary:diactionary];
        [self saveMessage:message];
    }
    [self reloadMessages];
}

-(void)saveMessage:(Message*)message{
    [message save];
}
@end

