//
//  CKUser.h
//  click
//
//  Created by Дрягин Павел on 28.11.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKUser : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, assign) NSInteger iso;
@property (nonatomic, assign) NSInteger countryId;
@property (nonatomic, strong) NSString *countryName;
@property (nonatomic, assign) NSInteger city;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSString *avatarName;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *invite;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) double distance;
@property (nonatomic, assign) NSInteger geoStatus;
@property (nonatomic, assign) BOOL isFriend;
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) NSDate *birthDate;

@property (nonatomic, strong) NSDate *registeredDate;
@property (nonatomic, strong) NSDate *statusDate;

@property (nonatomic, readonly) NSString *commonName;
@property (nonatomic, readonly) NSString *letterName;
@property (nonatomic, strong, readonly) NSString* avatarURLString;
@property (nonatomic, assign, readonly) BOOL isCreated;

//TODO Необходим рефакторинг
//----ПЕРЕОПРЕДЕЛИТЬ ЭТИ СВОЙСВА НА ОРИГИНАЛЬНЫЕ----------
@property (nonatomic, strong, readonly) NSString* fullname;
@property (nonatomic, strong, readonly) NSString* objectId;
@property (nonatomic, strong, readonly) NSString *firstname;
@property (nonatomic, strong, readonly) NSString *lastname;
@property (nonatomic, strong, readonly) NSString *picture;


//----------------------------------------------------------

+ (instancetype)modelWithDictionary:(NSDictionary *)sourceDict;

@property (strong, nonatomic) RACCommand *executeSearch;

#pragma mark - Class methods

+ (NSString *)currentId;

+ (CKUser *)currentUser;

+ (instancetype)userWithId:(NSString *)uid;

+ (BOOL)logOut;

#pragma mark - Instance methods

- (BOOL)isCurrent;


@end
