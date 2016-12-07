//  Created by Дрягин Павел on 18.11.16.
//  Copyright © 2016 Click. All rights reserved.


#import <Foundation/Foundation.h>

@interface UserDefaults : NSObject

+ (void)setObject:(id)value forKey:(NSString *)key;
+ (void)removeObjectForKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

+ (NSString *)stringForKey:(NSString *)key;
+ (NSInteger)integerForKey:(NSString *)key;
+ (BOOL)boolForKey:(NSString *)key;

@end

