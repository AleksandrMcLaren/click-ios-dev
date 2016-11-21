//  Created by Дрягин Павел on 18.11.16.
//  Copyright © 2016 Click. All rights reserved.

#import "UserDefaults.h"

@implementation UserDefaults

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)setObject:(id)value forKey:(NSString *)key
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)removeObjectForKey:(NSString *)key
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (id)objectForKey:(NSString *)key
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)stringForKey:(NSString *)key
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSInteger)integerForKey:(NSString *)key
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (BOOL)boolForKey:(NSString *)key
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

@end

