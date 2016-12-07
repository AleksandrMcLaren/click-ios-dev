//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.


#import <Foundation/Foundation.h>
#import "CKDialogsModel.h"
#import "Message.h"

@interface Recent : NSObject

#pragma mark - Fetch methods

+ (void)fetchRecents:(NSString *)groupId completion:(void (^)(NSMutableArray *recents))completion;
+ (void)fetchMembers:(NSString *)groupId completion:(void (^)(NSMutableArray *userIds))completion;

#pragma mark - Create methods

+ (void)createPrivate:(NSString *)userId groupId:(NSString *)groupId initials:(NSString *)initials picture:(NSString *)picture
		  description:(NSString *)description members:(NSArray *)members;

+ (void)createMultiple:(NSString *)groupId members:(NSArray *)members;

+ (void)createGroup:(NSString *)groupId picture:(NSString *)picture description:(NSString *)description members:(NSArray *)members;

+ (void)createItem:(NSString *)userId groupId:(NSString *)groupId initials:(NSString *)initials picture:(NSString *)picture
	   description:(NSString *)description members:(NSArray *)members type:(NSString *)type;

#pragma mark - Update methods

+ (void)updateLastMessage:(Message *)message;

+ (void)updateMembers:(CKDialogModel *)group;
+ (void)updateDescription:(CKDialogModel *)group;
+ (void)updatePicture:(CKDialogModel *)group;

#pragma mark - Delete/Archive methods

+ (void)deleteItem:(NSString *)objectId;
+ (void)archiveItem:(NSString *)objectId;
+ (void)unarchiveItem:(NSString *)objectId;

@end

