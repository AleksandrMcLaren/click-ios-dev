//
//  CKUser+Util.m
//  click
//
//  Created by Дрягин Павел on 28.11.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "AppConstant.h"

#import "CKUser+Util.h"

@implementation CKUser (Util)

#pragma mark - Class methods


+ (NSString *)fullname				{	return [[CKUser currentUser] fullname];					}
+ (NSString *)initials				{	return [[CKUser currentUser] initials];					}
+ (NSString *)picture				{	return [[CKUser currentUser] picture];					}
+ (NSString *)status				{	return [NSString stringWithFormat:@"%ld", (long)[[CKUser currentUser] status] ];					}


+ (NSInteger)keepMedia				{	return [[CKUser currentUser] keepMedia];					}
+ (NSInteger)networkImage			{	return [[CKUser currentUser] networkImage];				}
+ (NSInteger)networkVideo			{	return [[CKUser currentUser] networkVideo];				}
+ (NSInteger)networkAudio			{	return [[CKUser currentUser] networkAudio];				}

+ (BOOL)autoSaveMedia				{	return [[CKUser currentUser] autoSaveMedia];				}
+ (BOOL)isOnboardOk					{	return [[CKUser currentUser] isOnboardOk];				}


#pragma mark - Instance methods


- (NSString *)picture				{	return self.avatarURLString /*FUSER_PICTURE*/;								}
- (NSString *)status				{	return [NSString stringWithFormat:@"%ld", (long)self.status] /*FUSER_STATUS*/;								}
- (NSString *)loginMethod			{	return LOGIN_PHONE /*FUSER_LOGINMETHOD*/;							}

- (NSInteger)keepMedia				{	return KEEPMEDIA_FOREVER /*FUSER_KEEPMEDIA*/;			}
- (NSInteger)networkImage			{	return NETWORK_ALL /*FUSER_NETWORKIMAG*/;			}
- (NSInteger)networkVideo			{	return NETWORK_ALL /*FUSER_NETWORKVIDEO*/;			}
- (NSInteger)networkAudio			{	return NETWORK_ALL /*FUSER_NETWORKAUDIO*/;			}

- (BOOL)autoSaveMedia				{	return YES /* FUSER_AUTOSAVEMEDIA */ ;			}

- (BOOL)isOnboardOk					{	return (self.fullname != nil) /*FUSER_FULLNAME*/;					}


- (NSString *)initials

{
    if (([self.firstname length] != 0) && ([self.lastname length] != 0))
        return [NSString stringWithFormat:@"%@%@", [self.firstname substringToIndex:1], [self.lastname substringToIndex:1]];
    if ([self.login length] != 0) {
        return [self.firstname substringToIndex:1];
    }
    return nil;
}

@end
