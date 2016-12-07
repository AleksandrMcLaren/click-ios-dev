//
//  CKFriendProfileController.h
//  click
//
//  Created by Igor Tetyuev on 29.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "utilities.h"

@interface CKFriendProfileController : UITableViewController

- (instancetype)initWithUser:(CKUser *)user;
@property (nonatomic, assign) BOOL wentFromTheMap;

@end
