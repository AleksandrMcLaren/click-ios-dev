//
//  CKUserAvatarView.m
//  click
//
//  Created by Igor Tetyuev on 01.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKUserAvatarView.h"

@implementation CKUserAvatarView

- (instancetype)initWithUser:(CKUserModel *)user
{
    if (self = [super init])
    {
        self.user = user;
    }
    return self;
}

- (void)setUser:(CKUserModel *)user
{
    _user = user;
    [self setAvatarFile:user.avatarName fallbackName:[user letterName]];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageWithPurpleBorderAndRoundCornersWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius{
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
    CGRect rect = CGRectZero;
    rect.size = image.size;
    CGRect pathRect = CGRectInset(rect, lineWidth / 2.0, lineWidth / 2.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:cornerRadius];
    
    CGContextBeginPath(context);
    CGContextAddPath(context, path.CGPath);
    CGContextClosePath(context);
    CGContextClip(context);
    
    [image drawAtPoint:CGPointZero];
    
    CGContextRestoreGState(context);
    
    [[UIColor magentaColor] setStroke];
    path.lineWidth = lineWidth;
    [path stroke];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+ (UIImage *) imageWithBlueBorderAndRoundCornersWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius
{
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
    CGRect rect = CGRectZero;
    rect.size = image.size;
    CGRect pathRect = CGRectInset(rect, lineWidth / 2.0, lineWidth / 2.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:cornerRadius];
    
    CGContextBeginPath(context);
    CGContextAddPath(context, path.CGPath);
    CGContextClosePath(context);
    CGContextClip(context);
    
    [image drawAtPoint:CGPointZero];
    
    CGContextRestoreGState(context);
    
    [[UIColor blueColor] setStroke];
    path.lineWidth = lineWidth;
    [path stroke];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+(UIImage *) imageWithGrayBorderAndRoundCornersWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius
{
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
    CGRect rect = CGRectZero;
    rect.size = image.size;
    CGRect pathRect = CGRectInset(rect, lineWidth / 2.0, lineWidth / 2.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:cornerRadius];
    
    CGContextBeginPath(context);
    CGContextAddPath(context, path.CGPath);
    CGContextClosePath(context);
    CGContextClip(context);
    
    [image drawAtPoint:CGPointZero];
    
    CGContextRestoreGState(context);
    
    [[UIColor grayColor] setStroke];
    path.lineWidth = lineWidth;
    [path stroke];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
    
}

+ (UIImage *)blueCircle{
    static UIImage *blueCircle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.f, 20.f), NO, 0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        
        CGRect rect = CGRectMake(0, 0, 20, 20);
        CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
        CGContextFillEllipseInRect(ctx, rect);
        
        CGContextRestoreGState(ctx);
        blueCircle = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return blueCircle;
}
+ (UIImage *)purpleCircle {
    static UIImage *purpleCircle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.f, 20.f), NO, 0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        
        CGRect rect = CGRectMake(0, 0, 20, 20);
        CGContextSetFillColorWithColor(ctx, [UIColor magentaColor].CGColor);
        CGContextFillEllipseInRect(ctx, rect);
        
        CGContextRestoreGState(ctx);
        purpleCircle = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return purpleCircle;
}
+ (UIImage *)greyCircle {
    static UIImage *greyCircle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.f, 20.f), NO, 0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        
        CGRect rect = CGRectMake(0, 0, 20, 20);
        CGContextSetFillColorWithColor(ctx, [UIColor grayColor].CGColor);
        CGContextFillEllipseInRect(ctx, rect);
        
        CGContextRestoreGState(ctx);
        greyCircle = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return greyCircle;
}

+(UIImage*) drawText:(NSString*) text inImage:(UIImage*)  image atPoint:(CGPoint)   point
{
    
    NSMutableAttributedString *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",text]];
    
    [textStyle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, textStyle.length)];
    
    [textStyle addAttribute:NSFontAttributeName  value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(0, textStyle.length)];
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    
    [textStyle drawInRect:CGRectIntegral(rect)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)bluePinforClusters {
    static UIImage *blueCircle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(15.f, 15.f), NO, 0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        
        CGRect rect = CGRectMake(0, 0, 15, 15);
        CGContextSetFillColorWithColor(ctx, [[UIColor blueColor] colorWithAlphaComponent:0.6].CGColor);
        CGContextFillEllipseInRect(ctx, rect);
        
        CGContextRestoreGState(ctx);
        blueCircle = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return blueCircle;
}

@end
