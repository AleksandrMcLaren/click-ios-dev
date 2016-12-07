//
//  CKFriendSelectionController.h
//  click
//
//  Created by Igor Tetyuev on 20.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "utilities.h"

@protocol CKFriendsSelectionDelegate <NSObject>

@optional
- (void) didSelectFriends:(NSSet *)friends;
- (void) didSelectFriend: (CKUser *)friend;

@end

@interface CKFriendSelectionController : UITableViewController

- (instancetype)initWithExcludedFriends:(NSArray *)excludeList;
@property (nonatomic, assign) BOOL multiselect;
@property (nonatomic, assign) id<CKFriendsSelectionDelegate> delegate;

@end
