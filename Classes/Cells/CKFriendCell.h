//
//  CKFriendCell.h
//  click
//
//  Created by Igor Tetyuev on 10.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKUserAvatarView.h"
#import "SWTableViewCell.h"

@interface CKFriendCell : SWTableViewCell

@property (nonatomic, readonly) CKUserAvatarView *avatar;
@property (nonatomic, readonly) UILabel *name;
@property (nonatomic, readonly) UILabel *login;
@property (nonatomic, assign) BOOL isLast;
@property (nonatomic, strong) CKUser *friend;
@property (nonatomic, assign) BOOL isSelectable;
@property (nonatomic, assign) BOOL isSelected;


@end
