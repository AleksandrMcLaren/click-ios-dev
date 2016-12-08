//
//  CKApplicationModel.m
//  click
//
//  Created by Igor Tetyuev on 09.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKApplicationModel.h"
#import "utilities.h"

@implementation CKClusterModel

+ (instancetype)modelWithDictionary: (NSDictionary *) sourceDict
{
    CKClusterModel *clustermodel = [CKClusterModel new];
    
    @try{
        clustermodel.userid = [NSString stringWithFormat:@"%@", sourceDict[@"userid"]];
        clustermodel.clusterid = [NSString stringWithFormat:@"%@", sourceDict[@"clusterid"]];
        
        clustermodel.cnttotal = [NSNumber numberWithInteger: [sourceDict[@"cnttotal"] intValue]];
        clustermodel.location = CLLocationCoordinate2DMake([sourceDict[@"lat"] doubleValue], [sourceDict[@"lng"] doubleValue]);
        clustermodel.sex = sourceDict[@"sex"];
    }
    @catch (NSException *exception) {
        return nil; // bad model
    }
    return clustermodel;
}

@end

@implementation CKPhoneContact

@end

@interface CKApplicationModel()<CLLocationManagerDelegate>{
    Reachability* _internetReachable;
    CKChatModel* _currentChat;
}

@property (nonatomic, strong) NSString *token;

@end

@implementation CKApplicationModel
{
    NSString *_token;
    NSString *_userPhone;
    CLLocationManager *_locationManager;
    CLAuthorizationStatus _locationAuthorizationStatus;
    CLLocation *_location;
    BOOL _isNewUser;
    
    NSMutableDictionary *_chatPool;
    
    NSNumber *_nelat;
    NSNumber *_nelng;
    NSNumber *_swlat;
    NSNumber *_swlng;
    NSNumber *_status;
    NSNumber *_isfriend;
    NSNumber *_country;
    NSNumber *_city;
    NSString *_sex;
    NSNumber *_minage;
    NSNumber *_maxage;
    NSString *_mask;

}

- (instancetype)init
{
    if (self = [super init])
    {
        _token = [UserDefaults  stringForKey:@"token"];
        _userPhone = [UserDefaults stringForKey:@"phoneNumber"];
        _countryId = 2017370;
        _isNewUser = NO;
        _chatPool = [NSMutableDictionary new];
        if (_token) {
            [CKUserServerConnection sharedInstance].token = _token;
            [CKUserServerConnection sharedInstance].phoneNumber = _userPhone;
            
            [CKMessageServerConnection sharedInstance].token = _token;
            [CKMessageServerConnection sharedInstance].phoneNumber = _userPhone;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageResived:) name:CKMessageServerConnectionReceived object:nil];
    }
    return self;
}

- (void)setToken:(NSString *)token
{
    _token = token;
    [UserDefaults setObject:_token forKey:@"token"];
    [UserDefaults setObject:_userPhone forKey:@"phoneNumber"];
}

+ (instancetype)sharedInstance
{
    static CKApplicationModel *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [CKApplicationModel new];
    });
    
    return instance;
}


- (void) didStarted
{

    [self setupLocationService];
    
    if (self.token == nil)
    {
        [self.mainController showWelcomeScreen];
    } else {
        [[CKUserServerConnection sharedInstance] getUserInfoWithId:_userPhone callback:^(NSDictionary* result) {
            if ([result socketMessageStatus] == S_OK){
                [CKUser update:[result socketMessageResult]];
                [[Users sharedInstance] reloadUserList];
            }else{
                [_mainController showAlertWithResult:result completion:nil];
            }
        }];
        [self showMainScreen];
    }
}

- (void) userDidAcceptTerms
{
    [self.mainController showLoginScreen];
}

- (BOOL)countryExistWithId:(NSInteger)id{
    __block BOOL result = NO;
    
    CKDB *ckdb = [CKDB sharedInstance];
    
    NSMutableString *query = [NSMutableString stringWithFormat:@"select count(*) from countries where id=%ld", (long)id];
    [ckdb.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *data = [db executeQuery:query];
        while ([data next])
        {
            result = [data intForColumnIndex:0] > 0;
            break;
        }
        [data close];
    }];
    return result;
}

- (NSDictionary *)countryWithId:(NSInteger)id
{
    CKDB *ckdb = [CKDB sharedInstance];

    NSMutableString *query = [NSMutableString stringWithFormat:@"select * from countries where id=%ld", (long)id];
    __block NSDictionary *result = nil;
    [ckdb.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *data = [db executeQuery:query];
        while ([data next])
        {
            result = [data resultDictionary];
            break;
        }
        [data close];
    }];
    return result;
}

- (NSDictionary *)countryWithPhoneCode:(NSString*)phoneCode
{
    CKDB *ckdb = [CKDB sharedInstance];
    
    NSMutableString *query = [NSMutableString stringWithFormat:@"select * from countries where phonecode=%@", phoneCode];
    __block NSDictionary *result = nil;
    [ckdb.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *data = [db executeQuery:query];
        while ([data next])
        {
            result = [data resultDictionary];
            break;
        }
        [data close];
    }];
    return result;
}

- (void) sendUserPhone:(NSString *)phone promo:(NSString *)promo countryId:(NSInteger)countryId
{
    phone = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSString* operation = @"user.checkuser";
    [_mainController beginOperation:operation];
    
        _userPhone = phone;
        _countryId = countryId;
        [CKUserServerConnection sharedInstance].phoneNumber = phone;
        [CKMessageServerConnection sharedInstance].phoneNumber = phone;
        
       
        [[CKUserServerConnection sharedInstance] checkUserWithCallback:^(NSDictionary *result) {
            [_mainController endOperation:operation];
            if ([result socketMessageStatus] == S_OK){
                _isNewUser = YES;
                
                //        result == 1 || result == -1, тогда пользователя можно восстановить, иначе - пользователь новый, пользователь видит инфу
                
                switch ([result socketMessageResultInteger]) {
                    case 0:
                        NSLog(@"0 – Пользователя или нет или неактивирован");
                        _isNewUser = YES;
                        break;
                        
                    case 1:
                        NSLog(@"1 – все нормально,");
                        _isNewUser = NO;
                        break;
                        
                    case -1:
                        NSLog(@"-1 – есть, активирован но регистрация не завершена, нет профиля");
                        _isNewUser = NO;
                        break;
                    default:
                        break;
                }
                [[CKUserServerConnection sharedInstance] registerUserWithPromo:promo callback:^(NSDictionary *result) {
                    [self.mainController showAuthenticationScreen];
                }];
            }else{
                [_mainController showAlertWithResult:result completion:nil];
            }
        }];
}

- (void)sendPhoneAuthenticationCode:(NSString *)code
{
    NSString* operation = @"user.activate";
    [_mainController beginOperation:operation];
    
    [[CKUserServerConnection sharedInstance] activateUserWithCode:code callback:^(NSDictionary* result) {
        [_mainController endOperation:operation];
        if ([result socketMessageStatus] == S_OK){
            self.token = [[CKUserServerConnection sharedInstance] token];
            [CKMessageServerConnection sharedInstance].token = self.token;
            
            [[CKUserServerConnection sharedInstance] getUserInfoWithId:_userPhone callback:^(NSDictionary* result) {
                
                CKUser *profile;
                
                if ([result socketMessageStatus] == S_OK ) {
                    profile = [CKUser modelWithDictionary:[result socketMessageResult]];
                    [CKUser update:[result socketMessageResult]];
                    if (![[CKApplicationModel sharedInstance] countryExistWithId:profile.countryId]) {
                        NSDictionary *country = [[CKApplicationModel sharedInstance] countryWithId:self.countryId];
                        profile.iso = [country[@"iso"] integerValue];
                        profile.countryName = country[@"name"];
                        profile.countryId = self.countryId;
                    }
                    [Users sharedInstance].currentUser = profile;
                }else {
                    profile = [[Users sharedInstance] currentUser];
                }
                
                if (profile) {
                    if (_isNewUser) {
                        [self.mainController showProfile:NO];
                    }else{
                        [self.mainController showRestoreHistory];
                    }
                }else{
                    [_mainController showAlertWithResult:result completion:nil];
                }
            } ];
        }else{
            [_mainController showAlertWithResult:result completion:nil];
        }
    }];
}

- (void)checkUserLogin:(NSString *)login withCallback:(CKServerConnectionExecutedObject)callback{
    [[CKUserServerConnection sharedInstance] checkUserLogin:login withCallback:^(id result) {
        callback(result);
    }];
}

- (void)requestAuthentication;
{
    [[CKUserServerConnection sharedInstance] getActivationCode:^(NSDictionary *result) {
        
    }];
}



- (void)showMainScreen
{
    [self.mainController showMainScreen];
    
    [[CKDialogsModel sharedInstance] run];
    
    [[Users sharedInstance] run];
    
}

- (void) updateUsers
{
    [[CKMessageServerConnection sharedInstance] getUserListWithFilter:[CKUserFilterModel filterWithLocation] callback:^(NSDictionary *result) {
        NSMutableArray<CKUser*> *userlist = [NSMutableArray new];
        for (NSDictionary *i in result[@"result"])
        {
            CKUser *user1 = [CKUser modelWithDictionary:i];
            [userlist addObject:user1];
        }
        _userlistMain = userlist;
    }];
}

- (void) restoreHistoryWithCallback:(CKServerConnectionExecuted)callback
{
    [[CKMessageServerConnection sharedInstance] getDialogListWithCallback:^(NSDictionary *result) {
        callback(result);
    }];
}


- (void) loadClusters: (NSNumber *)status withFriendStatus: (NSNumber *)isfriend withCountry: (NSNumber *)country withCity: (NSNumber *)city withSex: (NSString *)sex withMinage: (NSNumber *)minage andMaxAge: (NSNumber *)maxage withMask: (NSString *)mask withBottomLeftLatitude: (NSNumber *)swlat withBottomLeftLongtitude: (NSNumber *)swlng withtopCoordinate: (NSNumber *)nelat withTopRigthLongtitude: (NSNumber *)nelng withInt: (int) count{
    if (count ==0){
        _nelat = nelat;
        _nelng = nelng;
        _swlat = swlat;
        _swlng = swlng;
        _status = status;
        _isfriend = isfriend;
        _country = country;
        _city = city;
        _sex = sex;
        _minage = minage;
        _maxage = maxage;
        _mask = mask;
    }
    [[CKMessageServerConnection sharedInstance] getUserClasters:_status withFriendStatus:_isfriend withCountry:_country withCity:_city withSex:_sex withMinage:_minage andMaxAge:_maxage withMask:_mask withBottomLeftLatitude:_swlat withBottomLeftLongtitude:_swlng withtopCoordinate:_nelat withTopRigthLongtitude:_nelng withCallback:^(NSDictionary *result) {
        NSMutableArray <CKClusterModel *> *clusterlist = [NSMutableArray new];
        for (NSDictionary *i in result[@"result"])
        {
            CKClusterModel *cluster1 = [CKClusterModel modelWithDictionary:i];
            [clusterlist addObject: cluster1];
        }
        _clusterlist = clusterlist;
        
    }];
}

- (void) restoreProfile:(bool) restore
{
    
    if (!restore) {
//        [Users sharedInstance].currentUser = nil;
        
        NSString* operation = @"restore";
        [_mainController beginOperation:operation];
        
        [[CKMessageServerConnection sharedInstance] cleanallHistory:^(NSDictionary *result) {
            [_mainController endOperation:operation];
   
            if ([result socketMessageStatus] == S_OK){
                 [[self mainController] showProfile:NO];
            }else{
                [_mainController showAlertWithResult:result completion:nil];
            }
        }];
    }else{
        [[self mainController] showProfile:YES];
    }
    
    
}

- (void)submitNewProfile
{
    NSString* operation = @"user.create";
    [_mainController beginOperation:operation];
    
    CKUser* userProfile = [[Users sharedInstance] currentUser];
    [userProfile save];
    [[CKUserServerConnection sharedInstance] createUserWithName:userProfile.name
                                                        surname:userProfile.surname
                                                          login:userProfile.login
                                                         avatar:userProfile.avatar
                                                      birthdate:[NSDate date2str:userProfile.birthDate ]
                                                            sex:userProfile.sex
                                                        country:userProfile.countryId
                                                           city:userProfile.city callback:^(NSDictionary *result) {
                                                               [_mainController endOperation:operation];
                                                               if ([result socketMessageStatus] == S_OK){
                                                                   [self showMainScreen];
                                                               }else{
                                                                   [_mainController showAlertWithResult:result completion:nil];
                                                               }
                                                           }];
}

// core location stuff

- (void)setupLocationService
{
    // проверить, включен ли локейшен сервис на телефоне.
    if([CLLocationManager locationServicesEnabled])
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        
        // проверить авторизацию
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        _locationAuthorizationStatus = authorizationStatus;
        if(authorizationStatus == kCLAuthorizationStatusNotDetermined)
        {
            [_locationManager requestWhenInUseAuthorization];
        }
        else
        {
            // если все ок, то запускаем определение места
            [self runUpdatingLocation];
        }
    }
    else
    {
        // Алерт с просьбой включить сервис в настройках
    }
}

- (void)runUpdatingLocation
{
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager startMonitoringSignificantLocationChanges];
    
    
    [_locationManager startUpdatingLocation];
}

// обработать коллбэки делегата
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if((status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorizedWhenInUse))
    {
        _locationAuthorizationStatus = status;
        [self runUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
//    _location = nil;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    _location = newLocation;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    _location = [locations lastObject];
}



- (void)storeChat:(CKChatModel *)model withId:(NSString *)id
{
    _chatPool[id] = model;
}

- (CKChatModel *)getChatModelWithId:(NSString *)id
{
    return _chatPool[id];
}

-(CLLocation*) location{
    return _location;
};

- (void) getLocationInfowithCallback:(CKServerConnectionExecutedObject)callback{
    
    __block NSMutableDictionary* info;
    
    if (_location) {
        CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
        [reverseGeocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
            // NSLog(@"Received placemarks: %@", placemarks);
            CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
            
            NSString *cityName = [[myPlacemark addressDictionary] objectForKey:@"City"];
            NSString *countryName = [[myPlacemark addressDictionary] objectForKey:@"Country"];
//            NSString *cuntryCode = [[myPlacemark addressDictionary] objectForKey:@"CountryCode"];
            
            NSLocale *locale = [NSLocale currentLocale];
            NSString *localeCode = [[locale objectForKey: NSLocaleCountryCode] lowercaseString];
            
            [[CKUserServerConnection sharedInstance] getCountriesWithMask:[countryName lowercaseString] locale:localeCode callback:^(NSDictionary *resultCountry) {
                if ([resultCountry socketMessageResult]) {
                    NSArray* countries = [resultCountry socketMessageResult];
                    if (countries.count) {
                        info = [[NSMutableDictionary alloc] initWithDictionary:[countries firstObject]];
                        [[CKUserServerConnection sharedInstance] getCitiesInCountry:[info[@"countryid"] integerValue] mask:[cityName lowercaseString] locale:localeCode callback:^(NSDictionary *resultCity) {
                            NSArray* cyties = [resultCity socketMessageResult];
                            NSDictionary* city =  [cyties firstObject];
                            if (city){
                                [info addEntriesFromDictionary:city];
                            }
                            callback(info);
                        }];
                    }else{
                         callback(nil);
                    }
                
                }else{
                    callback(nil);
                }
            }];
        }];
    }else{
        callback(nil);
    }
    
}


- (void)testInternetConnection:(NetworkReachable) reachableBlock unreachableBlock:(NetworkUnreachable) unreachableBlock
{
    _internetReachable = [Reachability reachabilityWithHostname:CK_URL_BASE];
    // Internet is reachable
    _internetReachable.reachableBlock = reachableBlock;
    // Internet is not reachable
    _internetReachable.unreachableBlock = unreachableBlock;
    [_internetReachable startNotifier];
}

#pragma mark - chats


-(void) startPrivateChat:(CKUser*) user{
}

-(void) startMultipleChat:(NSArray*) userIds{
}

-(void) startGroupChat:(CKGroupChatModel*) group{
}

-(void) restartRecentChat:(CKDialogModel*) dialog{
    //необходимо в зависимости от типа возвращать модель
    _currentChat = [[CKDialogChatModel alloc] initWithDialog:dialog];
    [self.mainController startChat:_currentChat];
}

-(void)messageResived:(NSNotification *)notification{
    [[CKDialogsModel sharedInstance] loadDialogList];
    Message* message = [Message modelWithDictionary:notification.userInfo];
    [Message update:notification.userInfo];
    if ([_currentChat messageMatch:message]) {
        [_currentChat reloadMessages];
        //    [[CKMessageServerConnection sharedInstance] setMessagesStatus:CKMessageStatusRead messages:@[messageId] callback:^(NSDictionary *result) {
        //
        //    }];i
    }else{
        NSString* title = @"Messme";
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:title
                                     message:message.text
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle your yes please button action here
                                   }];
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           //Handle your yes please button action here
                                       }];
        [alert addAction:okButton];
        [alert addAction:cancelButton];
        [self.mainController.currentController presentViewController:alert animated:YES completion:nil];
    }
}

-(NSString*)userPhone{
    return _userPhone;
}
@end
