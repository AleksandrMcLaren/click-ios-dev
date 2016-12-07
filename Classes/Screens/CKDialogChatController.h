//
//  CKDialogChatController.h
//  click
//
//  Created by Igor Tetyuev on 07.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKChatController.h"
#import "CKPictureCaptureManager.h"

@interface CKDialogChatController : CKChatController

- (instancetype)initWithDialogId:(NSString *)dialogId;
- (instancetype)initWithUserId:(NSString *)userId;

@property (nonatomic, strong) CKUser *user;
@property (nonatomic, assign) BOOL wentFromTheMap;

@end
