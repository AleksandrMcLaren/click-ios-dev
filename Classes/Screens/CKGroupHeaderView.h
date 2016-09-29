//
//  CKGroupHeaderView.h
//  click
//
//  Created by Igor Tetyuev on 27.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKGroupHeaderView : UIView

@property (nonatomic, readonly) UITextField *name;
@property (nonatomic, readonly) UITextView *descriptionText;
@property (nonatomic, readonly) UIButton *avatar;

@end
