//
//  NSString+NumEncoding.h
//  click
//
//  Created by Дрягин Павел on 17.10.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NumEncoding)

+ (NSString *)terminationForValue:(int)value withWords:(NSArray *)words;

@end
