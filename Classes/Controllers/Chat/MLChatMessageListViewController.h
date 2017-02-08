//
//  MLChatMessageListViewController.h
//  click
//
//  Created by Aleksandr on 02/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLChatCellContentViewController.h"

@interface MLChatMessageListViewController : UITableViewController

@property (nonatomic, assign) CGFloat contentOffSet;
@property (nonatomic, assign, readonly) CGFloat contentMaxOrdinateOffSet;

- (void)addMessages:(NSArray *)messages;
- (void)addMessage:(MLChatMessageModel *)message;

@end

