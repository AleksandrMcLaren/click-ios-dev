//
//  CKApplicationModel.h
//  click
//
//  Created by Igor Tetyuev on 09.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CKDialogsModel.h"
#import "CKServerConnection.h"

@class CKChatModel;

@interface CKUserModel : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, assign) NSString *sex;
@property (nonatomic, assign) NSInteger iso;
@property (nonatomic, assign) NSInteger countryId;
@property (nonatomic, strong) NSString *countryName;
@property (nonatomic, assign) NSInteger city;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSString *avatarName;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *invite;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) double distance;
@property (nonatomic, assign) NSInteger geoStatus;
@property (nonatomic, assign) BOOL isFriend;
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) NSDate *birthDate;
@property (nonatomic, strong) NSDate *registeredDate;
@property (nonatomic, strong) NSDate *statusDate;

@property (nonatomic, readonly) NSString *commonName;
@property (nonatomic, readonly) NSString *letterName;

+ (instancetype)modelWithDictionary:(NSDictionary *)sourceDict;

@end

@interface CKPhoneContact : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *id;
@end;

@protocol CKMainControllerProtocol <NSObject>

- (void) showWelcomeScreen;
- (void) showLoginScreen;
- (void) showAuthenticationScreen;
- (void) showMainScreen;
- (void) showRestoreHistory;
- (void) showCreateProfile;
- (void) showAlertWithTitle:(NSString*) title message:(NSString*) message completion:(void (^)(void))completion;
- (void) showAlertWithAction:(NSString*) action result:(NSInteger) result status:(NSInteger) status completion:(void (^)(void))completion;
- (id<CKDialogsControllerProtocol>) dialogsController;

@end

@interface CKApplicationModel : NSObject

@property (nonatomic, assign) id<CKMainControllerProtocol>mainController;

+ (instancetype)sharedInstance;

- (void) didStarted;
- (void) userDidAcceptTerms;
- (void) sendUserPhone:(NSString *)phone promo:(NSString *)promo;
- (void) requestAuthentication;
- (void) sendPhoneAuthenticationCode:(NSString *)code;
- (void) restoreHistory;
- (void) abandonHistory;
- (void) submitNewProfile;


// определять по местоположению пользователя
@property (nonatomic, readonly) NSInteger countryId;

- (NSDictionary *)countryWithId:(NSInteger)id;
- (NSDictionary *)countryWithISO:(NSInteger)iso;

// данные пользователя
@property (nonatomic, readonly) CKUserModel *userProfile;

@property (nonatomic, readonly) NSArray *phoneContacts;
@property (nonatomic, readonly) NSArray *friends;


// пул чатов
- (void)storeChat:(CKChatModel *)model withId:(NSString *)id;
- (CKChatModel *)getChatModelWithId:(NSString *)id;


@end
