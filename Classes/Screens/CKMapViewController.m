//
//  CKMapViewController.m
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKMapViewController.h"
#import <MapKit/MapKit.h>
@implementation CKMapViewController
{
    MKMapView *_mapView;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.title = @"Карта";
    }
    return self;
}

- (void)viewDidLoad
{
    _mapView = [MKMapView new];
    _mapView.showsUserLocation = YES;
    [self.view addSubview:_mapView];
    
    [_mapView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(self.view.top);
        make.width.equalTo(self.view.width);
        make.height.equalTo(self.view.height);
    }];
}

@end
