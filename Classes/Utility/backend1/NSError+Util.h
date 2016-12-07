//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import <Foundation/Foundation.h>


@interface NSError (Util)


+ (NSError *)description:(NSString *)description code:(NSInteger)code;

- (NSString *)description;

@end

