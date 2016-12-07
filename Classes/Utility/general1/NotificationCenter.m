//  Created by Дрягин Павел on 18.11.16.
//  Copyright © 2016 Click. All rights reserved.


#import "NotificationCenter.h"

@implementation NotificationCenter


+ (void)addObserver:(id)target selector:(SEL)selector name:(NSString *)name

{
	[[NSNotificationCenter defaultCenter] addObserver:target selector:selector name:name object:nil];
}


+ (void)removeObserver:(id)target

{
	[[NSNotificationCenter defaultCenter] removeObserver:target];
}


+ (void)post:(NSString *)notification

{
	[[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
}

@end

