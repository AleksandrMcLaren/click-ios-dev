//
//  CKUserProfileController.h
//  click
//
//  Created by Igor Tetyuev on 19.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKActivityViewController.h"
#import "utilities.h"

@interface CKUserProfileController : CKActivityViewController

@property (nonatomic, strong) CKUser *profile;
@property (nonatomic, assign) BOOL restoreProfile;

@end
