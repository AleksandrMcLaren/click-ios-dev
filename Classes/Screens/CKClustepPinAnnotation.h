//
//  CKClustepPinAnnotation.h
//  click
//
//  Created by Anatoly Mityaev on 21.10.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CKClusterPointAnnotation.h"

@interface CKClustepPinAnnotation : MKAnnotationView

@property (nonatomic, strong) NSNumber *usersInCluster;
@property (nonatomic, copy) UIImage *image;

- (instancetype) initWithAnnotation:(id<MKAnnotation>)annotation;

@end
