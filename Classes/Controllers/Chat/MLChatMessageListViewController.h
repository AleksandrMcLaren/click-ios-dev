//
//  MLChatMessageListViewController.h
//  click
//
//  Created by Aleksandr on 02/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLChatCellContentViewController.h"

@protocol MLChatMessageListViewControllerDelegate;

@interface MLChatMessageListViewController : UITableViewController

@property (nonatomic, weak) id <MLChatMessageListViewControllerDelegate> delegate;
@property (nonatomic, assign) CGFloat contentOffSet;
@property (nonatomic, assign) CGFloat contentInsetBottom;

- (void)reloadMessages:(NSArray *)messages animated:(BOOL)animated;
- (void)addMessage:(MLChatMessage *)message;

- (void)beginRefreshing;
- (void)endRefreshing;

@end


@protocol MLChatMessageListViewControllerDelegate <NSObject>

@required
- (void)chatMessageListViewControllerTapped;
- (void)chatMessageListViewControllerNeedsReloadData;

@end

