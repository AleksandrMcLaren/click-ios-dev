//
//  CKAttachMenu.h
//  click
//
//  Created by Igor Tetyuev on 09.06.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKAttachButton.h"

@interface CKAttachMenu : UIView

@property (nonatomic, strong) CKAttachButton *cameraButton;
@property (nonatomic, strong) CKAttachButton *photosButton;
@property (nonatomic, strong) CKAttachButton *recordingButton;
@property (nonatomic, strong) CKAttachButton *audioButton;
@property (nonatomic, strong) CKAttachButton *cloudButton;
@property (nonatomic, strong) CKAttachButton *locationButton;
@property (nonatomic, strong) CKAttachButton *contactButton;
@property (nonatomic, strong) CKAttachButton *hideButton;

@end
