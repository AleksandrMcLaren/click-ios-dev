//
//  CKMapViewController.m
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKMapViewController.h"
#import <MapKit/MapKit.h>

#import "CKApplicationModel.h"
#import "CKCustomPointAnnotation.h"
#import "CKCustomPinAnnotation.h"
#import "AppDelegate.h"
#import "CKUserServerConnection.h"
#import "CKMessageServerConnection.h"
#import "CKClusterPointAnnotation.h"
#import "CKClustepPinAnnotation.h"
#import "CKFiltersForMapViewController.h"
#import "CKFriendProfileController.h"
#import "CKDialogChatController.h"
#import <QuartzCore/QuartzCore.h>
#import "CKCache.h"

#define METERS_PER_MILE 1609.344



@implementation CKMapViewController
{
    MKMapView *_mapView;
    UIButton *_listButton;
    UIButton *_plusButton;
    UIButton *_minusButton;
    UIButton *_setLocationButton;
    UILabel *_menuLabel;
    int counter;
    
    CGFloat _padding;
    NSArray *_data;
    NSArray *_friendlist;
    NSNumber *userLat;
    NSNumber *userLng;
    NSArray<CKUserModel *> *_userlist;
    NSArray<CKClusterModel *> *_clusterlist;
    MKMapRect _mRect;
    NSMutableArray<CKCustomPointAnnotation *> *_annotations1;
    NSMutableArray<CKClusterPointAnnotation *> *_annotations2;
    int count;
    
    CKFiltersForMapViewController * ffmvc;
    
    NSString *sexVar;
    NSNumber *minageVar;
    NSNumber *maxageVar;
    NSNumber *status;
    NSNumber *inAllUsers;
    NSString *nameVar;
    UIImage *countryImageVar;
    NSString *countryNameVar;
    BOOL online;
    BOOL zoomByGesture;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.title = @"Карта";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"hamburger"] style:UIBarButtonItemStylePlain target:self action:@selector(filterButton)];
        self.profile = [[CKApplicationModel sharedInstance] userProfile];
        zoomByGesture = false;
    }
    return self;
}



- (void)viewDidLoad
{
    zoomByGesture = false;
    _annotations1 = [NSMutableArray new];
    _annotations2 = [NSMutableArray new];
    status = @0;
    online = true;
    sexVar = @"";
    minageVar = @0;
    maxageVar = @0;
    inAllUsers = @0;
    nameVar = @"";
    _minageT = @0;
    _maxageT = @0;
    _sexT = @"";
    double miles = 0.5;
    ffmvc = [CKFiltersForMapViewController new];
    ffmvc.switchOn = true;
    _mapView = [MKMapView new];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = _mapView.userLocation.coordinate.latitude;
    mapRegion.center.longitude = _mapView.userLocation.coordinate.longitude;
    mapRegion.span.latitudeDelta = miles/69.0;
    mapRegion.span.longitudeDelta = miles/69.0;
    [_mapView setRegion:mapRegion animated: YES];
    //    MKCoordinateRegion region;
    //    region.span = span;
    //[_mapView setRegion:region animated:YES];
    _mapView.userLocation.title = @"Текущее местоположение";
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    _mapView.multipleTouchEnabled = YES;
    _mapView.userInteractionEnabled = YES;
    [self.view addSubview:_mapView];
    
    UIPinchGestureRecognizer *tapRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
    tapRecognizer.delegate = self;
    [_mapView addGestureRecognizer:tapRecognizer];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    [_mapView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(self.view.top);
        make.width.equalTo(self.view.width);
        make.height.equalTo(self.view.height);
    }];
    _padding = 15.0;
    
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
    
    _plusButton.alpha = 0.0;
    _minusButton.alpha = 0.0;
    _listButton.alpha = 0.0;
    
    count=0;
    ffmvc.minage = @0;
    ffmvc.maxage = @0;
    ffmvc.sex = @"Любой";
    ffmvc.allUsers = true;
    _allUsersT = true;
    ffmvc.name = @"";
    ffmvc.country = @"";
    ffmvc.countryImageIso = 0;
    ffmvc.city = @"";
    ffmvc.endWithCancelFilters = NO;
}

- (void) viewDidAppear:(BOOL)animated{
    zoomByGesture = false;
    CGFloat padding = _padding;
    count = 0;
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
    online = ffmvc.switchOn;
    if (online == false)
    {
        [[CKUserServerConnection sharedInstance] setUserStatus:@0];
        //[self deviceLocation];
        //[[CKMessageServerConnection sharedInstance] setLocaion:@0 andLng:@0];
    }
    else
    {
        [[CKUserServerConnection sharedInstance] setUserStatus:@1];
        //[self deviceLocation];
        //[[CKMessageServerConnection sharedInstance] setLocaion:userLat andLng:userLng];
    }
    [self reloadAnnotations];
    [self deviceLocation];
    [[CKMessageServerConnection sharedInstance] setLocaion:userLat andLng:userLng];
}

- (void) viewWillAppear:(BOOL)animated
{
    zoomByGesture = false;
    [[CKApplicationModel sharedInstance] updateUsers];
    
}

- (void) filterButton
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:ffmvc];
    navController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (zoomByGesture == false || count < 2)
    {
        if (ffmvc.endWithSumbit == true)
        {
            _sexT = ffmvc.sex;
            _minageT = ffmvc.minage;
            _maxageT = ffmvc.maxage;
            online = ffmvc.switchOn;
            _allUsersT = ffmvc.allUsers;
            _nameT = ffmvc.name;
            _countryIdT = [NSNumber numberWithInteger: ffmvc.countryId];
            _cityIdT = [NSNumber numberWithInteger:ffmvc.cityId];
            
        }
        if (online == true)
        {
            [[CKUserServerConnection sharedInstance] setUserStatus:@1];
            //[self deviceLocation];
            //[[CKMessageServerConnection sharedInstance] setLocaion:userLat andLng:userLng];
        }
        else
        {
            [[CKUserServerConnection sharedInstance] setUserStatus:@0];
            //[[CKMessageServerConnection sharedInstance] setLocaion:@0 andLng:@0];
        }
        if (ffmvc.endWithCancelFilters == YES)
        {
            _countryIdT = [NSNumber numberWithInteger: 0];
            _cityIdT = [NSNumber numberWithInteger: 0];
        }
        if (![_sexT isEqual: @""] && _sexT != nil)
        {
            if ([_sexT isEqual:@"Мужской"])
            {
                sexVar = @"m";
            }
            else if ([_sexT isEqual: @"Женский"])
            {
                sexVar = @"f";
            }
            else
            {
                sexVar = @"";
            }
        }
        if (/*![_minageT isEqual: @0] && */_minageT !=nil)
        {
            minageVar = _minageT;
        }
        if ( /*![_maxageT isEqual: @0] &&*/ _maxageT !=nil)
        {
            maxageVar = _maxageT;
        }
        if (![_nameT isEqual:@""] && _nameT != nil)
        {
            nameVar = _nameT;
        }
        if (_allUsersT == true)
        {
            inAllUsers = [NSNumber numberWithInteger:-1];
        }
        else inAllUsers = [NSNumber numberWithInteger:1];
        if (_countryIdT == nil) _countryIdT = [NSNumber numberWithInteger:[@0 integerValue]];
        if (_cityIdT == nil) _cityIdT = [NSNumber numberWithInteger:0];
        
        _mRect = _mapView.visibleMapRect;
        MKMapPoint neMapPoint = MKMapPointMake(MKMapRectGetMaxX(_mRect), _mRect.origin.y);
        MKMapPoint swMapPoint = MKMapPointMake(_mRect.origin.x, MKMapRectGetMaxY(_mRect));
        
        CLLocationCoordinate2D neCoord = MKCoordinateForMapPoint(neMapPoint);
        CLLocationCoordinate2D swCoord = MKCoordinateForMapPoint(swMapPoint);
        
        NSNumber *nelat = [[NSNumber alloc] initWithDouble:neCoord.latitude];
        NSNumber *nelng = [[NSNumber alloc] initWithDouble:neCoord.longitude];
        NSNumber *swlat = [[NSNumber alloc] initWithDouble:swCoord.latitude];
        NSNumber *swlng = [[NSNumber alloc] initWithDouble:swCoord.longitude];
        
        [[CKApplicationModel sharedInstance] loadClusters: @1 withFriendStatus:inAllUsers withCountry:_countryIdT withCity:_cityIdT withSex:sexVar withMinage:minageVar andMaxAge:maxageVar withMask:nameVar withBottomLeftLatitude:swlat withBottomLeftLongtitude:swlng withtopCoordinate:nelat withTopRigthLongtitude:nelng withInt:count];
        
        //    [[CKApplicationModel sharedInstance] loadClusters:swlat withBottomLeftLongtitude:swlng withtopCoordinate:nelat withTopRigthLongtitude:nelng withInt: count];
        count++;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (MKAnnotationView*)mapView:(MKMapView *)mapView
           viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    if ([annotation isKindOfClass:[CKCustomPointAnnotation class]])
    {
        CKCustomPinAnnotation* pin = [[CKCustomPinAnnotation alloc]initWithAnnotation:annotation];
        pin.leftCalloutAccessoryView.tag = 1;
        pin.rightCalloutAccessoryView.tag = 2;
        return pin;
    }
    if ([annotation isKindOfClass: [CKClusterPointAnnotation class]])
    {
        CKClustepPinAnnotation *pin2 = [[CKClustepPinAnnotation alloc] initWithAnnotation:annotation];
        return pin2;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[CKCustomPointAnnotation class]])
    {
        if ([control tag] == 1)
        {
            CKCustomPointAnnotation *ckcpa = view.annotation;
            CKFriendProfileController *ckfpc = [[CKFriendProfileController alloc] initWithUser:ckcpa.profile];
            ckfpc.wentFromTheMap = true;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: ckfpc];
            navController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:navController animated:YES completion:nil];
            //ckupc.ownerProfile = true;
        }
        else if ([control tag] == 2)
        {
            CKCustomPointAnnotation *ckcpa = view.annotation;
            CKDialogChatController *ctl = [[CKDialogChatController alloc] initWithUserId:ckcpa.profile.id];
            ctl.user = ckcpa.profile;
            ctl.wentFromTheMap = true;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: ctl];
            navController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:navController animated:YES completion:nil];
            //[self.navigationController pushViewController:ctl animated:YES];
        }
    }
}

- (void) reloadAnnotations
{
    [_mapView removeAnnotations:_annotations1];
    [_mapView removeAnnotations:_annotations2];
    [_annotations1 removeAllObjects];
    [_annotations2 removeAllObjects];
    _clusterlist = [[CKApplicationModel sharedInstance] clusterlist];
    _data = [[CKApplicationModel sharedInstance] userlistMain];
    _friendlist = [[CKApplicationModel sharedInstance] friends];
    counter = 1;
    
    
    if (_clusterlist !=nil || _clusterlist.count != 0)
    {
        for (CKClusterModel *cluster in _clusterlist)
        {
            if ([cluster.cnttotal intValue] == counter)
            {
                for (CKUserModel *user in _data)
                {
                    if ([user.id isEqual: cluster.userid])
                    {
                        CKCustomPointAnnotation *pin = [[CKCustomPointAnnotation alloc] init];
                        if (user.age > 13)
                        {
                            if (user.isFriend == 1)
                            {
                                CKUserModel *friend = [[CKUserModel alloc] init];
                                for (CKUserModel *friends in _friendlist)
                                {
                                    if ([user.login isEqual:friends.login])
                                        friend = user;
                                }
                                if (![friend.name isEqual:@""])
                                {
                                    if (![friend.surname isEqual:@""])
                                    {
                                        pin.title = [NSString stringWithFormat: @"%@ %@, %ld лет", friend.name, friend.surname, friend.age];
                                        pin.subtitle = friend.login;
                                        pin.name = friend.name;
                                    }
                                    else
                                    {
                                        pin.title = [NSString stringWithFormat: @"%@, %ld лет", friend.name, friend.age];
                                        pin.subtitle = friend.login;
                                        pin.name = friend.name;
                                    }
                                }
                                else
                                {
                                    pin.title = [NSString stringWithFormat: @"%@, %ld лет", friend.login, friend.age];
                                    pin.name = user.login;
                                }
                            }
                            else
                            {
                                if (![user.name isEqual:@""])
                                {
                                    if (![user.surname isEqual:@""])
                                    {
                                        pin.title = [NSString stringWithFormat: @"%@ %@, %ld лет", user.name, user.surname, user.age];
                                        pin.subtitle = user.login;
                                        pin.name = user.name;
                                    }
                                    else
                                    {
                                        pin.title = [NSString stringWithFormat: @"%@, %ld лет", user.name, user.age];
                                        pin.subtitle = user.login;
                                        pin.name = user.name;
                                    }
                                }
                                else
                                {
                                    pin.title = [NSString stringWithFormat: @"%@, %ld лет", user.login, user.age];
                                    pin.name = user.login;
                                }
                            }
                            
                        }
                        else
                        {
                            if (user.isFriend == 1)
                            {
                                CKUserModel *friend = [[CKUserModel alloc] init];
                                for (CKUserModel *friends in _friendlist)
                                {
                                    if ([user.login isEqual:friends.login])
                                        friend = user;
                                }
                                
                                if (![friend.name isEqual:@""])
                                {
                                    if (![friend.surname isEqual:@""])
                                    {
                                        pin.title = [NSString stringWithFormat: @"%@ %@", friend.name, friend.surname];
                                        pin.subtitle = friend.login;
                                        pin.name = friend.name;
                                    }
                                    else
                                    {
                                        pin.title = [NSString stringWithFormat: @"%@", friend.name];
                                        pin.subtitle = friend.login;
                                        pin.name = friend.name;
                                    }
                                }
                                else
                                {
                                    pin.title = [NSString stringWithFormat: @"%@", friend.login];
                                    pin.name = friend.login;
                                }
                                
                            }
                            else
                            {
                                if (![user.name isEqual:@""])
                                {
                                    if (![user.surname isEqual:@""])
                                    {
                                        pin.title = [NSString stringWithFormat: @"%@ %@", user.name, user.surname];
                                        pin.subtitle = user.login;
                                        pin.name = user.name;
                                    }
                                    else
                                    {
                                        pin.title = [NSString stringWithFormat: @"%@", user.name];
                                        pin.subtitle = user.login;
                                        pin.name = user.name;
                                    }
                                }
                                else
                                {
                                    pin.title = [NSString stringWithFormat: @"%@", user.login];
                                    pin.name = user.login;
                                }
                            }
                        }
                        
                        
                        pin.coordinate = CLLocationCoordinate2DMake(cluster.location.latitude, cluster.location.longitude);
                        pin.sex = user.sex;
                        pin.profile = user;
                        //UIImage *avatarImage = [[CKCache sharedInstance] imageWithURLString:user.avatarURLString];
                        NSURL *avatarUrl = [NSURL URLWithString:user.avatarURLString];
                        //UIImage *avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user.avatarURLString]]];
                        pin.avatar = avatarUrl;
                        [_annotations1 addObject:pin];
                        [_mapView viewForAnnotation:pin];
                        break;
                    }
                }
            }
            else
            {
                CKClusterPointAnnotation *pin = [[CKClusterPointAnnotation alloc] init];
                pin.usersInCluster = cluster.cnttotal;
                pin.coordinate = CLLocationCoordinate2DMake(cluster.location.latitude, cluster.location.longitude);
                pin.image = cluster.avatar;
                [_annotations2 addObject:pin];
                [_mapView viewForAnnotation:pin];
            }
        }
    }
    else{
        
    }
    [_mapView addAnnotations:_annotations1];
    [_mapView addAnnotations:_annotations2];
}



- (void) zoom: (UIPinchGestureRecognizer *) sender
{
    zoomByGesture = false;
    static MKCoordinateRegion originalRegion;
    if (sender.state == UIGestureRecognizerStateBegan) {
        originalRegion = _mapView.region;
    }
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (sender.scale > 1)
        {
            
            count=0;
            [_mapView removeAnnotations:_annotations1];
            [_mapView removeAnnotations:_annotations2];
            MKCoordinateRegion region = _mapView.region;
            region.span.latitudeDelta /= 2.0;
            region.span.longitudeDelta /= 2.0;
            [_mapView setRegion:region animated:YES];
        }
        else
        {
            count=0;
            [_mapView removeAnnotations:_annotations1];
            [_mapView removeAnnotations:_annotations2];
            MKCoordinateRegion region = _mapView.region;
            region.span.latitudeDelta  = MIN(region.span.latitudeDelta  * 2.0, 180.0);
            region.span.longitudeDelta = MIN(region.span.longitudeDelta * 2.0, 180.0);
            [_mapView setRegion:region animated:YES];
        }
        [self mapView:_mapView regionDidChangeAnimated:YES];
        zoomByGesture = true;
        [self reloadAnnotations];
    }
}

- (void) ZoomIn{
    zoomByGesture = false;
    count=0;
    [_mapView removeAnnotations:_annotations1];
    [_mapView removeAnnotations:_annotations2];
    MKCoordinateRegion region = _mapView.region;
    region.span.latitudeDelta /= 2.0;
    region.span.longitudeDelta /= 2.0;
    [_mapView setRegion:region animated:YES];
    [self reloadAnnotations];
}

- (void) ZoomOut{
    zoomByGesture = false;
    count=0;
    [_mapView removeAnnotations:_annotations1];
    [_mapView removeAnnotations:_annotations2];
    MKCoordinateRegion region = _mapView.region;
    region.span.latitudeDelta  = MIN(region.span.latitudeDelta  * 2.0, 180.0);
    region.span.longitudeDelta = MIN(region.span.longitudeDelta * 2.0, 180.0);
    [_mapView setRegion:region animated:YES];
    [self reloadAnnotations];
}

- (void) CurrentLocation{
    zoomByGesture = false;
    count = 0;
    [_mapView removeAnnotations:_annotations1];
    [_mapView removeAnnotations:_annotations2];
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = _mapView.userLocation.coordinate.latitude;
    mapRegion.center.longitude = _mapView.userLocation.coordinate.longitude;
    mapRegion.span.latitudeDelta = 0.5/69.0;
    mapRegion.span.longitudeDelta = 0.5/69.0;
    [_mapView setRegion:mapRegion animated: YES];
    [self reloadAnnotations];
    [self deviceLocation];
    [[CKMessageServerConnection sharedInstance] setLocaion:userLat andLng:userLng];
}

- (void)deviceLocation
{
    userLat = [NSNumber numberWithDouble:_locationManager.location.coordinate.latitude];
    userLng = [NSNumber numberWithDouble:_locationManager.location.coordinate.longitude];
    
}
@end
