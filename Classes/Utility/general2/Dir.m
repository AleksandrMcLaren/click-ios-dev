//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.


#import "utilities.h"
 
@implementation Dir


+ (NSString *)application

{
	return [[NSBundle mainBundle] resourcePath];
}


+ (NSString *)application:(NSString *)component

{
	NSString *path = [self application];
	
	if (component != nil) path = [path stringByAppendingPathComponent:component];
	
	return path;
}


+ (NSString *)application:(NSString *)component1 and:(NSString *)component2

{
	NSString *path = [self application];
	
	if (component1 != nil) path = [path stringByAppendingPathComponent:component1];
	if (component2 != nil) path = [path stringByAppendingPathComponent:component2];
	
	return path;
}

#pragma mark -


+ (NSString *)document

{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}


+ (NSString *)document:(NSString *)component

{
	NSString *path = [self document];
	
	if (component != nil) path = [path stringByAppendingPathComponent:component];
	
	[self createIntermediate:path];
	
	return path;
}

#pragma mark -


+ (NSString *)cache

{
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}


+ (NSString *)cache:(NSString *)component

{
	NSString *path = [self cache];
	
	if (component != nil) path = [path stringByAppendingPathComponent:component];
	
	[self createIntermediate:path];
	
	return path;
}

#pragma mark -


+ (void)createIntermediate:(NSString *)path

{
	NSString *directory = [path stringByDeletingLastPathComponent];
	if ([self exist:directory] == NO) [self create:directory];
}


+ (void)create:(NSString *)directory

{
	[[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
}


+ (BOOL)exist:(NSString *)path

{
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

@end

