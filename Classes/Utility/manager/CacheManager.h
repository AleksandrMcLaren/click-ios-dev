//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.


#import <Foundation/Foundation.h>

@interface CacheManager : NSObject

+ (void)cleanupExpired;

+ (void)cleanupManual;

+ (uint64_t)total;

@end

