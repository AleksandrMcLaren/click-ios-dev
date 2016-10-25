//
//  CKUserServerConnection.h
//  click
//
//  Created by Igor Tetyuev on 26.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKServerConnection.h"

@interface CKUserServerConnection : CKServerConnection

- (void)registerUserWithPromo:(NSString *)promo callback:(CKServerConnectionExecuted)callback;
- (void)createUserWithName:(NSString *)name
                   surname:(NSString *)surname
                     login:(NSString *)login
                    avatar:(UIImage *)avatar
                 birthdate:(NSString *)birthdate
                       sex:(NSString *)sex
                   country:(NSUInteger)country
                      city:(NSUInteger)city
                  callback:(CKServerConnectionExecuted)callback;
- (void)checkUserWithCallback:(CKServerConnectionExecuted)callback;
- (void)activateUserWithCode:(NSString *)code callback:(CKServerConnectionExecuted)callback;
- (void)getUserInfoWithId:(NSString *)userid callback:(CKServerConnectionExecuted)callback;
- (void)suicide:(CKServerConnectionExecutedStatus)callback;
- (void)getRegionsInCountry:(NSInteger)countryId callback:(CKServerConnectionExecuted)callback;
- (void)getCitiesInCountry:(NSInteger)countryId callback:(CKServerConnectionExecuted)callback;
- (void)getActivationCode:(CKServerConnectionExecuted)callback;
- (void)checkUserLogin:(NSString*) login withCallback:(CKServerConnectionExecutedObject)callback;
@end
