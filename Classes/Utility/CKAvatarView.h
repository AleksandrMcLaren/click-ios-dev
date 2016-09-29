//
//  CKAvatarView.h
//  click
//
//  Created by Igor Tetyuev on 01.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKAvatarView : UIView

- (void)setAvatarFile:(NSString *)filename fallbackName:(NSString *)fallbackName;

@property (nonatomic, strong) UIColor *fallbackColor;

@end
