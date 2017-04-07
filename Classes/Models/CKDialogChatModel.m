//
//  CKDialogChatModel.m
//  click
//
//  Created by Igor Tetyuev on 07.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKDialogChatModel.h"
#import "CKAttachModel.h"
#import "utilities.h"

@interface CKDialogChatModel(){
    NSMutableArray* _messagesId;
}

@end

@implementation CKDialogChatModel

- (instancetype)initWithDialog:(CKDialogModel*) dialog{
    self = [super initWithDialog:dialog];
    if (self) {
        _userId = self.dialog.userId;
    }
    return self;
}

-(void)loadMessagesWithSuccess:(void (^)(NSArray *messages))success
{
    [[CKMessageServerConnection sharedInstance] getDialogWithUser:self.dialog.userId page:1 pageSize:INSERT_MESSAGES callback:^(NSDictionary *result) {
        
        [self recivedMesages:result[@"result"]
                     success:^(NSArray *messages) {
                         
                         if(success)
                             success(messages);
                     }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [CKDialogModel clearCounter:self.dialog];
            [self clearCounter:nil];
        });
    }];
}

-(void)loadMessagesWithPage:(NSInteger)page
                    success:(void (^)(NSArray *messages))success
{
    [[CKMessageServerConnection sharedInstance] getDialogWithUser:self.dialog.userId page:page pageSize:INSERT_MESSAGES callback:^(NSDictionary *result) {
        
        [self recivedMesages:result[@"result"]
                     success:^(NSArray *messages) {
                         
                         if(success)
                             success(messages);
                     }];
    }];
}

- (void)messageReceived:(NSNotification *)notif
{
    Message *message = [Message modelWithDictionary:notif.userInfo];
    if (![message.userid isEqualToString:_userId]) return;
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

- (void)sendMessage:(Message *)message
{
    [super sendMessage:message];

    [[CKMessageServerConnection sharedInstance] uploadAttachements:self.attachements completion:^(NSDictionary *result) {
        
        self.attachements = @[];
        [[CKMessageServerConnection sharedInstance] sendMessage:message.text
                                                   attachements:result[@"uuids"]
                                                         toUser:_userId
                                                       callback:^(NSDictionary *result) {
                                                           
                                                           if (result.socketMessageStatus == S_OK) {
                                                               NSDictionary* dictionary = result[@"result"];
                                                               Message *messageRecived = [Message modelWithDictionary:dictionary];
                                                               [message updateWithMessage:messageRecived];
                                                               [CKMessageServerConnection sharedInstance].messageModelCache[message.id] = message;
                                                               [message save];
                                                               
                                                               if(message.updatedIdentifier)
                                                                   message.updatedIdentifier();
    
                                                               [CKDialogModel updateDialog:self.dialog withMessage:message];
                                                               
                                                           }else{
                                                                [ProgressHUD showError:@"Message sending failed."];
                                                           }
        }];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(Message*)newMessage{
    Message *message = [MessageSent new];
    message.dialogType = CKDialogTypeChat;
    message.dialogIdentifier = self.dialog.userId;
    return message;
}

-(void)saveMessage:(Message*)message{
    message.dialogIdentifier = self.dialog.userId;
    [message save];
}

@end
