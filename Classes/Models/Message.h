//
//  Message
//  click
//
//  Created by Дрягин Павел on 26.11.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import <Foundation/Foundation.h>

//0 не доставлено, 1 доставлено, 2 прочитано
typedef NS_ENUM(NSInteger, CKMessageStatus)
{
    CKMessageStatusSent,
    CKMessageStatusDelivered,
    CKMessageStatusRead
};

typedef enum CKMessageType
{
    CKMessageTypeNormal,
    CKMessageTypeSnap,
} CKMessageType;

@interface Message : NSObject

@property (nonatomic, strong) NSString* id;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) CKMessageStatus status;
@property (nonatomic, assign) CKMessageType type;
@property (nonatomic, assign) CKDialogType dialogType;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSArray *attachements;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString *toUserID;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSString *userlogin;
@property (nonatomic, strong) NSString *useravatar;
@property (nonatomic, assign) NSInteger timer;
@property (nonatomic, assign) NSInteger attachPreviewCounter;
@property (nonatomic, strong) NSString* entryid;

@property (nonatomic, strong) NSString* dialogIdentifier;

@property (nonatomic, strong, readonly) NSString *senderName;
@property (nonatomic, strong, readonly) NSString *senderLogin;
@property (nonatomic, strong, readonly) NSString *statusName;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSString *senderInitials;

@property (copy) void (^updatedIdentifier)();
@property (copy) void (^updatedStatus)();

+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
+ (instancetype)fromCacheWithId:(NSString *)ident;

+ (void)updateIncoming:(NSString *)messageId;
+ (void)updateStatusWithDictionary:(NSDictionary *)dict;
+ (void)update:(NSDictionary*)dictionary;
+ (void)updateId:(NSString*)oldId withId:(NSString*)newId;
+ (void)saveLinkWithUserId:(NSString*)userId messageId:(NSString*)messageId;
+ (void)deleteItem:(NSString *)groupId messageId:(NSString *)messageId;

+ (void)deleteItem:(Message *)dbmessage;

//- (void)updateWithSender:(CKUser*)user;
- (void)updateWithMessage:(Message*)message;
- (void)updateWithDictionary:(NSDictionary *)dict;
- (void)save;
@end

@interface MessageSent : Message

@end

@interface MessageReceived : Message

@end

NSString* NSStringFromCKMessageStatus(CKMessageStatus status);
