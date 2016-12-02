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
+ (UIImage *)bluePinforClusters;
+ (UIImage *)imageWithPurpleBorderAndRoundCornersWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius;
+ (UIImage *)imageWithGrayBorderAndRoundCornersWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius;
+ (UIImage *)imageWithBlueBorderAndRoundCornersWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius;
+ (UIColor *) getColorForAvatar: (NSString *) name;
+ (UIImage*) blankImageWithSize:(CGSize)size color:(UIColor*)color;
+ (UIImage*) drawText:(NSString*)text atPoint:(CGPoint)point withImg: (UIImage *)img;
+ (UIImage*) getRounded: (UIImage *)img;

@property (nonatomic, strong) CKUserModel *user;

@end
