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

- (void)addMessages:(NSArray *)messages;
- (void)addMessage:(MLChatMessage *)message;

@end

