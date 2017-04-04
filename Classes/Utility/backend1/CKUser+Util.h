//
//  CKUser+Util.h
//  click
//
//  Created by Дрягин Павел on 28.11.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "CKUser.h"

@interface CKUser (Util)

#pragma mark - Class methods

+ (NSString *)fullname;
+ (NSString *)initials;
+ (NSString *)picture;
//+ (NSString *)status;
+ (NSString *)loginMethod;

+ (NSInteger)keepMedia;
+ (NSInteger)networkImage;
+ (NSInteger)networkVideo;
+ (NSInteger)networkAudio;

+ (BOOL)autoSaveMedia;
+ (BOOL)isOnboardOk;

#pragma mark - Instance methods

- (NSString *)initials;


@end
