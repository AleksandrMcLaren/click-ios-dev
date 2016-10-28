//
//  CKActivityViewController.h
//  click
//
//  Created by Дрягин Павел on 24.10.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKOperationsProtocol.h"

@interface CKActivityViewController : UIViewController<CKOperationsProtocol, CKViewControllerRotation>

@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) UIButton* continueButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

-(void)viewTapped;

@end
