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

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)blueCircle;
+ (UIImage *)purpleCircle;
+ (UIImage *)greyCircle;
+ (UIImage* )drawText:(NSString*) text inImage:(UIImage*) image atPoint:(CGPoint) point;
+ (UIImage *)bluePinforClusters;
+ (UIImage *)imageWithPurpleBorderAndRoundCornersWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius;
+ (UIImage *)imageWithGrayBorderAndRoundCornersWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius;
+ (UIImage *)imageWithBlueBorderAndRoundCornersWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius;

@property (nonatomic, strong) CKUserModel *user;

@end
