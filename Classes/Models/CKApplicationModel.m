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

@implementation CKUserModel

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
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTF"];
        [dateFormatter setDateFormat:@"YYYY-MM-DDThh:mm:ss"];
        model.birthDate = [dateFormatter dateFromString:sourceDict[@"birthdate"]];
        model.registeredDate = [dateFormatter dateFromString:sourceDict[@"registereddate"]];
        model.statusDate = [dateFormatter dateFromString:sourceDict[@"statusdate"]];
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
    
    if (!surname && !name) name = self.login;
    
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

@end

@implementation CKPhoneContact

@end

@interface CKApplicationModel()<CLLocationManagerDelegate>

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
    if (self.token == nil)
    {
        [self.mainController showWelcomeScreen];
    } else {
        [[CKUserServerConnection sharedInstance] getUserInfoWithId:_userPhone callback:^(NSDictionary *result) {
            CKUserModel *profile = [CKUserModel modelWithDictionary:result[@"result"]];
            if (!profile)
            {
                // error
                NSLog(@"error!");
            } else
            {
                self.userProfile = profile;
                [self showMainScreen];
            }
        }];
    }
}

- (void) userDidAcceptTerms
{
    [self.mainController showLoginScreen];
}

- (NSDictionary *)countryWithISO:(NSInteger)iso
{
    CKDB *ckdb = [CKDB sharedInstance];

    NSMutableString *query = [NSMutableString stringWithFormat:@"select * from countries where iso=%ld", (long)iso];
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

- (void) sendUserPhone:(NSString *)phone promo:(NSString *)promo
{
    phone = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    _userPhone = phone;
    [CKUserServerConnection sharedInstance].phoneNumber = phone;
    [CKMessageServerConnection sharedInstance].phoneNumber = phone;
    
    [[CKMessageServerConnection sharedInstance] connectWithCallback:^(NSDictionary *result) {
        NSInteger status = [result[@"status"] integerValue];
        NSInteger res = [result[@"result"] integerValue];
        NSString* action = @"getUserState";
        
        
        _isNewUser = YES;
        
        if (status == 2205) {
            
            
            switch (res) {
                    
                    case 1:
                    NSLog(@"1 - пользователь заблокирован");
                    _isNewUser = NO;
                    break;
                    
                    case 2:
                    NSLog(@"2 - пользователь не активирован");
                    
                    _isNewUser = NO;
                    break;
                    
                    case 3:
                    NSLog(@"3 - пользователь есть но не совпадает uuid или deviceid, то есть новое устройство");
                    _isNewUser = NO;
                    break;
                    
                    case 4:
                    NSLog(@"4 - пользователя в базе нет");
                    _isNewUser = YES;
                    break;
                    
                    case 5:
                    NSLog(@"5 - не заполнен профиль, регистрация прошла не до конца");
                    _isNewUser = NO;
                    break;
                default:
                    break;
            }
            [[CKUserServerConnection sharedInstance] registerUserWithPromo:promo?promo:@"" callback:^(NSDictionary *result) {
                [[CKUserServerConnection sharedInstance] getActivationCode:^(NSDictionary *result) {
                    [self.mainController showAuthenticationScreen];
                }];
            }];
        }else{
            //Выводим сообщение
            [[[CKApplicationModel sharedInstance] mainController] showAlertWithAction:action result:res status:status completion:nil];
        }
        

    }];
    
//    [[CKUserServerConnection sharedInstance] checkUserWithCallback:^(NSInteger status) {

        
//        if (status == 1000)
//        {
//            NSLog(@"new user");
//            _isNewUser = YES;
//        } else
//        {
//            NSLog(@"existing user");
//        }
//        [[CKUserServerConnection sharedInstance] registerUserWithPromo:promo?promo:@"" callback:^(NSDictionary *result) {
//            [[CKUserServerConnection sharedInstance] getActivationCode:^(NSDictionary *result) {
//                [self.mainController showAuthenticationScreen];
//            }];
//        }];

//    }];
}

- (void)sendPhoneAuthenticationCode:(NSString *)code
{
    [[CKUserServerConnection sharedInstance] activateUserWithCode:code callback:^(NSInteger status) {
        if (status == 1000)
        {
            self.token = [[CKUserServerConnection sharedInstance] token];
            [CKMessageServerConnection sharedInstance].token = self.token;
            if (_isNewUser)
            {
                [self.mainController showCreateProfile];
            } else
            {
                [[CKUserServerConnection sharedInstance] getUserInfoWithId:_userPhone callback:^(NSDictionary *result) {
                    CKUserModel *profile = [CKUserModel modelWithDictionary:result[@"result"]];
                    if (!profile)
                    {
                        // error
                        NSLog(@"error!");
                    } else
                    {
                        self.userProfile = profile;
                        [self.mainController showRestoreHistory];
                    }
                }];
            }
        }else{
            //вывести ошибку про пароль
        }
        
    }];
}

- (void)requestAuthentication
{
    
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
        [[CKMessageServerConnection sharedInstance] addFriends:[self contactPhoneList] callback:^(NSInteger status) {
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

- (void) restoreHistory
{
    [self showMainScreen];
}

- (void) abandonHistory
{
    [self showMainScreen];
}

+(NSString*)date2str:(NSDate*)date {
    if (!date) return @"Не указана";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}

- (void)submitNewProfile
{
    [[CKUserServerConnection sharedInstance] createUserWithName:self.userProfile.name
                                                        surname:self.userProfile.surname
                                                          login:self.userProfile.login
                                                         avatar:self.userProfile.avatar
                                                      birthdate:[CKApplicationModel date2str:self.userProfile.birthDate]
                                                            sex:self.userProfile.sex
                                                        country:self.userProfile.countryId
                                                           city:self.userProfile.city callback:^(NSInteger status) {
                                                               [self showMainScreen];
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
            if([[contact.phoneNumber substringToIndex:1] isEqualToString:@"8"]) {
                contact.phoneNumber = [NSString stringWithFormat:@"%@%@", @"7", [contact.phoneNumber substringFromIndex:1]];
            }
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

@end
