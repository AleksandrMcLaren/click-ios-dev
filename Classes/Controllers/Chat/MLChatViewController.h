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

- (void)addMessages:(NSArray <MLChatMessage *> *)messages;
- (void)addMessage:(MLChatMessage *)message;

@property (copy) void (^sendMessage)(NSString *text);

@end
