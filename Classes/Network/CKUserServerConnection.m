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

- (void)getUserInfoWithId:(NSString *)userid callback:(CKServerConnectionExecutedObject)callback needDisplayAlert:(bool)needDisplayAlert
{
    [self sendData:@{@"action":@"user.info", @"options":@{@"locale":@"ru", @"userid":userid}} completion:^(NSDictionary *result) {
        [self connect];
        
        CKUserModel *profile;
        
        if ([result socketMessageStatus] == S_OK) {
            profile = [CKUserModel modelWithDictionary:result[@"result"]];
        }else if ([result socketMessageStatus] == S_REQUEST_ERROR){
            profile = [CKUserModel new];
        }
            
        if (profile || !needDisplayAlert) {
            callback(profile);
        }else{
            [[[CKApplicationModel sharedInstance] mainController] showAlertWithResult:result completion:nil];
        }
    }];
}

- (void)checkUserWithCallback:(CKServerConnectionExecuted)callback
{
    [self sendDataWithAlert:@{@"action":@"user.checkuser", @"options":@{@"userid":self.phoneNumber}} successfulCompletion:^(NSDictionary *result) {
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
    [self sendDataWithAlert:@{@"action":@"user.activate", @"options":@{@"code":code}} successfulCompletion:^(NSDictionary *result) {
        self.token = result[@"result"];
         callback(result);
    }];
}

- (void)suicide:(CKServerConnectionExecutedStatus)callback
{
    [self sendData:@{@"action":@"user.suicide"} completion:^(NSDictionary *result) {
        callback((CKStatusCode) result[@"status"]);
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
    [self sendDataWithAlert:@{@"action":@"user.create", @"options": @{@"name":name, @"login":login,@"surname":surname, @"birthdate":birthdate, @"sex":sex, @"avatar":avatar?[UIImagePNGRepresentation(avatar) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]:@"", @"country":@(country), @"city":@(city)}} successfulCompletion:^(NSDictionary *result) {
            callback((CKStatusCode) result[@"status"]);
    }];
}

- (void)checkUserLogin:(NSString*) login withCallback:(CKServerConnectionExecutedObject)callback
{
    [self sendData:@{@"action":@"user.checklogin", @"options":@{@"login":login}} completion:^(NSDictionary *result) {
        callback( @([result socketMessageStatus] == S_OK));
    }];
}

@end
