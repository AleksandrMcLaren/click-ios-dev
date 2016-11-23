//
//  CKMapViewController.h
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKFiltersForMapViewController.h"

@interface CKMapViewController : UIViewController<MKMapViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong) NSString *sexT;
@property(nonatomic,strong) NSNumber *minageT;
@property(nonatomic, strong) NSNumber *maxageT;
@property(nonatomic, strong) NSString *nameT;
@property(nonatomic, assign) BOOL allUsersT;
@property (nonatomic, strong) CKUserModel *profile;
@property (nonatomic, strong) NSNumber *countryIdT;
@property (nonatomic, strong) NSNumber *cityIdT;

@property (nonatomic,retain) CLLocationManager *locationManager;
@end
