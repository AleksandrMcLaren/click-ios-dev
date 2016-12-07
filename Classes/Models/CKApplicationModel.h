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
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <FMDB/FMDB.h>
#import "CKServerConnection.h"
#import "CKUserServerConnection.h"
#import "CKMessageServerConnection.h"
#import "Reachability.h"
#import "CKCache.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "utilities.h"

@class CKChatModel;


@interface CKClusterModel : NSObject

@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSString *clusterid;
@property (nonatomic, strong) NSNumber *cnttotal;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSString *sex;

+ (instancetype)modelWithDictionary:(NSDictionary *)sourceDict;

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
- (void) showProfile:(BOOL)restore;
- (void) showAlertWithResult:(NSDictionary*)result completion:(void (^)(void))completion;
- (void) startChat:(CKChatModel *)chat;

@end

@interface CKApplicationModel : NSObject

@property (nonatomic, assign) id<CKMainControllerProtocol>mainController;
@property (nonatomic, strong, readonly) CLLocation* location;

+ (instancetype)sharedInstance;

- (void) didStarted;
- (void) userDidAcceptTerms;
- (void) sendUserPhone:(NSString *)phone promo:(NSString *)promo countryId:(NSInteger)countryId;
- (void) checkUserLogin:(NSString *)login withCallback:(CKServerConnectionExecutedObject)callback;
- (void) requestAuthentication;
- (void) sendPhoneAuthenticationCode:(NSString *)code;
- (void) restoreHistoryWithCallback:(CKServerConnectionExecuted)callback;
- (void) restoreProfile:(bool) restore;
- (void) submitNewProfile;
- (void) getLocationInfowithCallback:(CKServerConnectionExecutedObject)callback;
- (void) loadClusters: (NSNumber *)status withFriendStatus: (NSNumber *)isfriend withCountry: (NSNumber *)country withCity: (NSNumber *)city withSex: (NSString *)sex withMinage: (NSNumber *)minage andMaxAge: (NSNumber *)maxage withMask: (NSString *)mask withBottomLeftLatitude: (NSNumber *)swlat withBottomLeftLongtitude: (NSNumber *)swlng withtopCoordinate: (NSNumber *)nelat withTopRigthLongtitude: (NSNumber *)nelng withInt: (int) count;
- (void) updateUsers;


// определять по местоположению пользователя
@property (nonatomic, readonly) NSInteger countryId;

- (BOOL)countryExistWithId:(NSInteger)id;
- (NSDictionary *)countryWithId:(NSInteger)id;


// данные пользователя
@property (nonatomic, readonly) CKUser* userProfile;

@property (strong, nonatomic, readonly) NSArray<CKUser *> *userlistMain;
@property (nonatomic, readonly) NSArray<CKClusterModel *> *clusterlist;
@property (nonatomic, readonly) NSArray<CKClusterModel *> *clusterForFilter;


-(void) startPrivateChat:(CKUser*) user;
-(void) startMultipleChat:(NSArray*) userIds;
-(void) startGroupChat:(CKGroupChatModel*) group;
-(void) restartRecentChat:(CKDialogModel*) dialog;
 
// пул чатов
- (void)storeChat:(CKChatModel *)model withId:(NSString *)id;
- (CKChatModel *)getChatModelWithId:(NSString *)id;

- (void)testInternetConnection:(NetworkReachable) reachableBlock unreachableBlock:(NetworkUnreachable) unreachableBlock;

@end
