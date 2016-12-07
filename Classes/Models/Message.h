//
//  Message
//  click
//
//  Created by Дрягин Павел on 26.11.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import <Foundation/Foundation.h>

//0 не доставлено, 1 доставлено, 2 прочитано
typedef enum CKMessageStatus
{
    CKMessageStatusSent,
    CKMessageStatusDelivered,
    CKMessageStatusRead
} CKMessageStatus;

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
@property (nonatomic, assign) NSInteger timer;
@property (nonatomic, assign) NSInteger attachPreviewCounter;
@property (nonatomic, strong) NSString* entryid;

@property (nonatomic, strong, readonly) NSString *senderName;
@property (nonatomic, strong, readonly) NSString *statusName;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSString *senderInitials;

+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

+ (void)updateIncoming:(NSString *)messageId;
+ (void)updateStatus:(NSString *)groupId messageId:(NSString *)messageId;

+ (void)deleteItem:(NSString *)groupId messageId:(NSString *)messageId;

+ (void)deleteItem:(Message *)dbmessage;

//- (void)updateWithSender:(CKUser*)user;
- (void)update:(Message*)message;
@end

@interface MessageSent : Message

@end

@interface MessageReceived : Message

@end

NSString* NSStringFromCKMessageStatus(CKMessageStatus status);