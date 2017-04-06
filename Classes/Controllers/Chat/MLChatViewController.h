//
//  MLChatViewController.h
//  click
//
//  Created by Aleksandr on 02/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLChatMessage.h"

@interface MLChatViewController : UIViewController

- (id)init;

- (void)reloadMessages:(NSArray <MLChatMessage *> *)messages animated:(BOOL)animated;
- (void)insertTopMessages:(NSArray *)messages;
- (void)addMessage:(MLChatMessage *)message;

- (void)beginRefreshing;
- (void)endRefreshing;

@property (copy) void (^sendMessage)(NSString *text);
@property (copy) void (^reloadMessages)();

@end
