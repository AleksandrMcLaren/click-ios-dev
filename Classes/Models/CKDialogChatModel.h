//
//  CKDialogChatModel.h
//  click
//
//  Created by Igor Tetyuev on 07.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKChatModel.h"
#import "CKAttachModel.h"

@interface CKDialogChatModel : CKChatModel

@property (nonatomic, readonly) NSString *userId;
@property (nonatomic, readonly) NSString *dialogId;

- (instancetype)initWithDialogId:(NSString *)dialogId;
- (instancetype)initWithUserId:(NSString *)userId;

- (void)sendMessage:(NSString *)message;

@property (nonatomic, strong) NSArray *attachements;

- (void)addAttachement:(CKAttachModel *)attach;
- (void)deleteAttachementAt:(NSInteger)pos;

@end
