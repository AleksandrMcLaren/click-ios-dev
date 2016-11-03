//
//  CKCustomPinAnnotation.h
//  click
//
//  Created by Anatoly Mityaev on 20.10.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CKCustomPointAnnotation.h"

@interface CKCustomPinAnnotation : MKAnnotationView

@property (nonatomic, strong) NSURL *avatar;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, strong) NSString *name;


- (instancetype) initWithAnnotation:(id<MKAnnotation>)annotation;

@end
