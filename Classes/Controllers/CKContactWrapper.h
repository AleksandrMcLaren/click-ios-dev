#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>

#define BLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); };

NS_ASSUME_NONNULL_BEGIN

@interface CKContactWrapper : NSObject

/**
 * Singleton for Contacts Wrapper
 *
 * @return Instance
 */
+ (instancetype)sharedInstance;

/**
 * Get All Contacts with their Family Name, Given Name, Phone Numbers, Image Data
 *
 * @param completionBlock Nullable contacts and error
 */
- (void)getContacts:(void (^)(NSArray<CNContact *> * _Nullable contacts, NSError  * _Nullable error))completionBlock;

/**
 * Get All Contacts with given keys
 *
 * @param keys Keys for filling contact data
 * @param completionBlock Nullable contacts and error
 */
- (void)getContactsWithKeys:(NSArray<id<CNKeyDescriptor>> *)keys
            completionBlock:(void (^)(NSArray<CNContact *> * _Nullable contacts, NSError  * _Nullable error))completionBlock;

/**
 * Save given contact
 *
 * @param completionBlock isSuccess and error
 */
- (void)saveContact:(CNMutableContact *)contact
    completionBlock:(void (^)(bool isSuccess, NSError * _Nullable error))completionBlock;

/**
 * Get Contacts with given name
 *
 * @param givenName Given name
 * @param completionBlock Nullable contacts and error
 */
- (void)getContactsWithGivenName:(NSString *)givenName
                 completionBlock:(void (^)(NSArray<CNContact *> * _Nullable contacts, NSError * _Nullable error))completionBlock;

/**
 * Get Contacts with given name
 *
 * @param givenName Given name
 * @param familyName Family name
 * @param completionBlock Nullable contacts and error
 */
- (void)getContactsWithGivenName:(NSString *)givenName
                      familyName:(NSString *)familyName
                 completionBlock:(void (^)(NSArray<CNContact *> * _Nullable contacts, NSError * _Nullable error))completionBlock;

/**
 * Update given contact
 *
 * @param completionBlock isSuccess and error
 */
- (void)updateContact:(CNMutableContact *)contact
      completionBlock:(void (^)(bool isSuccess, NSError * _Nullable error))completionBlock;

/**
 * Get contacts with given email address
 *
 * @param emailAddress Email address
 * @param completionBlock Nullable contacts and error
 */
- (void)getContactsWithEmailAddress:(NSString *)emailAddress
                    completionBlock:(void (^)(NSArray<CNContact *> * _Nullable contacts, NSError * _Nullable error))completionBlock;

/**
 * Delete given contact
 *
 * @param completionBlock isSuccess and error
 */
- (void)deleteContact:(CNContact *)contact
      completionBlock:(void (^)(bool isSuccess, NSError * _Nullable error))completionBlock;

/**
 * Add given group to contacts list
 *
 * @param completionBlock isSuccess and error
 */
- (void)addGroup:(CNMutableGroup *)group
 completionBlock:(void (^)(bool isSuccess, NSError * _Nullable error))completionBlock;

/**
 * Add given member to given group
 *
 * @param contact Contact will be added to group
 * @param group Group which contact will be added in
 * @param completionBlock isSuccess and error
 */
- (void)addGroupMember:(CNContact *)contact
                 group:(CNGroup *)group
       completionBlock:(void (^)(bool isSuccess, NSError * _Nullable error))completionBlock;

/**
 * Get groups
 *
 * @param completionBlock Nullable groups and error
 */
- (void)getGroupsWithCompletionBlock:(void (^)(NSArray<CNGroup *> * _Nullable groups, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
