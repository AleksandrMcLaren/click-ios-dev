//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.

#import <Foundation/Foundation.h>

@interface Account : NSObject

+ (void)add:(NSString *)email password:(NSString *)password;

+ (void)delOne;
+ (void)delAll;

+ (NSInteger)count;

+ (NSArray *)userIds;

+ (NSDictionary *)account:(NSString *)userId;

@end

