//  Created by Дрягин Павел on 18.11.16.
//  Copyright © 2016 Click. All rights reserved.


#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface NotificationCenter : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (void)addObserver:(id)target selector:(SEL)selector name:(NSString *)name;

+ (void)removeObserver:(id)target;

+ (void)post:(NSString *)notification;

@end

