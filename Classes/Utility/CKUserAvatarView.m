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

+ (UIImage *)bluePinforClusters {
    static UIImage *blueCircle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.f, 30.f), NO, 0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        
        CGRect rect = CGRectMake(0, 0, 30, 30);
        CGContextSetFillColorWithColor(ctx, [[UIColor blueColor] colorWithAlphaComponent:0.6].CGColor);
        CGContextFillEllipseInRect(ctx, rect);
        
        CGContextRestoreGState(ctx);
        blueCircle = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
    });
    return blueCircle;
}
+ (UIColor *) getColorForAvatar: (NSString *) name
{
    __block UIColor *color = [UIColor new];
    NSString *str = name;
    str = [str  uppercaseString];
    
    typedef void (^CaseBlock)();
    
    // Squint and this looks like a proper switch!
    NSDictionary *d = @{
                        @"A":
                            ^{
                                color = [UIColor colorWithRed:230/255.0f green:54/255.0f blue:180/255.0f alpha:1.0];
                            },
                        @"B":
                            ^{
                                color = [UIColor colorWithRed:250/255.0f green:55/255.0f blue:122/255.0f alpha:1.0];
                            },
                        @"C":
                            ^{
                                color =  [UIColor colorWithRed:255/255.0f green:112/255.0f blue:102/255.0f alpha:1.0];
                            },
                        @"D":
                            ^{
                                color =  [UIColor colorWithRed:255/255.0f green:123/255.0f blue:82/255.0f alpha:1.0];
                            },
                        @"E":
                            ^{
                                color =  [UIColor colorWithRed:254/255.0f green:200/255.0f blue:7/255.0f alpha:1.0];
                            },
                        @"F":
                            ^{
                                color =  [UIColor colorWithRed:96/255.0f green:219/255.0f blue:100/255.0f alpha:1.0];
                            },
                        @"G":
                            ^{
                                color =  [UIColor colorWithRed:194/255.0f green:35/255.0f blue:137/255.0f alpha:1.0];
                            },
                        @"H":
                            ^{
                                color =  [UIColor colorWithRed:232/255.0f green:30/255.0f blue:99/255.0f alpha:1.0];
                            },
                        @"I":
                            ^{
                                color =  [UIColor colorWithRed:243/255.0f green:67/255.0f blue:54/255.0f alpha:1.0];
                            },
                        @"J":
                            ^{
                                color =  [UIColor colorWithRed:254/255.0f green:87/255.0f blue:34/255.0f alpha:1.0];
                            },
                        @"K":
                            ^{
                                color =  [UIColor colorWithRed:254/255.0f green:151/255.0f blue:0/255.0f alpha:1.0];
                            },
                        @"L":
                            ^{
                                color =  [UIColor colorWithRed:76/255.0f green:174/255.0f blue:80/255.0f alpha:1.0];
                            },
                        @"M":
                            ^{
                                color =  [UIColor colorWithRed:124/255.0f green:21/255.0f blue:104/255.0f alpha:1.0];
                            },
                        @"N":
                            ^{
                                color =  [UIColor colorWithRed:135/255.0f green:14/255.0f blue:79/255.0f alpha:1.0];
                            },
                        @"O":
                            ^{
                                color =  [UIColor colorWithRed:182/255.0f green:28/255.0f blue:28/255.0f alpha:1.0];
                            },
                        @"P":
                            ^{
                                color =  [UIColor colorWithRed:190/255.0f green:54/255.0f blue:12/255.0f alpha:1.0];
                            },
                        @"Q":
                            ^{
                                color =  [UIColor colorWithRed:299/255.0f green:81/255.0f blue:0/255.0f alpha:1.0];
                            },
                        @"R":
                            ^{
                                color =  [UIColor colorWithRed:27/255.0f green:94/255.0f blue:32/255.0f alpha:1.0];
                            },
                        @"S":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:181/255.0f blue:164/255.0f alpha:1.0];
                            },
                        @"T":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:197/255.0f blue:222/255.0f alpha:1.0];
                            },
                        @"U":
                            ^{
                                color =  [UIColor colorWithRed:78/255.0f green:99/255.0f blue:219/255.0f alpha:1.0];
                            },
                        @"V":
                            ^{
                                color =  [UIColor colorWithRed:144/255.0f green:76/255.0f blue:228/255.0f alpha:1.0];
                            },
                        @"W":
                            ^{
                                color =  [UIColor colorWithRed:210/255.0f green:53/255.0f blue:237/255.0f alpha:1.0];
                            },
                        @"X":
                            ^{
                                color =  [UIColor colorWithRed:121/255.0f green:157/255.0f blue:173/255.0f alpha:1.0];
                            },
                        @"Y":
                            ^{
                                color =  [UIColor colorWithRed:176/255.0f green:124/255.0f blue:105/255.0f alpha:1.0];
                            },
                        @"Z":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:149/255.0f blue:135/255.0f alpha:1.0];
                            },
                        @"0":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:172/255.0f blue:194/255.0f alpha:1.0];
                            },
                        @"1":
                            ^{
                                color =  [UIColor colorWithRed:63/255.0f green:81/255.0f blue:180/255.0f alpha:1.0];
                            },
                        @"2":
                            ^{
                                color =  [UIColor colorWithRed:109/255.0f green:60/255.0f blue:178/255.0f alpha:1.0];
                            },
                        @"3":
                            ^{
                                color =  [UIColor colorWithRed:155/255.0f green:39/255.0f blue:175/255.0f alpha:1.0];
                            },
                        @"4":
                            ^{
                                color =  [UIColor colorWithRed:96/255.0f green:125/255.0f blue:138/255.0f alpha:1.0];
                            },
                        @"5":
                            ^{
                                color =  [UIColor colorWithRed:121/255.0f green:85/255.0f blue:72/255.0f alpha:1.0];
                            },
                        @"6":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:77/255.0f blue:64/255.0f alpha:1.0];
                            },
                        @"7":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:96/255.0f blue:100/255.0f alpha:1.0];
                            },
                        @"8":
                            ^{
                                color =  [UIColor colorWithRed:21/255.0f green:31/255.0f blue:124/255.0f alpha:1.0];
                            },
                        @"9":
                            ^{
                                color =  [UIColor colorWithRed:70/255.0f green:32/255.0f blue:127/255.0f alpha:1.0];
                            },
                        @"А":
                            ^{
                                color =  [UIColor colorWithRed:230/255.0f green:54/255.0f blue:180/255.0f alpha:1.0];
                            },
                        @"Б":
                            ^{
                                color =  [UIColor colorWithRed:250/255.0f green:55/255.0f blue:122/255.0f alpha:1.0];
                            },
                        @"В":
                            ^{
                                color =  [UIColor colorWithRed:255/255.0f green:112/255.0f blue:102/255.0f alpha:1.0];
                            },
                        @"Г":
                            ^{
                                color =  [UIColor colorWithRed:255/255.0f green:123/255.0f blue:82/255.0f alpha:1.0];
                            },
                        @"Д":
                            ^{
                                color =  [UIColor colorWithRed:254/255.0f green:200/255.0f blue:7/255.0f alpha:1.0];
                            },
                        @"Е":
                            ^{
                                color =  [UIColor colorWithRed:96/255.0f green:219/255.0f blue:100/255.0f alpha:1.0];
                            },
                        @"Ё":
                            ^{
                                color =  [UIColor colorWithRed:194/255.0f green:35/255.0f blue:137/255.0f alpha:1.0];
                            },
                        @"Ж":
                            ^{
                                color =  [UIColor colorWithRed:232/255.0f green:30/255.0f blue:99/255.0f alpha:1.0];
                            },
                        @"З":
                            ^{
                                color =  [UIColor colorWithRed:243/255.0f green:67/255.0f blue:54/255.0f alpha:1.0];
                            },
                        @"И":
                            ^{
                                color =  [UIColor colorWithRed:254/255.0f green:87/255.0f blue:34/255.0f alpha:1.0];
                            },
                        @"Й":
                            ^{
                                color =  [UIColor colorWithRed:254/255.0f green:151/255.0f blue:0/255.0f alpha:1.0];
                            },
                        @"К":
                            ^{
                                color =  [UIColor colorWithRed:76/255.0f green:174/255.0f blue:80/255.0f alpha:1.0];
                            },
                        @"Л":
                            ^{
                                color =  [UIColor colorWithRed:124/255.0f green:21/255.0f blue:104/255.0f alpha:1.0];
                            },
                        @"М":
                            ^{
                                color =  [UIColor colorWithRed:135/255.0f green:14/255.0f blue:79/255.0f alpha:1.0];
                            },
                        @"Н":
                            ^{
                                color =  [UIColor colorWithRed:182/255.0f green:28/255.0f blue:28/255.0f alpha:1.0];
                            },
                        @"О":
                            ^{
                                color =  [UIColor colorWithRed:190/255.0f green:54/255.0f blue:12/255.0f alpha:1.0];
                            },
                        @"П":
                            ^{
                                color =  [UIColor colorWithRed:299/255.0f green:81/255.0f blue:0/255.0f alpha:1.0];
                            },
                        @"Р":
                            ^{
                                color =  [UIColor colorWithRed:27/255.0f green:94/255.0f blue:32/255.0f alpha:1.0];
                            },
                        @"С":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:181/255.0f blue:164/255.0f alpha:1.0];
                            },
                        @"Т":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:197/255.0f blue:222/255.0f alpha:1.0];
                            },
                        @"У":
                            ^{
                                color =  [UIColor colorWithRed:78/255.0f green:99/255.0f blue:219/255.0f alpha:1.0];
                            },
                        @"Ф":
                            ^{
                                color =  [UIColor colorWithRed:144/255.0f green:76/255.0f blue:228/255.0f alpha:1.0];
                            },
                        @"Х":
                            ^{
                                color =  [UIColor colorWithRed:210/255.0f green:53/255.0f blue:237/255.0f alpha:1.0];
                            },
                        @"Ц":
                            ^{
                                color =  [UIColor colorWithRed:121/255.0f green:157/255.0f blue:173/255.0f alpha:1.0];
                            },
                        @"Ч":
                            ^{
                                color =  [UIColor colorWithRed:176/255.0f green:124/255.0f blue:105/255.0f alpha:1.0];
                            },
                        @"Ш":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:149/255.0f blue:135/255.0f alpha:1.0];
                            },
                        @"Щ":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:172/255.0f blue:194/255.0f alpha:1.0];
                            },
                        @"Ъ":
                            ^{
                                color =  [UIColor colorWithRed:63/255.0f green:81/255.0f blue:180/255.0f alpha:1.0];
                            },
                        @"Ы":
                            ^{
                                color =  [UIColor colorWithRed:109/255.0f green:60/255.0f blue:178/255.0f alpha:1.0];
                            },
                        @"Ь":
                            ^{
                                color =  [UIColor colorWithRed:155/255.0f green:39/255.0f blue:175/255.0f alpha:1.0];
                            },
                        @"Э":
                            ^{
                                color =  [UIColor colorWithRed:96/255.0f green:125/255.0f blue:138/255.0f alpha:1.0];
                            },
                        @"Ю":
                            ^{
                                color =  [UIColor colorWithRed:121/255.0f green:85/255.0f blue:72/255.0f alpha:1.0];
                            },
                        @"Я":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:77/255.0f blue:64/255.0f alpha:1.0];
                            }
                        };
    
    CaseBlock c = d[str];
    if (c) c(); else {
        return [UIColor orangeColor];
    }
    return color;
}

+ (UIImage*) blankImageWithSize:(CGSize)size color:(UIColor*)color
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [color set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
    UIImage* blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

+ (UIImage*) drawText:(NSString*)text atPoint:(CGPoint)point withImg: (UIImage *)img
{
    text = [text uppercaseString];
    UIImage* image = img;
    double fontSize = 28.0/34*img.size.width; // sorry, magic way
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    //    [[UIColor whiteColor] set];
    //    [text drawInRect:CGRectIntegral(rect) withFont:font];
    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.alignment = NSTextAlignmentCenter;
    NSDictionary* attr = @{NSFontAttributeName: font,
                           NSForegroundColorAttributeName:[UIColor whiteColor],
                           NSParagraphStyleAttributeName: textStyle};
    [text drawInRect:CGRectIntegral(rect) withAttributes:attr];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage*) getRounded: (UIImage *)img
{
    //    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    UIGraphicsBeginImageContext(img.size);
    //    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:cornerRadius] addClip];
    CGFloat cornerRadius = img.size.width / 2;
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, img.size.width, img.size.height) cornerRadius:cornerRadius] addClip];
    //    [image drawInRect:imageView.bounds];
    [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}


@end
