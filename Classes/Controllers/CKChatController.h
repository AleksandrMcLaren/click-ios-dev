//
//  CKChatController.h
//  click
//
//  Created by Igor Tetyuev on 07.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKChatModel.h"
#import "CKMessagesListController.h"

@interface CKChatController : UIViewController

@property (nonatomic, strong) CKMessagesListController *messagesList;
@property (nonatomic, strong) CKChatModel *chat;

@end
