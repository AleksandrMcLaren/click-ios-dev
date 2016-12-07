//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import "utilities.h"


@interface UserStatuses()
{
//	FIRDatabaseReference *firebase;
}
@end


@implementation UserStatuses


+ (UserStatuses *)shared

{
	static dispatch_once_t once;
	static UserStatuses *userStatuses;
	
	dispatch_once(&once, ^{ userStatuses = [[UserStatuses alloc] init]; });
	
	return userStatuses;
}


- (id)init

{
	self = [super init];
	
	[NotificationCenter addObserver:self selector:@selector(initObservers) name:NOTIFICATION_APP_STARTED];
	[NotificationCenter addObserver:self selector:@selector(initObservers) name:NOTIFICATION_USER_LOGGED_IN];
	[NotificationCenter addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT];
	
	return self;
}

#pragma mark - Backend methods


- (void)initObservers

{
	if ([CKUser currentId] != nil)
	{
//		if (firebase == nil) [self createObservers];
	}
}


- (void)createObservers

{
//	firebase = [[FIRDatabase database] referenceWithPath:CKUserSTATUS_PATH];
//	[firebase observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
//	{
//		if (snapshot.exists)
//		{
//			for (NSDictionary *userStatus in [snapshot.value allValues])
//			{
//				dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL), ^{
//					[self updateRealm:userStatus];
//				});
//			}
//		}
//	}];
}


- (void)updateRealm:(NSDictionary *)userStatus

{
//	RLMRealm *realm = [RLMRealm defaultRealm];
//	[realm beginWriteTransaction];
//	[DBUserStatus createOrUpdateInRealm:realm withValue:userStatus];
//	[realm commitWriteTransaction];
}

#pragma mark - Cleanup methods


- (void)actionCleanup

{
//	[firebase removeAllObservers]; firebase = nil;
}

@end

