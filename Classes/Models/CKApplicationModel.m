//
//  CKApplicationModel.m
//  click
//
//  Created by Igor Tetyuev on 09.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKApplicationModel.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <Contacts/Contacts.h>
#import <FMDB/FMDB.h>
#import "CKServerConnection.h"
#import "CKUserServerConnection.h"
#import "CKMessageServerConnection.h"
#import "Reachability.h"
#import "CKCache.h"
#import <SDWebImage/UIImageView+WebCache.h>

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

@implementation CKUserModel

-(void)initizlize{
    self.id = nil;
    self.login = @"";
    self.name = @"";
    self.surname = @"";
    self.sex = @"";
    self.avatarName = nil;
    self.iso = -1;
    self.countryId = 0;
    self.countryName = nil;
    self.city = 0;
    self.cityName = nil;
    self.status = 0;
    self.invite = nil;
    self.location = kCLLocationCoordinate2DInvalid;
    self.distance = 0;
    self.geoStatus = 0;
    self.isFriend = NO;
    self.likes = 0;
    self.isLiked = NO;
    self.age = 0;
    self.birthDate = nil;
    self.registeredDate = nil;
    self.statusDate = nil;
    self.avatar = nil;
}

-(instancetype)init{
    if (self = [super init]) {
        [self initizlize];
    }
    return self;
}

- (RACSignal *)executeSearchSignal {
    return [[[[RACSignal empty]
              logAll]
             delay:2.0]
            logAll];
}


+ (instancetype)modelWithDictionary:(NSDictionary *)sourceDict
{
    CKUserModel *model = [CKUserModel new];
    
    @try {
        model.id = [NSString stringWithFormat:@"%@", sourceDict[@"id"]];
        model.login = sourceDict[@"login"];
        model.name = sourceDict[@"name"];
        model.surname = sourceDict[@"surname"];
        model.sex = sourceDict[@"sex"];
        model.avatarName = sourceDict[@"avatar"];
        model.iso = [sourceDict[@"iso"] integerValue];
        model.countryId = [sourceDict[@"country"] integerValue];
        model.countryName = sourceDict[@"countryname"];
        model.city = [sourceDict[@"city"] integerValue];
        model.cityName = sourceDict[@"cityname"];
        if (![sourceDict[@"avatar"] isKindOfClass:[NSNull class]] && [sourceDict[@"avatar"] length]) model.avatar = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:(NSString *)sourceDict[@"avatar"] options:0]];
        model.status = [sourceDict[@"status"] integerValue];
        model.invite = sourceDict[@"invite"];
        model.location = CLLocationCoordinate2DMake([sourceDict[@"lat"] doubleValue], [sourceDict[@"lon"] doubleValue]);
        model.distance = [sourceDict[@"distance"] doubleValue];
        model.geoStatus = [sourceDict[@"geostatus"] integerValue];
        model.isFriend = [sourceDict[@"isfriend"] boolValue];
        model.likes = [sourceDict[@"likes"] integerValue];
        model.isLiked = [sourceDict[@"isliked"] boolValue];
        model.age = [sourceDict[@"age"] integerValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss"];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTF"];
        
        model.birthDate =  [sourceDict[@"birthdate"] isEqualToString:@"0001-01-01T00:00:00"] ? nil : [dateFormatter dateFromString:sourceDict[@"birthdate"]];
        model.registeredDate =  [sourceDict[@"registereddate"] isEqualToString:@"0001-01-01T00:00:00"] ? nil :[dateFormatter dateFromString:sourceDict[@"registereddate"]];
        model.statusDate =  [sourceDict[@"statusdate"] isEqualToString:@"0001-01-01T00:00:00"] ? nil :[dateFormatter dateFromString:sourceDict[@"statusdate"]];
    } @catch (NSException *exception) {
        return nil; // bad model
    }

    return model;
}

- (NSString *)commonName
{
    NSMutableString *result = [NSMutableString new];
    NSString *surname = self.surname;
    NSString *name = self.name;
    
    if (!surname && !name) name = self.login;
    
    if (surname)
    {
        surname = name;
        name = nil;
    }
    
    if (name)
    {
        [result appendString:name];
        if (surname) [result appendString:@" "];
    }
    if (surname)
    {
        [result appendString:surname];
    }
    
    return result;
}

- (NSString *)letterName
{
    NSString *surname = self.surname;
    NSString *name = self.name;
    NSString *login = self.login;
    
    if (!surname && !name) name = login;
    
    if ([surname isEqual:@""] && [name isEqual:@""]) name = login;
    
    if (!surname)
    {
        surname = name;
        name = nil;
    }
    if (name.length) return [name substringToIndex:1];
    return nil;
}

- (BOOL)isEqual:(CKUserModel *)object
{
    if ([object isKindOfClass:[CKUserModel class]]) return NO;
    return [self.id isEqual:object.id];
}

- (NSUInteger)hash
{
    return [self.id hash];
}

-(NSString*)avatarURLString{
    return [NSString stringWithFormat:@"%@%@", CK_URL_AVATAR, self.avatarName];
}

-(BOOL)isCreated{
    return self.id != nil;
}

-(void)setAvatar:(UIImage *)avatar{
    
    CGFloat maxSize = 300;
    if (avatar) {
        if (MIN(avatar.size.height, avatar.size.width) > maxSize) {
            CGFloat k = maxSize / MAX(avatar.size.height, avatar.size.width);
            
            CGSize newSize = CGSizeMake(avatar.size.width*k, avatar.size.height*k);
            UIGraphicsBeginImageContext(newSize);
            [avatar drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            avatar = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    
    _avatar = avatar;
}

@end

@implementation CKPhoneContact

@end

@interface CKApplicationModel()<CLLocationManagerDelegate>{
    Reachability* _internetReachable;
}

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) CKUserModel *userProfile;

@end

@implementation CKApplicationModel
{
    NSString *_token;
    NSString *_userPhone;
    CLLocationManager *_locationManager;
    CLAuthorizationStatus _locationAuthorizationStatus;
    CLLocation *_location;
    BOOL _isNewUser;
    NSDictionary *_phoneContacts;
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
    
    NSNumber *_userLat;
    NSNumber *_userLng;

}

- (instancetype)init
{
    if (self = [super init])
    {
        _token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        _userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNumber"];
        _countryId = 2017370;
        _isNewUser = NO;
        _chatPool = [NSMutableDictionary new];
        if (self.token) {
            [CKUserServerConnection sharedInstance].token = self.token;
            [CKUserServerConnection sharedInstance].phoneNumber = _userPhone;
            
            [CKMessageServerConnection sharedInstance].token = self.token;
            [CKMessageServerConnection sharedInstance].phoneNumber = _userPhone;

        }

    }
    return self;
}

- (void)setToken:(NSString *)token
{
    _token = token;
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] setObject:_userPhone forKey:@"phoneNumber"];

}

- (CKUserModel *)userProfile
{
    if (!_userProfile)
    {
        _userProfile = [CKUserModel new];
        NSDictionary *country = [[CKApplicationModel sharedInstance] countryWithId:self.countryId];
        _userProfile.iso = [country[@"iso"] integerValue];
        _userProfile.countryName = country[@"name"];
        _userProfile.countryId = self.countryId;
    }
    return _userProfile;
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
    [self deviceLocation];
    [[CKMessageServerConnection sharedInstance] setLocaion:_userLat andLng:_userLng];
    
    if (self.token == nil)
    {
        [self.mainController showWelcomeScreen];
    } else {
        [[CKUserServerConnection sharedInstance] getUserInfoWithId:_userPhone callback:^(NSDictionary* result) {
            if ([result socketMessageStatus] == S_OK){
                CKUserModel* profile = [CKUserModel modelWithDictionary:[result socketMessageResult]];
                self.userProfile = profile;
                [self showMainScreen];
            }else{
                [_mainController showAlertWithResult:result completion:nil];
            }

        }];
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
    
//    [self testInternetConnection:^(Reachability *reachability) {
//        [_internetReachable stopNotifier];
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
//    } unreachableBlock:^(Reachability *reachability) {
//        [_internetReachable stopNotifier];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [_mainController endOperation:operation];
//            [_mainController showAlertWithResult:nil completion:nil];
//        });
//
//    }];
    

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
                
                CKUserModel *profile;
                
                if ([result socketMessageStatus] == S_OK ) {
                    profile = [CKUserModel modelWithDictionary:[result socketMessageResult]];
                    if (![[CKApplicationModel sharedInstance] countryExistWithId:profile.countryId]) {
                        NSDictionary *country = [[CKApplicationModel sharedInstance] countryWithId:self.countryId];
                        profile.iso = [country[@"iso"] integerValue];
                        profile.countryName = country[@"name"];
                        profile.countryId = self.countryId;
                    }
                    self.userProfile = profile;
                }else {
                    profile = [[CKApplicationModel sharedInstance] userProfile];
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

- (NSArray *)phoneContacts
{
    NSMutableDictionary *contactsByPhone = [NSMutableDictionary new];
    for (CKPhoneContact *i in [_phoneContacts allValues])
    {
        contactsByPhone[i.phoneNumber] = i;
    }
    NSLog(@"%@", contactsByPhone);
    for (CKUserModel *i in _friends)
    {
        NSLog(@"%@ %@", i.id, contactsByPhone[i.id]);
        [contactsByPhone removeObjectForKey:i.id];
    }
    NSLog(@"%@", contactsByPhone);
    return [contactsByPhone allValues];
}

- (NSArray *)contactPhoneList
{
    return [_phoneContacts allKeys];
}

- (void)showMainScreen
{
    
    [self fetchContactsWithCompletion:^(NSMutableArray *arr) {
        
        NSMutableDictionary *d = [NSMutableDictionary new];
        for (CKPhoneContact *i in arr)
        {
            d[i.phoneNumber] = i;
        }
        _phoneContacts = d;
        NSMutableArray *cont = [NSMutableArray new];
        [cont addObjectsFromArray:[_phoneContacts allValues]];
        _fullContacts = cont;
        [[CKMessageServerConnection sharedInstance] addFriends:[self contactPhoneList] callback:^(CKStatusCode status) {
            [[CKMessageServerConnection sharedInstance] getUserListWithFilter:[CKUserFilterModel filterWithAllFriends] callback:^(NSDictionary *result) {
                
                NSMutableArray *friends = [NSMutableArray new];
                for (NSDictionary *i in result[@"result"])
                {
                    CKUserModel *user = [CKUserModel modelWithDictionary:i];
                    CKPhoneContact *contact;
                    if ((contact = _phoneContacts[user.id]))
                    {
                        user.name = contact.name;
                        user.surname = contact.surname;
                    }
                    [friends addObject:user];
                }
                _friends = friends;
                [self.mainController showMainScreen];
                [[CKDialogsModel sharedInstance] setDialogsController:[self.mainController dialogsController]];
                [[CKDialogsModel sharedInstance] run];
            }];
        }];
        
    }];
}

- (void) logOut
{
    _token = nil;
    _userPhone = nil;
    [self setToken:nil];
    [CKUserServerConnection sharedInstance].token = _token;
    [CKUserServerConnection sharedInstance].phoneNumber = _userPhone;
    //NSString *str = [NSString stringWithFormat:@"%@",[CKServerConnection sharedInstance].token];
    //NSLog(@" WARNING_1 %@", str);
    //NSLog(@"%@",[CKServerConnection sharedInstance].apnToken);
    [self didStarted];
}

- (void) updateUsers
{
    [[CKMessageServerConnection sharedInstance] getUserListWithFilter:[CKUserFilterModel filterWithLocation] callback:^(NSDictionary *result) {
        NSMutableArray<CKUserModel*> *userlist = [NSMutableArray new];
        for (NSDictionary *i in result[@"result"])
        {
            CKUserModel *user1 = [CKUserModel modelWithDictionary:i];
            [userlist addObject:user1];
        }
        _userlistMain = userlist;
    }];
}

- (void) checkUserProfile: (NSString *)newFriendPhone withCallback: (CKServerConnectionExecutedObject) callback
{
    __block BOOL isFriend = false;
    [[CKUserServerConnection sharedInstance] getUserInfoWithId:newFriendPhone callback:^(NSDictionary *result) {
        //CKUserModel *profile;
        if ([result socketMessageStatus] == S_OK) {
            CKUserModel *user = [CKUserModel new];
            //   profile = [CKUserModel modelWithDictionary:[result socketMessageResult]];
            
            user = [CKUserModel modelWithDictionary:[result socketMessageResult]];
            //user.isFriend = 1;
            NSArray *friends1 = [[CKApplicationModel sharedInstance] friends];
            for (CKUserModel *i in friends1)
            {
                if ([user.id isEqual:i.id])
                {
                    isFriend = true;
                    callback(user);
                    break;
                }
            }
            if (isFriend != true)
            {
                NSMutableArray *friends = [NSMutableArray new];
                [friends addObjectsFromArray:_friends];
                if (user !=nil && ![user.id isEqual:@"0"]) [friends addObject:user];
                _friends = friends;
                NSArray *arr = [NSArray arrayWithObject:user.id];
                [[CKMessageServerConnection sharedInstance] setNewFriend: arr];
                callback(user);
            }
        }
        //[[CKApplicationModel sharedInstance] addNewContactToFriends:user];
    }];
}

- (void) updateFriends
{
    [[CKMessageServerConnection sharedInstance] getUserListWithFilter:[CKUserFilterModel filterWithAllFriends] callback:^(NSDictionary *result) {
        NSMutableArray<CKUserModel*> *userlist = [NSMutableArray new];
        
        for (NSDictionary *i in result[@"result"])
        {
            CKUserModel *user1 = [CKUserModel modelWithDictionary:i];
            [userlist addObject:user1];
        }
        _friends = userlist;
    }];
}

- (void) UpdateUserInfo: (NSString *) userid  callback: (CKServerConnectionExecutedObject) callback
{
    __block CKUserModel *updatedUser = [CKUserModel new];
    [[CKUserServerConnection sharedInstance] getUserInfoWithId:userid callback:^(NSDictionary *result) {
        if ([result socketMessageStatus] == S_OK){
            updatedUser = [CKUserModel modelWithDictionary:[result socketMessageResult]];
            callback(updatedUser);
        }
    }];
}


- (void) addNewContactToFriends
{
    [self fetchContactsWithCompletion:^(NSMutableArray *arr) {
        
        NSMutableDictionary *d = [NSMutableDictionary new];
        for (CKPhoneContact *i in arr)
        {
            d[i.phoneNumber] = i;
        }
        _phoneContacts = d;
        NSMutableArray *cont = [NSMutableArray new];
        [cont addObjectsFromArray:[_phoneContacts allValues]];
        _fullContacts = cont;
    }];
}


- (void) restoreHistoryWithCallback:(CKServerConnectionExecuted)callback
{
    [[CKMessageServerConnection sharedInstance] getDialogListWithCallback:^(NSDictionary *result) {
        callback(result);
    }];
}


- (void) loadClusters: (NSNumber *)status withFriendStatus: (NSNumber *)isfriend withCountry: (NSNumber *)country withCity: (NSNumber *)city withSex: (NSString *)sex withMinage: (NSNumber *)minage andMaxAge: (NSNumber *)maxage withMask: (NSString *)mask withBottomLeftLatitude: (NSNumber *)swlat withBottomLeftLongtitude: (NSNumber *)swlng withtopCoordinate: (NSNumber *)nelat withTopRigthLongtitude: (NSNumber *)nelng withInt: (int) count withCallback: (CKServerConnectionExecutedObject) callback{
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
        callback(clusterlist);
    }];
}

- (void) restoreProfile:(bool) restore
{
    
    if (!restore) {
        self.userProfile = nil;
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
    
    [[CKUserServerConnection sharedInstance] createUserWithName:self.userProfile.name
                                                        surname:self.userProfile.surname
                                                          login:self.userProfile.login
                                                         avatar:self.userProfile.avatar
                                                      birthdate:[NSDate date2str:self.userProfile.birthDate ]
                                                            sex:self.userProfile.sex
                                                        country:self.userProfile.countryId
                                                           city:self.userProfile.city callback:^(NSDictionary *result) {
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


- (void) fetchContactsWithCompletion:(void(^)(NSMutableArray* arr))completion
{
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusDenied) {
        // error
        return;
    }
    
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"No permissions");
            });
            return;
        }
        NSMutableArray *phoneUsers = [NSMutableArray array];
        
        NSError *fetchError;
        NSArray* keys = @[CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactIdentifierKey, [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
        
        CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
        BOOL success = [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
            
            NSString *fullname = [formatter stringFromContact:contact];
            NSArray *phones = contact.phoneNumbers;
            if(fullname && phones.count) {
                CNLabeledValue<CNPhoneNumber*> *first = [phones firstObject];
                CNPhoneNumber* number = first.value;
                NSString* digits = number.stringValue;
                CKPhoneContact *phoneContact = [CKPhoneContact new];
                phoneContact.phoneNumber = digits;
                phoneContact.fullname = fullname;
                phoneContact.name = contact.givenName;
                phoneContact.surname = contact.familyName;
                phoneContact.id = contact.identifier;
                [phoneUsers addObject:phoneContact];
            }
            //
        }];
        if (!success) {
            NSLog(@"error = %@", fetchError);
        }
        // get digits only
        for(int i = 0; i < phoneUsers.count; i++) {
            CKPhoneContact* contact = [phoneUsers objectAtIndex:i];
            NSString* phone = contact.phoneNumber;
            contact.phoneNumber = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
//            if([[contact.phoneNumber substringToIndex:1] isEqualToString:@"8"]) {
//                contact.phoneNumber = [NSString stringWithFormat:@"%@%@", @"7", [contact.phoneNumber substringFromIndex:1]];
//            }
        }
        // remove duplicates
        NSMutableIndexSet* toRemove = [NSMutableIndexSet new];
        for(int i = 0; i < phoneUsers.count; i++) {
            for(int j = 0; j < i; j++) {
                if([[(CKPhoneContact *)phoneUsers[i] phoneNumber] isEqualToString:[(CKPhoneContact *)phoneUsers[j] phoneNumber]]) {
                    [toRemove addIndex:j];
                }
            }
        }
        [phoneUsers removeObjectsAtIndexes:toRemove];

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(phoneUsers);
        });
    }];
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

- (void)deviceLocation
{
    _userLat = [NSNumber numberWithDouble:_locationManager.location.coordinate.latitude];
    _userLng = [NSNumber numberWithDouble:_locationManager.location.coordinate.longitude];
    
}


@end
