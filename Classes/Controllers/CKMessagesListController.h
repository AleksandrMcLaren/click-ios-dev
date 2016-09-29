//
//  CKMessagesListController.h
//  click
//
//  Created by Igor Tetyuev on 07.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKChatModel.h"
#import "CKMessageCell.h"

#define CKMessagesTableViewResignKeyboard @"CKMessagesTableViewResignKeyboard"

@interface CKMessagesTableView : UITableView<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL disableStickyBottom;
@property (nonatomic, assign) BOOL isManualScrollingEnabled;

- (void) scrollToBottom;
- (void) setMyContentInset:(UIEdgeInsets)contentInset;

@end

@interface CKMessagesListController : UITableViewController<CKMessageCellDelegate>

@property (nonatomic, strong) NSArray *messages;
- (void)scrollToLastMessage;

@end
