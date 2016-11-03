//
//  CKClusterPointAnnotation.h
//  click
//
//  Created by Anatoly Mityaev on 21.10.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CKClusterPointAnnotation : MKPointAnnotation

@property (nonatomic, copy) UIImage *image;
@property (nonatomic, strong) NSNumber *usersInCluster;

@end
