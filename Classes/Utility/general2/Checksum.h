//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import <Foundation/Foundation.h>
 

@interface Checksum : NSObject


+ (NSString *)md5HashOfData:(NSData *)data;
+ (NSString *)md5HashOfPath:(NSString *)path;
+ (NSString *)md5HashOfString:(NSString *)string;

+ (NSString *)shaHashOfData:(NSData *)data;
+ (NSString *)shaHashOfPath:(NSString *)path;
+ (NSString *)shaHashOfString:(NSString *)string;

@end

