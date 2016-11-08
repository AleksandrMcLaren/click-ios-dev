//
//  CKCustomPinAnnotation.m
//  click
//
//  Created by Anatoly Mityaev on 20.10.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKCustomPinAnnotation.h"
#import "CKUserAvatarView.h"
#import "CKCache.h"

@implementation CKCustomPinAnnotation

-(instancetype) initWithAnnotation:(id<MKAnnotation>)annotation
{
    self = [super initWithAnnotation:annotation reuseIdentifier:@"CKCustomPinAnnotation"];
    CKCustomPointAnnotation *ann = (CKCustomPointAnnotation *) annotation;
    self.sex = ann.sex;
    self.profile = ann.profile;
    self.canShowCallout = YES;
    
    BOOL imageWithPhoto = false;
    UIButton *messageButton = [[UIButton alloc] init];
    [messageButton setBackgroundImage:[UIImage imageNamed:@"baloon_blue_circle"] forState:UIControlStateNormal];
    [messageButton sizeToFit];
    self.rightCalloutAccessoryView = messageButton;
    
    NSString *str = @"";
    if (![ann.name isEqual:@""] && ann.name !=nil)
    {
        str = [ann.name substringToIndex:1];
    }
    UIButton *imageButton = [UIButton new];
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:ann.avatar]];
    UIImage *imageForEmptyAnn = [UIImage new];
    if ([_sex isEqual:@"f"])
    {
        if (image !=nil)
        {
            image = [CKUserAvatarView imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
            image = [CKUserAvatarView imageWithPurpleBorderAndRoundCornersWithImage:image lineWidth:1.5 cornerRadius:image.size.width/2];
            self.image = image;
            imageWithPhoto = true;
        }
        else
        {
            //image = [CKUserAvatarView purpleCircle];
            self.image = [CKUserAvatarView purpleCircle];
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.text = [NSString stringWithFormat:@"%@", str];
            label.font = [label.font fontWithSize:12];
            [self addSubview:label];
            //imageForEmptyAnn = [CKUserAvatarView imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
            imageForEmptyAnn = [CKUserAvatarView drawText:str inImage:self.image atPoint:CGPointMake(0, 6)];
            imageWithPhoto = false;
            //            self.image = image;
            
        }
    }
    else if ([_sex isEqual:@"m"])
    {
        if (image !=nil)
        {
            image = [CKUserAvatarView imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
            image = [CKUserAvatarView imageWithBlueBorderAndRoundCornersWithImage:image lineWidth:1.5 cornerRadius:image.size.width/2];
            self.image = image;
            imageWithPhoto = true;
        }
        else
        {
            self.image = [CKUserAvatarView blueCircle];
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.text = [NSString stringWithFormat:@"%@", str];
            label.font = [label.font fontWithSize:9];
            [self addSubview:label];
            //imageForEmptyAnn = [CKUserAvatarView imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
            imageForEmptyAnn = [CKUserAvatarView drawText:str inImage:self.image atPoint:CGPointMake(0, 6)];
            imageWithPhoto = false;
        }
    }
    else
    {
        if (image !=nil)
        {
            image = [CKUserAvatarView imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
            image = [CKUserAvatarView imageWithGrayBorderAndRoundCornersWithImage:image lineWidth:1.5 cornerRadius:image.size.width/2];
            self.image = image;
            imageWithPhoto = true;
        }
        else
        {
            self.image = [CKUserAvatarView greyCircle];
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.text = [NSString stringWithFormat:@"%@", str];
            label.font = [label.font fontWithSize:9];
            [self addSubview:label];
            //imageForEmptyAnn = [CKUserAvatarView imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
            imageForEmptyAnn = [CKUserAvatarView drawText:str inImage:self.image atPoint:CGPointMake(0, 6)];
            imageWithPhoto = false;
        }
    }
    if (imageWithPhoto == true)
    {
        img.image = image;
        [imageButton  setBackgroundImage:image forState:UIControlStateNormal];
        [imageButton sizeToFit];
    }
    else
    {
        img.image = imageForEmptyAnn;
        [imageButton  setBackgroundImage:imageForEmptyAnn forState:UIControlStateNormal];
        [imageButton sizeToFit];
    }
    self.leftCalloutAccessoryView = imageButton;
    return self;
}


- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    if (hitView != nil)
    {
        [self.superview bringSubviewToFront:self];
    }
    return hitView;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect rect = self.bounds;
    BOOL isInside = CGRectContainsPoint(rect, point);
    if(!isInside)
    {
        for (UIView *view in self.subviews)
        {
            isInside = CGRectContainsPoint(view.frame, point);
            if(isInside)
                break;
        }
    }
    return isInside;
}

@end
