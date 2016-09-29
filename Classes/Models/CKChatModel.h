//
//  CKChatModel.h
//  click
//
//  Created by Igor Tetyuev on 06.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKAttachModel.h"

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

@interface CKMessageModel : NSObject

@property (nonatomic, strong) NSUUID *id;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) CKMessageStatus status;
@property (nonatomic, assign) CKMessageType type;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSArray *attachements;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString *toUserID;
@property (nonatomic, strong) NSString *fromUserID;
@property (nonatomic, assign) NSInteger timer;
@property (nonatomic, assign) NSInteger attachPreviewCounter;


@end

@interface CKSentMessageModel : CKMessageModel

@end

@interface CKReceivedMessageModel : CKMessageModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

@interface CKChatModel : NSObject

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, readonly) BOOL isReadonly;

@end
