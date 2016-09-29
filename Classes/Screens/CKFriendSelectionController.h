//
//  CKFriendSelectionController.h
//  click
//
//  Created by Igor Tetyuev on 20.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKFriendsSelectionDelegate <NSObject>

@optional
- (void) didSelectFriends:(NSSet *)friends;
- (void) didSelectFriend: (CKUserModel *)friend;

@end

@interface CKFriendSelectionController : UITableViewController

- (instancetype)initWithExcludedFriends:(NSArray *)excludeList;
@property (nonatomic, assign) BOOL multiselect;
@property (nonatomic, assign) id<CKFriendsSelectionDelegate> delegate;

@end
