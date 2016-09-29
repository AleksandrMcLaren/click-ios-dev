//
//  CKGroupChatModel.h
//  click
//
//  Created by Igor Tetyuev on 23.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKChatModel.h"
#import "CKMessageServerConnection.h"

@interface CKGroupChatModel : CKChatModel

@property (nonatomic, strong) NSMutableArray *userIds;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, assign) CKDialogType dialogType;
@property (nonatomic, assign) BOOL readonly;

- (instancetype)initWithName:(NSString *)name avatar:(NSString *)avatar description:(NSString *)description userIDs:(NSArray *)userIds; // new group
- (instancetype)initWithGroupID:(NSString *)groupId; // existing group

@end
