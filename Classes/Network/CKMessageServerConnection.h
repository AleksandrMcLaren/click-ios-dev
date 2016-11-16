//
//  CKMessageServerConnection.h
//  click
//
//  Created by Igor Tetyuev on 26.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKServerConnection.h"
#import "CKAttachModel.h"
#import <MapKit/MapKit.h>

#define CKMessageServerConnectionReceived @"CKMessageServerConnectionReceived"

typedef enum CKDialogType
{
    CKDialogTypeChat,
    CKDialogTypeGroupChat,
    CKDialotTypeBroadcast
} CKDialogType;

@interface CKUserFilterModel : NSObject

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) BOOL isFriend;
@property (nonatomic, assign) NSInteger country;
@property (nonatomic, assign) NSInteger city;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, assign) NSInteger minAge;
@property (nonatomic, assign) NSInteger maxAge;
@property (nonatomic, strong) NSString *mask;
@property (nonatomic, assign) MKCoordinateRegion area;
@property (nonatomic, strong) NSArray *userlist;

+ (CKUserFilterModel *)filterWithAllFriends;
+ (CKUserFilterModel *)filterWithLocation;

- (NSDictionary *)getDictionary;

@end

@interface CKMessageServerConnection : CKServerConnection

- (void)getDialogListWithCallback:(CKServerConnectionExecuted)callback;
- (void)addFriends:(NSArray *)friendPhoneList callback:(CKServerConnectionExecutedStatus)callback;
- (void)getUserListWithFilter:(CKUserFilterModel *)model callback:(CKServerConnectionExecuted)callback;
- (void)getDialogWithId:(NSString *)dialogId page:(NSInteger)page pageSize:(NSInteger)pageSize callback:(CKServerConnectionExecuted)callback;
- (void)getDialogWithUser:(NSString *)userId page:(NSInteger)page pageSize:(NSInteger)pageSize callback:(CKServerConnectionExecuted)callback;
- (void)getDialogWithGroup:(NSString *)groupId page:(NSInteger)page pageSize:(NSInteger)pageSize callback:(CKServerConnectionExecuted)callback;
- (void)sendMessage:(NSString *)message attachements:(NSArray *)attachements toUser:(NSString *)user callback:(CKServerConnectionExecuted)callback;
- (void)sendMessage:(NSString *)message toGroup:(NSString *)group dialogType:(CKDialogType)dialogType callback:(CKServerConnectionExecuted)callback;
- (void)createGroupChatWithName:(NSString *)title avatar:(NSString *)avatar description:(NSString *)description users:(NSArray *)userlist callback:(CKServerConnectionExecuted)callback;
- (void)uploadAttachements:(NSArray<CKAttachModel *>*)attachements completion:(CKServerConnectionExecuted)callback;
- (void)cleanallHistory:(CKServerConnectionExecuted)callback;
- (void) getUserClasters: (NSNumber *)status withFriendStatus: (NSNumber *)isfriend withCountry: (NSNumber *)country withCity: (NSNumber *)city withSex: (NSString *)sex withMinage: (NSNumber *)minage andMaxAge: (NSNumber *)maxage withMask: (NSNumber *)mask withBottomLeftLatitude:(NSNumber *)bottomLeftLatitude withBottomLeftLongtitude: (NSNumber *) bottomLeftLongtitude withtopCoordinate: (NSNumber *)topRightLatitude withTopRigthLongtitude:(NSNumber *)topRightLongtitde withCallback: (CKServerConnectionExecuted)callback;

@property (nonatomic, strong) NSMutableDictionary *messageModelCache;
@property (nonatomic, strong) NSMutableDictionary *attachmentModelCache;

@end
