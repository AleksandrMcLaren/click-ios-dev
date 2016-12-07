//
//  CKChatModel.h
//  click
//
//  Created by Igor Tetyuev on 06.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKDialogsModel.h"

@interface CKChatModel : NSObject

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, readonly) BOOL isReadonly;
@property (nonatomic, strong) NSArray *attachements;
@property (nonatomic, strong, readonly) NSString* dialogId;
@property (nonatomic, strong, readonly) CKDialogModel* dialog;


@property (nonatomic, strong, readonly) RACSignal* messagesDidChanged;

- (instancetype)initWithDialog:(CKDialogModel*) dialog;

- (void)send:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio;

//inherited
- (void)saveMessage:(NSDictionary*)message;
//ovverite
- (void)reloadMessages;

- (void)loadMessages;

- (void)clearCounter;

- (BOOL)messageMatch:(Message*)message;
@end
