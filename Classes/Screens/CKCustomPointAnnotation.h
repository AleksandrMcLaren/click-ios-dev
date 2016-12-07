//
//  CKCustomPointAnnotation.h
//  click
//
//  Created by Anatoly Mityaev on 19.10.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "utilities.h"

@interface CKCustomPointAnnotation : MKPointAnnotation

@property (nonatomic, strong) NSURL *avatar;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) CKUser *profile;

@end
