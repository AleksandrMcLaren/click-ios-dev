//
//  CKChatModel.h
//  click
//
//  Created by Igor Tetyuev on 06.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKDialogsModel.h"
#import "CKMessageServerConnection.h"

typedef void (^CKChatModelFetchedMessages)(NSArray* messages);

@interface CKChatModel : NSObject

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) Message *lastMessage;
@property (nonatomic, readonly) BOOL isReadonly;
@property (nonatomic, strong) NSArray *attachements;
@property (nonatomic, strong, readonly) NSString* identifier;
@property (nonatomic, strong, readonly) CKDialogModel* dialog;

@property (nonatomic, strong, readonly) RACSignal* messagesDidChanged;
@property (nonatomic, strong, readonly) RACSignal* messageDidChanged;

- (instancetype)initWithDialog:(CKDialogModel*) dialog;

- (void)send:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio;

- (NSArray *)getMessages;

- (void)loadMessages;

- (void)clearCounter;

- (BOOL)messageMatch:(Message*)message;

- (void)sendMessage:(Message *)message;

- (void)recivedMesagesArray:(NSArray*)messages;

@end
