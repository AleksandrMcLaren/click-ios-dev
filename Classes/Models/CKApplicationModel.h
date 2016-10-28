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
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CKOperationsProtocol.h"

@class CKChatModel;

@interface CKUserModel : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, strong) NSString *sex;
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
@property (nonatomic, strong, readonly) NSString* avatarURLString;
@property (nonatomic, assign, readonly) BOOL isCreated;



+ (instancetype)modelWithDictionary:(NSDictionary *)sourceDict;

@property (strong, nonatomic) RACCommand *executeSearch;

@end

@interface CKPhoneContact : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *id;
@end;

@protocol CKMainControllerProtocol <NSObject, CKOperationsProtocol>

@property (nonatomic, strong, readonly) UIViewController* currentController;

- (void) showWelcomeScreen;
- (void) showLoginScreen;
- (void) showAuthenticationScreen;
- (void) showMainScreen;
- (void) showRestoreHistory;
- (void) showCreateProfile;
- (void) showAlertWithResult:(NSDictionary*)result completion:(void (^)(void))completion;
- (id<CKDialogsControllerProtocol>) dialogsController;

@end

@interface CKApplicationModel : NSObject

@property (nonatomic, assign) id<CKMainControllerProtocol>mainController;
@property (nonatomic, strong, readonly) CLLocation* location;

+ (instancetype)sharedInstance;

- (void) didStarted;
- (void) userDidAcceptTerms;
- (void) sendUserPhone:(NSString *)phone promo:(NSString *)promo;
- (void) checkUserLogin:(NSString *)login withCallback:(CKServerConnectionExecutedObject)callback;
- (void) requestAuthentication;
- (void) sendPhoneAuthenticationCode:(NSString *)code;
- (void) restoreHistoryWithCallback:(CKServerConnectionExecuted)callback;
- (void) abandonHistory;
- (void) submitNewProfile;
- (void) getLocationInfowithCallback:(CKServerConnectionExecutedObject)callback;
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
