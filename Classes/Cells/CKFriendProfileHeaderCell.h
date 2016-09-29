//
//  CKFriendProfileHeaderCell.h
//  click
//
//  Created by Igor Tetyuev on 29.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKUserAvatarView.h"

@interface CKFriendProfileHeaderCell : UITableViewCell

@property (nonatomic, readonly) CKUserAvatarView *avatar;
@property (nonatomic, readonly) UILabel *name;
@property (nonatomic, readonly) UILabel *status;
@property (nonatomic, readonly) UIButton *likes;
@property (nonatomic, readonly) UILabel *login;
@property (nonatomic, readonly) UIButton *openChat;

- (void) setNumberOfLikes:(NSInteger)likes;
- (void) setUserStatus:(NSString *)status showCalendar:(BOOL)showCalendar;

@property (nonatomic, strong) CKUserModel *friend;

@end
