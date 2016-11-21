//
//  CKDialogsModel.h
//  click
//
//  Created by Igor Tetyuev on 25.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@protocol CKDialogsControllerProtocol <NSObject>

@end

@interface CKDialogListEntryModel : NSObject

+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

@property (nonatomic, strong) NSString *userAvatarId;
@property (nonatomic, assign) NSUInteger attachCount;
@property (nonatomic, assign) NSUInteger onlineUsersCount;
@property (nonatomic, assign) NSUInteger userCount;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *dialogAvatarId;
@property (nonatomic, strong) NSString *dialogDescription;
@property (nonatomic, strong) NSString *dialogName;
@property (nonatomic, strong) NSString *dialogId;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString *userLogin;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, assign) NSUInteger messageStatus;
@property (nonatomic, assign) NSUInteger messagesTotal;
@property (nonatomic, assign) NSUInteger messageType;
@property (nonatomic, assign) NSUInteger messagesUnread;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userSurname;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, assign) NSUInteger state;
@property (nonatomic, assign) NSUInteger status;
@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, strong) NSString *userId;

@end

@interface CKDialogsModel : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign) id<CKDialogsControllerProtocol>dialogsController;
@property (nonatomic, strong, readonly) RACSignal* dialogsDidChanged;

- (void)run;

@property (nonatomic, readonly) NSArray *dialogs;

@end
