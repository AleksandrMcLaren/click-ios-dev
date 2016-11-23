//
//  CKFriendProfileController.h
//  click
//
//  Created by Igor Tetyuev on 29.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Contacts;
@import ContactsUI;

@interface CKFriendProfileController : UITableViewController<CNContactViewControllerDelegate>

- (instancetype)initWithUser:(CKUserModel *)user;
@property (nonatomic, assign) BOOL wentFromTheMap;
@property (nonatomic, strong) CKUserModel* user;
@property (nonatomic, assign) BOOL fromProfile;


@end
