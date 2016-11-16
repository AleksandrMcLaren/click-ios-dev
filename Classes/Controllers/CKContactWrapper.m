//
//  CKContactWrapper.m
//  click
//
//  Created by Anatoly Mityaev on 10.11.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "CKContactWrapper.h"

@interface CKContactWrapper ()

@property (nonatomic) CNContactStore *contactStore;

@end

@implementation CKContactWrapper

+ (instancetype)sharedInstance
{
    static CKContactWrapper *contactsWrapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contactsWrapper = [[CKContactWrapper alloc] init];
    });
    return contactsWrapper;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _contactStore = [CNContactStore new];
    }
    return self;
}

- (void)getContacts:(void (^)(NSArray<CNContact *> *contacts, NSError  *error))completionBlock;
{
    [self getContactsWithKeys:@[] completionBlock:completionBlock];
}

- (void)getContactsWithKeys:(NSArray<id<CNKeyDescriptor>> *)keys
            completionBlock:(void (^)(NSArray<CNContact *> *contacts, NSError  *error))completionBlock
{
    [self getAuthorizationWithCompletionBlock:^(bool isSuccess, NSError *error) {
        if (isSuccess)
        {
            [self fetchContactsWithStore:self.contactStore key:keys completionBlock:completionBlock];
        }
        else
        {
            BLOCK_EXEC(completionBlock, nil, error);
        }
    }];
}

- (void)fetchContactsWithStore:(CNContactStore *)store
                           key:(NSArray<id<CNKeyDescriptor>> *)keys
               completionBlock:(void (^)(NSArray<CNContact *> *contacts, NSError *error))completionBlock

{
    if (keys.count == 0)
    {
        keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
    }
    NSString *containerId = store.defaultContainerIdentifier;
    NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
    NSError *contactError;
    NSArray<CNContact *> *contacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&contactError];
    if (contactError)
    {
        BLOCK_EXEC(completionBlock, nil, contactError)
    }
    else
    {
        BLOCK_EXEC(completionBlock, contacts, nil);
    }
}

- (void)saveContact:(CNMutableContact *)contact
    completionBlock:(void (^)(bool isSuccess, NSError *error))completionBlock
{
    [self getAuthorizationWithCompletionBlock:^(bool isSuccess, NSError *error) {
        if (isSuccess)
        {
            CNSaveRequest *saveRequest = [CNSaveRequest new];
            [saveRequest addContact:contact toContainerWithIdentifier:self.contactStore.defaultContainerIdentifier];
            NSError *saveContactError;
            [self.contactStore executeSaveRequest:saveRequest error:&saveContactError];
            if (saveContactError)
            {
                BLOCK_EXEC(completionBlock, NO, saveContactError);
            }
            else
            {
                BLOCK_EXEC(completionBlock, YES, nil);
            }
        }
        else
        {
            BLOCK_EXEC(completionBlock, NO, error);
        }
    }];
}

- (void)getContactsWithGivenName:(NSString *)givenName
                 completionBlock:(void (^)(NSArray<CNContact *> *contacts, NSError *error))completionBlock
{
    [self fetchContactsWithGivenName:givenName completionBlock:completionBlock];
}

- (void)getContactsWithGivenName:(NSString *)givenName
                      familyName:(NSString *)familyName
                 completionBlock:(void (^)(NSArray<CNContact *> *contacts, NSError *error))completionBlock
{
    [self fetchContactsWithGivenName:givenName completionBlock:^(NSArray<CNContact *> * _Nullable contacts, NSError * _Nullable error) {
        if (error)
        {
            BLOCK_EXEC(completionBlock, nil, error);
        }
        else
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"familyName == %@", familyName];
            contacts = [contacts filteredArrayUsingPredicate:predicate];
            BLOCK_EXEC(completionBlock, contacts, nil);
        }
    }];
}

- (void)fetchContactsWithGivenName:(NSString *)givenName
                   completionBlock:(void (^)(NSArray<CNContact *> * _Nullable contacts, NSError * _Nullable error))completionBlock
{
    [self getAuthorizationWithCompletionBlock:^(bool isSuccess, NSError *error) {
        if (isSuccess)
        {
            NSPredicate *predicate = [CNContact predicateForContactsMatchingName:givenName];
            NSError *error;
            NSArray<CNContact *> *contacts = [self.contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey] error:&error];
            if (error)
            {
                BLOCK_EXEC(completionBlock, nil, error);
            }
            else
            {
                BLOCK_EXEC(completionBlock, contacts, nil);
            }
        }
        else
        {
            BLOCK_EXEC(completionBlock, nil, error);
        }
    }];
}

- (void)updateContact:(CNMutableContact *)contact
      completionBlock:(void (^)(bool isSuccess, NSError *error))completionBlock
{
    [self getAuthorizationWithCompletionBlock:^(bool isSuccess, NSError *error) {
        if (isSuccess)
        {
            CNSaveRequest *saveRequest = [CNSaveRequest new];
            [saveRequest updateContact:contact];
            NSError *updateContactError;
            [self.contactStore executeSaveRequest:saveRequest error:&updateContactError];
            if (updateContactError)
            {
                BLOCK_EXEC(completionBlock, NO, updateContactError);
            }
            else
            {
                BLOCK_EXEC(completionBlock, YES, nil);
            }
        }
        else
        {
            BLOCK_EXEC(completionBlock, NO, error);
        }
    }];
}

- (void)getContactsWithEmailAddress:(NSString *)emailAddress
                    completionBlock:(void (^)(NSArray<CNContact *> *contacts, NSError *error))completionBlock
{
    [self getAuthorizationWithCompletionBlock:^(bool isSuccess, NSError *error) {
        if (isSuccess)
        {
            NSPredicate *predicate = [CNContact predicateForContactsMatchingName:emailAddress];
            NSError *error;
            NSArray<CNContact *> *contacts = [self.contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey] error:&error];
            if (error)
            {
                BLOCK_EXEC(completionBlock, nil, error);
            }
            else
            {
                BLOCK_EXEC(completionBlock, contacts, nil);
            }
        }
        else
        {
            BLOCK_EXEC(completionBlock, nil, error);
        }
    }];
}

- (void)deleteContact:(CNContact *)contact
      completionBlock:(void (^)(bool isSuccess, NSError *error))completionBlock
{
    [self getAuthorizationWithCompletionBlock:^(bool isSuccess, NSError *error) {
        if (isSuccess)
        {
            CNSaveRequest *deleteRequest = [CNSaveRequest new];
            CNMutableContact *mutableContact = contact.mutableCopy;
            [deleteRequest deleteContact:mutableContact];
            NSError *deleteContactError;
            [self.contactStore executeSaveRequest:deleteRequest error:&deleteContactError];
            if (deleteContactError)
            {
                BLOCK_EXEC(completionBlock, NO, deleteContactError);
            }
            else
            {
                BLOCK_EXEC(completionBlock, YES, nil);
            }
        }
        else
        {
            BLOCK_EXEC(completionBlock, NO, error);
        }
    }];
}

- (void)addGroup:(CNMutableGroup *)group
 completionBlock:(void (^)(bool isSuccess, NSError *error))completionBlock
{
    [self getAuthorizationWithCompletionBlock:^(bool isSuccess, NSError *error) {
        if (isSuccess)
        {
            CNSaveRequest *addRequest = [CNSaveRequest new];
            [addRequest addGroup:group toContainerWithIdentifier:self.contactStore.defaultContainerIdentifier];
            NSError *groupError;
            [self.contactStore executeSaveRequest:addRequest error:&groupError];
            if (groupError)
            {
                BLOCK_EXEC(completionBlock, NO, groupError);
            }
            else
            {
                BLOCK_EXEC(completionBlock, YES, nil);
            }
        }
        else
        {
            BLOCK_EXEC(completionBlock, NO, error);
        }
    }];
}

- (void)addGroupMember:(CNContact *)contact
                 group:(CNGroup *)group
       completionBlock:(void (^)(bool isSuccess, NSError *error))completionBlock
{
    [self getAuthorizationWithCompletionBlock:^(bool isSuccess, NSError *error) {
        if (isSuccess)
        {
            CNSaveRequest *addMemberRequest = [CNSaveRequest new];
            [addMemberRequest addMember:contact toGroup:group];
            NSError *addMemberError;
            [self.contactStore executeSaveRequest:addMemberRequest error:&addMemberError];
            if (addMemberError)
            {
                BLOCK_EXEC(completionBlock, NO, addMemberError);
            }
            else
            {
                BLOCK_EXEC(completionBlock, YES, nil);
            }
        }
        else
        {
            BLOCK_EXEC(completionBlock, NO, error);
        }
    }];
}

- (void)getGroupsWithCompletionBlock:(void (^)(NSArray<CNGroup *> *groups, NSError *error))completionBlock
{
    [self getAuthorizationWithCompletionBlock:^(bool isSuccess, NSError *error) {
        if (isSuccess)
        {
            NSString *containerId = self.contactStore.defaultContainerIdentifier;
            NSPredicate *predicate = [CNGroup predicateForGroupsInContainerWithIdentifier:containerId];
            NSError *groupsError;
            NSArray<CNGroup*> *groups = [self.contactStore groupsMatchingPredicate:predicate error:&groupsError];
            if (groupsError)
            {
                BLOCK_EXEC(completionBlock, nil, groupsError);
            }
            else
            {
                BLOCK_EXEC(completionBlock, groups, nil);
            }
        }
        else
        {
            BLOCK_EXEC(completionBlock, nil, error);
        }
    }];
}

- (void)getAuthorizationWithCompletionBlock:(void (^)(bool isSuccess, NSError *error))completionBlock
{
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized)
    {
        BLOCK_EXEC(completionBlock, YES, nil);
    }
    else
    {
        [self.contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            BLOCK_EXEC(completionBlock, granted, error);
        }];
    }
}

@end
