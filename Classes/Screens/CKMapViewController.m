//
//  CKMapViewController.m
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKMapViewController.h"
#import <MapKit/MapKit.h>
#import "CKUserServerConnection.h"
#define METERS_PER_MILE 1609.344
@implementation CKMapViewController
{
    MKMapView *_mapView;
    UIButton *_listButton;
    UIButton *_plusButton;
    UIButton *_minusButton;
    UIButton *_setLocationButton;
    UILabel *_menuLabel;
    
    CGFloat _padding;
    NSArray *_data;
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
    double miles = 0.5;
    
    //how much area will be shown
    MKCoordinateSpan span;
    span.latitudeDelta = miles/69.0;
    span.longitudeDelta = miles/69.0;
    
    /*
     - (void)viewDidLoad{
     [super viewDidLoad];
     
     // define span for map: how much area will be shown
     MKCoordinateSpan span;
     span.latitudeDelta = 0.002;
     span.longitudeDelta = 0.002;
     
     // define starting point for map
     CLLocationCoordinate2D location;
     location.latitude = aUserLocation.coordinate.latitude;
     location.longitude = aUserLocation.coordinate.longitude;
     
     // create region, consisting of span and location
     MKCoordinateRegion region;
     region.span = span;
     region.center = location;
     
     // move the map to our location
     [self.mapView setRegion:region animated:YES];*/
    
    _mapView = [MKMapView new];
    _mapView.showsUserLocation = YES;
    MKCoordinateRegion region;
    region.span = span;
    [_mapView setRegion:region animated:YES];
    //_mapView.mapType = MKMapTypeSatellite;
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [self.view addSubview:_mapView];
    
    [_mapView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(self.view.top);
        make.width.equalTo(self.view.width);
        make.height.equalTo(self.view.height);
    }];
    _padding = 15.0;
    
    //кнопка "Список"
    //    _listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [_listButton setTitle:@"Список" forState: UIControlStateNormal];
    //    [_listButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [self.view addSubview:_listButton];
    
    //кнопка "меню", которая пока является типом label
    //    _menuLabel = [UILabel labelWithText:@"menu"
    //                                   font:[UIFont systemFontOfSize: 14.0]
    //                              textColor:[UIColor whiteColor]
    //                          textAlignment:NSTextAlignmentCenter];
    //    _menuLabel.numberOfLines = 1;
    //    [self.view addSubview:_menuLabel];
    
    //кнопка увеличения
    _plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *plusButtonImage = [UIImage imageNamed:@"plus_blue"];
    [_plusButton setImage:plusButtonImage forState:UIControlStateNormal];
    [self.view addSubview:_plusButton];
    [_plusButton addTarget:self action:@selector(ZoomIn) forControlEvents:UIControlEventTouchUpInside];
    
    //кнопка уменьшения
    _minusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *minusButtonImage = [UIImage imageNamed:@"minus_blue"];
    [_minusButton setImage:minusButtonImage forState:UIControlStateNormal];
    [self.view addSubview:_minusButton];
    [_minusButton addTarget:self action:@selector(ZoomOut) forControlEvents:UIControlEventTouchUpInside];
    
    //кнопка определения локации
    _setLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *locationButtonImage = [UIImage imageNamed:@"geo_active"];
    [_setLocationButton setImage:locationButtonImage forState:UIControlStateNormal];
    [self.view addSubview:_setLocationButton];
    [_setLocationButton addTarget:self action:@selector(CurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    
    //_listButton.alpha = 0.0;
    _plusButton.alpha = 0.0;
    _minusButton.alpha = 0.0;
    //_menuLabel.alpha = 0.0;
    _listButton.alpha = 0.0;
    
}

- (void) loadData
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"select * from userlist"];
    
    CKDB *ckdb = [CKDB sharedInstance];
    
    [ckdb.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *data = [db executeQuery:query];
        [[CKDB sharedInstance] configureDB:db];
        NSMutableArray *tmp = [NSMutableArray new];
        while ([data next])
        {
            [tmp addObject:[data resultDictionary]];
        }
        _data = tmp;
        [data close];
    }];
}

- (void) viewDidAppear:(BOOL)animated{
    
    CGFloat padding = _padding;
    
    [_plusButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_minusButton.top).offset(-padding/8);
        make.right.equalTo(self.view.right).offset(-padding);
        make.width.equalTo(@50);
        make.height.equalTo(50);
    }
     ];
    
    [_minusButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(@0);
        make.right.equalTo(self.view.right).offset(-padding);
        make.width.equalTo(@50);
        make.height.equalTo(@50);
    }];
    
    [_setLocationButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_minusButton.bottom).offset(padding*2);
        make.right.equalTo(self.view.right).offset(-padding);
        make.width.equalTo(@50);
        make.height.equalTo(@50);
    }];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.4 animations:^{
            _listButton.alpha = 1.0;
            _plusButton.alpha = 1.0;
            _minusButton.alpha = 1.0;
            _menuLabel.alpha = 1.0;
            _listButton.alpha = 1.0;        }];
        
    }];
}

- (void) ZoomIn{
    MKCoordinateRegion region = _mapView.region;
    region.span.latitudeDelta /= 2.0;
    region.span.longitudeDelta /= 2.0;
    [_mapView setRegion:region animated:YES];
}

- (void) ZoomOut{
    MKCoordinateRegion region = _mapView.region;
    region.span.latitudeDelta  = MIN(region.span.latitudeDelta  * 2.0, 180.0);
    region.span.longitudeDelta = MIN(region.span.longitudeDelta * 2.0, 180.0);
    [_mapView setRegion:region animated:YES];
}

- (void) CurrentLocation{
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
}
@end
