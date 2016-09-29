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

- (void)connect
{
    [self connect:@"User"];
}

- (void)registerUserWithPromo:(NSString *)promo callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"user.register", @"options":@{@"invite":promo}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)getUserInfoWithId:(NSString *)userid callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"user.info", @"options":@{@"locale":@"ru", @"userid":userid}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)checkUserWithCallback:(CKServerConnectionExecutedStatus)callback
{
    [self sendData:@{@"action":@"user.checkuser", @"options":@{@"userid":self.phoneNumber}} completion:^(NSDictionary *result) {
        callback([result[@"status"] integerValue]);
    }];
}

- (void)getActivationCode:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"user.getactivationcode"} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)activateUserWithCode:(NSString *)code callback:(CKServerConnectionExecutedStatus)callback
{
    [self sendData:@{@"action":@"user.activate", @"options":@{@"code":code}} completion:^(NSDictionary *result) {
        if ([result[@"status"] integerValue] == 1000 && result[@"result"])
        {
            self.token = result[@"result"];
            [self connect];
        }
        callback([result[@"status"] integerValue]);
    }];
}

- (void)suicide:(CKServerConnectionExecutedStatus)callback
{
    [self sendData:@{@"action":@"user.suicide"} completion:^(NSDictionary *result) {
        callback([result[@"status"] integerValue]);
    }];
}

- (void)getCitiesInCountry:(NSInteger)countryId callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"geo.city.list", @"options":@{@"continent":@[],@"country":@[@(countryId)], @"region":@[],@"locale":@"ru",@"filter":@[], @"mask":@""}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)getRegionsInCountry:(NSInteger)countryId callback:(CKServerConnectionExecuted)callback
{
    [self sendData:@{@"action":@"geo.region.list", @"options":@{@"continent":@[],@"country":@[@(countryId)], @"locale":@"ru",@"filter":@[], @"mask":@""}} completion:^(NSDictionary *result) {
        callback(result);
    }];
}

- (void)createUserWithName:(NSString *)name surname:(NSString *)surname login:(NSString *)login avatar:(UIImage *)avatar birthdate:(NSString *)birthdate sex:(NSString *)sex country:(NSUInteger)country city:(NSUInteger)city callback:(CKServerConnectionExecutedStatus)callback {
    [self sendData:@{@"action":@"user.create", @"options": @{@"name":name, @"login":login,@"surname":surname, @"birthdate":birthdate, @"sex":sex, @"avatar":avatar?[UIImagePNGRepresentation(avatar) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]:@"", @"country":@(country), @"city":@(city)}} completion:^(NSDictionary *result) {
        callback([result[@"status"] integerValue]);
    }];
}

@end
