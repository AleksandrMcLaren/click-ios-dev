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

+(NSDateFormatter*)dateFormatterFull{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTF"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSZZZZZ"];
    return dateFormatter;
}

+(NSDate*)dateWithString:(NSString*)date{
    NSDateFormatter* dateFormatter = [[self class] dateFormatterFull];
    return [dateFormatter dateFromString:date];
}

+(NSString*)stringWithDate:(NSDate*)date{
    if (!date) {
        return @"0001-01-01T00:00:00";
    }
    NSDateFormatter* dateFormatter = [[self class] dateFormatterFull];
    return [dateFormatter stringFromDate:date];
}
@end
