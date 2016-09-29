//
//  CKUserAvatarView.h
//  click
//
//  Created by Igor Tetyuev on 01.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKAvatarView.h"

@interface CKUserAvatarView : CKAvatarView

- (instancetype)initWithUser:(CKUserModel *)user;

@property (nonatomic, strong) CKUserModel *user;

@end
