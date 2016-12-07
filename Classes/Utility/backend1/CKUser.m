//
//  CKUser.m
//  click
//
//  Created by Дрягин Павел on 28.11.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "CKUser.h"
#import "CKApplicationModel.h"

@implementation CKUser

-(void)initizlize{
    self.id = nil;
    self.login = @"";
    self.name = @"";
    self.surname = @"";
    self.sex = @"";
    self.avatarName = nil;
    self.iso = -1;
    self.countryId = 0;
    self.countryName = nil;
    self.city = 0;
    self.cityName = nil;
    self.status = 0;
    self.invite = nil;
    self.location = kCLLocationCoordinate2DInvalid;
    self.distance = 0;
    self.geoStatus = 0;
    self.isFriend = NO;
    self.likes = 0;
    self.isLiked = NO;
    self.age = 0;
    self.birthDate = nil;
    self.registeredDate = nil;
    self.statusDate = nil;
    self.avatar = nil;
}

-(instancetype)init{
    if (self = [super init]) {
        [self initizlize];
    }
    return self;
}

- (RACSignal *)executeSearchSignal {
    return [[[[RACSignal empty]
              logAll]
             delay:2.0]
            logAll];
}


+ (instancetype)modelWithDictionary:(NSDictionary *)sourceDict
{
    CKUser *model = [CKUser new];
    
    @try {
        model.id = [NSString stringWithFormat:@"%@", sourceDict[@"id"]];
        model.login = sourceDict[@"login"];
        model.name = sourceDict[@"name"];
        model.surname = sourceDict[@"surname"];
        model.sex = sourceDict[@"sex"];
        model.avatarName = sourceDict[@"avatar"];
        if (sourceDict[@"iso"])  {
            model.iso = [sourceDict[@"iso"] integerValue];
        }
        if (sourceDict[@"country"]) {
            model.countryId = [sourceDict[@"country"] integerValue];
        }
        model.countryName = sourceDict[@"countryname"];
        if (sourceDict[@"city"]) {
            model.city = [sourceDict[@"city"] integerValue];
        }
        model.cityName = sourceDict[@"cityname"];
        if (![sourceDict[@"avatar"] isKindOfClass:[NSNull class]] && [sourceDict[@"avatar"] length]) model.avatar = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:(NSString *)sourceDict[@"avatar"] options:0]];
        if (sourceDict[@"status"]) {
            model.status = [sourceDict[@"status"] integerValue];
        }
        model.invite = sourceDict[@"invite"];
        if ((sourceDict[@"lat"]) && (sourceDict[@"lon"]) ) {
            model.location = CLLocationCoordinate2DMake([sourceDict[@"lat"] doubleValue], [sourceDict[@"lon"] doubleValue]);
        }
        if (sourceDict[@"distance"]) {
            model.distance = [sourceDict[@"distance"] doubleValue];
        }
        if (sourceDict[@"geostatus"]) {
            model.geoStatus = [sourceDict[@"geostatus"] integerValue];
        }
        if (sourceDict[@"isfriend"]) {
            model.isFriend = [sourceDict[@"isfriend"] boolValue];
        }
        if (sourceDict[@"likes"]) {
            model.likes = [sourceDict[@"likes"] integerValue];
        }
        if (sourceDict[@"isliked"]) {
            model.isLiked = [sourceDict[@"isliked"] boolValue];
        }
        if (sourceDict[@"age"]) {
            model.age = [sourceDict[@"age"] integerValue];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss"];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTF"];
        
        model.birthDate =  [sourceDict[@"birthdate"] isEqualToString:@"0001-01-01T00:00:00"] ? nil : [dateFormatter dateFromString:sourceDict[@"birthdate"]];
        model.registeredDate =  [sourceDict[@"registereddate"] isEqualToString:@"0001-01-01T00:00:00"] ? nil :[dateFormatter dateFromString:sourceDict[@"registereddate"]];
        model.statusDate =  [sourceDict[@"statusdate"] isEqualToString:@"0001-01-01T00:00:00"] ? nil :[dateFormatter dateFromString:sourceDict[@"statusdate"]];
    } @catch (NSException *exception) {
        return nil; // bad model
    }
    
    return model;
}

- (NSString *)commonName
{
    NSMutableString *result = [NSMutableString new];
    NSString *surname = self.surname;
    NSString *name = self.name;
    
    if (!surname && !name) name = self.login;
    
    if (surname)
    {
        surname = name;
        name = nil;
    }
    
    if (name)
    {
        [result appendString:name];
        if (surname) [result appendString:@" "];
    }
    if (surname)
    {
        [result appendString:surname];
    }
    
    return result;
}

- (NSString *)letterName
{
    NSString *surname = self.surname;
    NSString *name = self.name;
    NSString *login = self.login;
    
    if (!surname && !name) name = login;
    
    if ([surname isEqual:@""] && [name isEqual:@""]) name = login;
    
    if (!surname)
    {
        surname = name;
        name = nil;
    }
    if (name.length) return [name substringToIndex:1];
    return nil;
}

- (BOOL)isEqual:(CKUser *)object
{
    if ([object isKindOfClass:[CKUser class]]) return NO;
    return [self.id isEqual:object.id];
}

- (NSUInteger)hash
{
    return [self.id hash];
}

-(NSString*)avatarURLString{
    return [NSString stringWithFormat:@"%@%@", CK_URL_AVATAR, self.avatarName];
}

-(BOOL)isCreated{
    return self.id != nil;
}

-(void)setAvatar:(UIImage *)avatar{
    
    CGFloat maxSize = 300;
    if (avatar) {
        if (MIN(avatar.size.height, avatar.size.width) > maxSize) {
            CGFloat k = maxSize / MAX(avatar.size.height, avatar.size.width);
            
            CGSize newSize = CGSizeMake(avatar.size.width*k, avatar.size.height*k);
            UIGraphicsBeginImageContext(newSize);
            [avatar drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            avatar = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    
    _avatar = avatar;
}

-(NSString*)fullname{
    return [NSString stringWithFormat:@"fullname %@", self.login ];
}


-(NSString*)objectId{
    return self.id;
}

-(NSString*)firstname{
    return self.name;
}

-(NSString*)lastname{
    return self.surname;
}


#pragma mark - Class methods


+ (NSString *)currentId{
    return [[CKApplicationModel sharedInstance].userProfile objectId];
}


+ (CKUser *)currentUser{
    return  [CKApplicationModel sharedInstance].userProfile;
}

#pragma mark - Initialization methods


+ (instancetype)userWithId:(NSString *)userId{
//    CKUser *user = [[CKUser alloc] initWithPath:@"User"];
//    user[@"objectId"] = userId;
//    return user;
    return nil;
}

#pragma mark - Logut methods


+ (BOOL)logOut

{
    NSError *error;
    //	[[FIRAuth auth] signOut:&error];
    
    if (error == nil)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentUser"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    return NO;
}

#pragma mark - Private methods


//+ (void)load:(FIRUser *)firuser completion:(void (^)(CKUser *user, NSError *error))completion
//
//{
//	CKUser *user = [CKUser userWithId:firuser.uid];
//	[user fetchInBackground:^(NSError *error)
//	{
//		if (error != nil)
//		{
//			[self create:firuser.uid email:firuser.email completion:completion];
//		}
//		else if (completion != nil) completion(user, nil);
//	}];
//}



#pragma mark - Current user methods


- (BOOL)isCurrent

{
    return [self.objectId isEqualToString:[CKUser currentId]];
}


- (void)saveLocalIfCurrent

{
    if ([self isCurrent])
    {
//        [[NSUserDefaults standardUserDefaults] setObject:self.dictionary forKey:@"CurrentUser"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Save methods


- (void)saveInBackground

{
//    [self saveLocalIfCurrent];
//    [super saveInBackground];
}


- (void)saveInBackground:(void (^)(NSError *error))block
{
//    [self saveLocalIfCurrent];
//    [super saveInBackground:^(NSError *error)
//     {
//         if (error == nil) [self saveLocalIfCurrent];
//         if (block != nil) block(error);
//     }];
}

#pragma mark - Fetch methods


- (void)fetchInBackground
{
//    [super fetchInBackground:^(NSError *error)
//     {
//         if (error == nil) [self saveLocalIfCurrent];
//     }];
}


- (void)fetchInBackground:(void (^)(NSError *error))block
{
//    [super fetchInBackground:^(NSError *error)
//     {
//         if (error == nil) [self saveLocalIfCurrent];
//         if (block != nil) block(error);
//     }];
}


@end

