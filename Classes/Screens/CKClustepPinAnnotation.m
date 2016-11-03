//
//  CKClustepPinAnnotation.m
//  click
//
//  Created by Anatoly Mityaev on 21.10.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKClustepPinAnnotation.h"
#import "CKUserAvatarView.h"

@implementation CKClustepPinAnnotation

- (instancetype) initWithAnnotation:(id<MKAnnotation>)annotation
{
    self = [super initWithAnnotation:annotation reuseIdentifier:@"CKClustepPinAnnotation"];
    CKClusterPointAnnotation *ann = (CKClusterPointAnnotation *) annotation;
    self.usersInCluster = [NSNumber numberWithInt: [ann.usersInCluster intValue]];
    //self.canShowCallout = YES;
    NSString *str = [ann.usersInCluster stringValue];
    UIImage *image = ann.image;
    self.image = [CKUserAvatarView bluePinforClusters];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%@", str];
    label.font = [label.font fontWithSize:9];
    [self addSubview:label];
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
