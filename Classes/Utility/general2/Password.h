//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import <Foundation/Foundation.h>
 

@interface Password : NSObject


+ (NSString *)get:(NSString *)groupId;

+ (void)set:(NSString *)password groupId:(NSString *)groupId;

+ (NSString *)init:(NSString *)groupId;

@end

