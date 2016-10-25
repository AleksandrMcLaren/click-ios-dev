//
//  CKActivityViewController.h
//  click
//
//  Created by Дрягин Павел on 24.10.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKOperationsProtocol.h"

@interface CKActivityViewController : UIViewController<CKOperationsProtocol>

@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) UIButton* continueButton;

@end
