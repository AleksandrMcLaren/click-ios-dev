//
//  NSDate+Utils.m
//  click
//
//  Created by Дрягин Павел on 22.10.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

+(NSString*)date2str:(NSDate*)date {
    if (!date) return @"01.01.0001";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}

@end
