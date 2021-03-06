//
//  CKUserServerConnection.m
//  click
//
//  Created by Igor Tetyuev on 26.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKUserServerConnection.h"

@implementation CKUserServerConnection

+ (instancetype)sharedInstance
{
    static CKUserServerConnection *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [CKUserServerConnection new];
    });
    
    return instance;
}

-(NSString*)entryPoint{
    return @"User";
}

- (void)registerUserWithPromo:(NSString *)promo callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{CKSocketMessageFieldAction:@"user.register",
                     CKSocketMessageFieldOptions:@{CKSocketMessageFieldInvite:promo?promo:@"" }} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)getUserInfoWithId:(NSString *)userid callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"user.info", @"options":@{@"locale":@"ru", @"userid":userid}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)checkUserWithCallback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"user.checkuser", @"options":@{@"userid":self.phoneNumber}} completion:^(NSDictionary *result) {
        callback( result );
     }];
}

- (void)getActivationCode:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"user.getactivationcode"} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)activateUserWithCode:(NSString *)code callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"user.activate", @"options":@{@"code":code}} completion:^(NSDictionary *result) {
        if ([result socketMessageStatus] == S_OK){
            self.token = result[@"result"];
        }
        callback(result);
     } ];
}

- (void)suicide:(CKServerConnectionExecutedStatus)callback
{
    [self sendData:@{@"action":@"user.suicide"} completion:^(NSDictionary *result) {
        callback((CKStatusCode) result[@"status"]);
    }];
}

- (void)getCountriesWithMask:(NSString*)mask locale:(NSString*)locale callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"geo.country.list", @"options":@{@"continent":@[],@"locale":locale ? locale : @"",@"filter":@[], @"mask":mask ? mask : @"" }} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)getCitiesInCountry:(NSInteger)countryId mask:(NSString*)mask locale:(NSString*)locale callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"geo.city.list", @"options":@{@"continent":@[],@"country":@[@(countryId)], @"region":@[],@"locale":locale ? locale : @"",@"filter":@[], @"mask":mask ? mask : @""}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void) setUserStatus: (NSNumber *)status
{
    [self sendData:@{@"action":@"user.setstatus", @"options":@{@"status":[NSNumber numberWithInteger: [status integerValue]]}} completion: nil];
}

- (void)getRegionsInCountry:(NSInteger)countryId callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"geo.region.list", @"options":@{@"continent":@[],@"country":@[@(countryId)], @"locale":@"ru",@"filter":@[], @"mask":@""}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)createUserWithName:(NSString *)name surname:(NSString *)surname login:(NSString *)login avatar:(UIImage *)avatar birthdate:(NSString *)birthdate sex:(NSString *)sex country:(NSUInteger)country city:(NSUInteger)city callback:(CKServerConnectionExecuted)callback {
    [self sendData:@{@"action":@"user.create", @"options": @{@"name":name, @"login":login,@"surname":surname, @"birthdate":birthdate, @"sex":sex, @"avatar":avatar?[UIImagePNGRepresentation(avatar) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]:@"", @"country":@(country), @"city":@(city)}} completion:^(NSDictionary *result) {
            callback(result);
     } ];
}

- (void)checkUserLogin:(NSString*) login withCallback:(CKServerConnectionExecutedObject)callback
{
    [self sendData:@{@"action":@"user.checklogin", @"options":@{@"login":login}} completion:^(NSDictionary *result) {
        callback( @([result socketMessageStatus] == S_OK));
    }];
}

- (void) getUserListForGeoLocation:(CKServerConnectionExecuted)callback{
    [self sendData:@{@"action": @"user.geolist", @"options":@{@"userlist":@[], @"status": @0, @"isfriend": @0, @"country": @0, @"city": @0, @"sex": @"", @"minage": @0, @"maxage": @0, @"mask": @"", @"lat": @0, @"lng": @0, @"radius": @0, @"count": @0}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}



@end
