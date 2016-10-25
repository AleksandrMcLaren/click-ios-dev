//
//  CKUserProfileController.h
//  click
//
//  Created by Igor Tetyuev on 19.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKActivityViewController.h"

@interface CKUserProfileController : CKActivityViewController

@property (nonatomic, strong) CKUserModel *profile;

@end
