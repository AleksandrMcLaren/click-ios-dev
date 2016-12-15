//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import <Foundation/Foundation.h>

@interface Users : NSObject

@property (nonatomic, strong, readonly) RACSignal* usersDidChanged;

@property (nonatomic, readonly) NSArray *phoneContacts;
@property (nonatomic, readonly) NSArray *fullContacts;
@property (nonatomic, readonly) NSArray *users;

@property (nonatomic, strong, readonly) NSString *currentId;
@property (nonatomic, strong) CKUser *currentUser;

+ (Users *)sharedInstance;

- (CKUser*)userWithId:(NSString*)userId;


- (void) addNewContactToFriends;
- (void) checkUserProfile: (NSString *)newFriendPhone;
- (void) run;
- (void) saveUserWithDialog:(NSDictionary*)dialog;
- (void) reloadUserList;
@end
