//
//  NSString+Verify.m
//  click
//
//  Created by Дрягин Павел on 31.10.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "NSString+Verify.h"

@implementation NSString (Verify)

-(NSRange)nonLatinSymbols{
    NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
    
    s = [s invertedSet];
    
    NSRange r = [self rangeOfCharacterFromSet:s];
    if (r.location != NSNotFound) {
        NSLog(@"the string contains illegal characters");
    }
    return r;
}

@end
