//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import "utilities.h"
#import <Contacts/Contacts.h>

@interface Users()
{
	BOOL refreshUserInterface;
    NSMutableDictionary* _users;
    NSDictionary *_phoneContacts;
    CKUser* _currentUser;
}
@end

@implementation Users

+ (Users *)sharedInstance

{
	static dispatch_once_t once;
	static Users *users;
	
	dispatch_once(&once, ^{ users = [[Users alloc] init]; });
	
	return users;
}

-(NSArray*)users{
    return _users.allValues;
}

-(CKUser*)userWithId:(NSString*)userId{
    if ([_currentUser.id isEqualToString:userId]) {
        return _currentUser;
    }
    if ([_users objectForKey:userId]) {
        return [_users objectForKey:userId];
    }else{
        [[CKUserServerConnection sharedInstance] getUserInfoWithId:userId callback:^(NSDictionary* result) {
            if ([result socketMessageStatus] == S_OK){
                CKUser* profile = [CKUser modelWithDictionary:[result socketMessageResult]];
                [_users setObject:profile forKey:profile.id];
                [self refreshUserInterface];
            }
        }];
    }
    return nil;
}

- (id)init

{
	self = [super init];
	
    _users = [NSMutableDictionary new];
    
	[NotificationCenter addObserver:self selector:@selector(run) name:NOTIFICATION_APP_STARTED];
	[NotificationCenter addObserver:self selector:@selector(run) name:NOTIFICATION_USER_LOGGED_IN];
	[NotificationCenter addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT];
	
//    _usersDidChanged = [RACObserve(self, ) ignore:nil];

	return self;
}

#pragma mark - Cleanup methods

- (void)actionCleanup{
}

#pragma mark - Notification methods


- (void)refreshUserInterface{
	if (refreshUserInterface)
	{
		[NotificationCenter post:NOTIFICATION_REFRESH_USERS];
		refreshUserInterface = NO;
	}
}

- (void)run
{
    _users = [NSMutableDictionary new];
    [self loadUserList];
    [self reloadUserList];
}

- (void)reloadUserList
{
    NSString *query = @"select * from users";
    __block NSMutableDictionary *result = [NSMutableDictionary new];
    [[CKDB sharedInstance].queue inDatabase:^(FMDatabase *db) {
        FMResultSet *data = [db executeQuery:query];
        while ([data next])
        {
            NSDictionary* resultDictionary = [data resultDictionary];
            CKUser *user = [CKUser modelWithDictionary:[resultDictionary prepared]];
            CKPhoneContact *contact;
            if ((contact = _phoneContacts[user.id]))
            {
                user.name = contact.name;
                user.surname = contact.surname;
            }
            if ([user.id isEqualToString:[CKApplicationModel sharedInstance].userPhone]) {
                _currentUser = user;
            }else{
                [result setObject:user forKey:user.id];
            }
        }
    }];
    _users = result;
}

-(void)loadUserList{
    [self fetchContactsWithCompletion:^(NSMutableArray *arr) {
        
        NSMutableDictionary *d = [NSMutableDictionary new];
        for (CKPhoneContact *i in arr)
        {
            d[i.phoneNumber] = i;
        }
        _phoneContacts = d;
        NSMutableArray *cont = [NSMutableArray new];
        [cont addObjectsFromArray:[_phoneContacts allValues]];
        _fullContacts = cont;
        [[CKMessageServerConnection sharedInstance] addFriends:[self contactPhoneList] callback:^(CKStatusCode status) {
            
            [self updateUserList];
        }];
        
    }];
}

- (void)updateUserList
{
    [[CKMessageServerConnection sharedInstance] getUserListWithFilter:[CKUserFilterModel filterWithAllFriends] callback:^(NSDictionary *result) {
        for (NSDictionary *i in result[@"result"]){
            [self saveUser:i];
        }
        [self reloadUserList];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)saveUser:(NSDictionary*)dialog{
    [[CKDB sharedInstance] updateTable:@"users" withValues:dialog];
}


- (void) fetchContactsWithCompletion:(void(^)(NSMutableArray* arr))completion
{
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusDenied) {
        // error
        return;
    }
    
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"No permissions");
            });
            return;
        }
        NSMutableArray *phoneUsers = [NSMutableArray array];
        
        NSError *fetchError;
        NSArray* keys = @[CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactIdentifierKey, [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
        
        CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
        BOOL success = [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
            
            NSString *fullname = [formatter stringFromContact:contact];
            NSArray *phones = contact.phoneNumbers;
            if(fullname && phones.count) {
                CNLabeledValue<CNPhoneNumber*> *first = [phones firstObject];
                CNPhoneNumber* number = first.value;
                NSString* digits = number.stringValue;
                CKPhoneContact *phoneContact = [CKPhoneContact new];
                phoneContact.phoneNumber = digits;
                phoneContact.fullname = fullname;
                phoneContact.name = contact.givenName;
                phoneContact.surname = contact.familyName;
                phoneContact.id = contact.identifier;
                [phoneUsers addObject:phoneContact];
            }
            //
        }];
        if (!success) {
            NSLog(@"error = %@", fetchError);
        }
        // get digits only
        for(int i = 0; i < phoneUsers.count; i++) {
            CKPhoneContact* contact = [phoneUsers objectAtIndex:i];
            NSString* phone = contact.phoneNumber;
            contact.phoneNumber = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
            //            if([[contact.phoneNumber substringToIndex:1] isEqualToString:@"8"]) {
            //                contact.phoneNumber = [NSString stringWithFormat:@"%@%@", @"7", [contact.phoneNumber substringFromIndex:1]];
            //            }
        }
        // remove duplicates
        NSMutableIndexSet* toRemove = [NSMutableIndexSet new];
        for(int i = 0; i < phoneUsers.count; i++) {
            for(int j = 0; j < i; j++) {
                if([[(CKPhoneContact *)phoneUsers[i] phoneNumber] isEqualToString:[(CKPhoneContact *)phoneUsers[j] phoneNumber]]) {
                    [toRemove addIndex:j];
                }
            }
        }
        [phoneUsers removeObjectsAtIndexes:toRemove];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(phoneUsers);
        });
    }];
}

- (NSArray *)phoneContacts
{
    NSMutableDictionary *contactsByPhone = [NSMutableDictionary new];
    for (CKPhoneContact *i in [_phoneContacts allValues])
    {
        contactsByPhone[i.phoneNumber] = i;
    }
    NSLog(@"%@", contactsByPhone);
    for (CKUser *i in _users.allValues)
    {
        NSLog(@"%@ %@", i.id, contactsByPhone[i.id]);
        [contactsByPhone removeObjectForKey:i.id];
    }
    NSLog(@"%@", contactsByPhone);
    return [contactsByPhone allValues];
}

- (NSArray *)contactPhoneList
{
    return [_phoneContacts allKeys];
}

- (void) addNewContactToFriends:(void(^)())completion
{
    [self fetchContactsWithCompletion:^(NSMutableArray *arr) {
        
        NSMutableDictionary *d = [NSMutableDictionary new];
        for (CKPhoneContact *i in arr)
        {
            d[i.phoneNumber] = i;
        }
        _phoneContacts = d;
        
        NSMutableArray *cont = [NSMutableArray new];
        [cont addObjectsFromArray:[_phoneContacts allValues]];
        _fullContacts = cont;
        
        if(completion)
            completion();
    }];
}

- (void) checkUserProfile: (NSString *)newFriendPhone
{
    __block BOOL isFriend = false;
    [[CKUserServerConnection sharedInstance] getUserInfoWithId:newFriendPhone callback:^(NSDictionary *result) {
        //CKUser *profile;
        if ([result socketMessageStatus] == S_OK) {
            CKUser *user = [CKUser new];
            //   profile = [CKUser modelWithDictionary:[result socketMessageResult]];
            
            user = [CKUser modelWithDictionary:[result socketMessageResult]];
            //user.isFriend = 1;
            NSArray *friends1 = [[Users sharedInstance] users];
            for (CKUser *i in friends1)
            {
                if (![user.id isEqual:i.id])
                {
                    isFriend = true;
                    break;
                }
            }
            if (isFriend != true)
            {
                if (user !=nil && ![user.id isEqual:@"0"])
                    [_users setObject:user forKey:user.id];
            }
        }
    }];
}

- (void) saveUserWithDialog:(NSDictionary*)dialog{
    NSMutableDictionary* user = [NSMutableDictionary new];
    if (dialog[@"userid"]) {
        [user setObject:dialog[@"userid"] forKey:@"id"];
        
        if (dialog[@"avatar"]) {
            [user setObject:dialog[@"avatar"] forKey:@"avatar"];
        }
        if (dialog[@"login"]) {
            [user setObject:dialog[@"login"] forKey:@"login"];
        }
        if (dialog[@"name"]) {
            [user setObject:dialog[@"name"] forKey:@"name"];
        }
        
        [self saveUser:user];
    }


}

#pragma mark - Class methods


- (NSString *)currentId{
    return [_currentUser objectId];
}


-(CKUser *)currentUser{
    if (!_currentUser)
    {
        _currentUser = [CKUser new];
        NSDictionary *country = [[CKApplicationModel sharedInstance] countryWithId: [CKApplicationModel sharedInstance].countryId];
        _currentUser.iso = [country[@"iso"] integerValue];
        _currentUser.countryName = country[@"name"];
        _currentUser.countryId = [CKApplicationModel sharedInstance].countryId;
        _currentUser.id = [CKApplicationModel sharedInstance].userPhone;
    }
    return  _currentUser;
}



@end

