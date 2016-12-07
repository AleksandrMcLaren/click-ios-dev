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

//- (instancetype)initWithUserId:(NSString *)userId;

- (void)sendMessage:(NSString *)message;
- (void)addAttachement:(CKAttachModel *)attach;
- (void)deleteAttachementAt:(NSInteger)pos;

@end
