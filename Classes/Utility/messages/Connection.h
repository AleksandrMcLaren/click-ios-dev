//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.

#import <Foundation/Foundation.h>


@interface Connection : NSObject


@property (strong, nonatomic) Reachability *reachability;

+ (Connection *)shared;

+ (BOOL)isReachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;

@end

