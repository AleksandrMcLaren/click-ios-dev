//
//  NSString+NumEncoding.m
//  click
//
//  Created by Дрягин Павел on 17.10.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "NSString+NumEncoding.h"

@implementation NSString (NumEncoding)

+ (NSString *)terminationForValue:(int)value withWords:(NSArray *)words {
    if (words.count != 3) {
        return nil;
    }
    int dd = (int)floor(value) % 100;
    int d = (int)floor(value) % 10;
    
    if(d == 0 || d > 4 || dd == 11 || dd == 12 || dd == 13 || dd == 14) return words[0];
    if(d != 1 && d < 5) return words[1];
    if(d == 1) return words[2];
    
    return words[0];
}

@end
