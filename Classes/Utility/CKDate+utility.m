//
//  CKDate+utility.m
//  click
//
//  Created by Igor Tetyuev on 06.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKDate+utility.h"

@implementation NSDate(utility)

- (NSString *)readableMessageTimestampString
{
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([self timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    int minutes;
    
    if(deltaSeconds < 5)
    {
        return @"Только что";
    }
    else if(deltaSeconds < 60)
    {
        return [NSString stringWithFormat:@"%d секунд назад", (unsigned int)deltaSeconds];
    }
    else if(deltaSeconds < 120)
    {
        return @"Минуту назад";
    }
    else if (deltaMinutes < 60)
    {
        return [NSString stringWithFormat:@"%d минут назад", (unsigned int)deltaMinutes];
    }
    else if (deltaMinutes < 120)
    {
        return @"Час назад";
    }
    else if (deltaMinutes < (24 * 60))
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTF"];
        [dateFormatter setDateFormat:@"HH:mm"];
        return [dateFormatter stringFromDate:self];
    }
    else if (deltaMinutes < (24 * 60 * 2))
    {
        return @"Вчера";
    }
    else if (deltaMinutes < (24 * 60 * 7))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24));
        return [NSString stringWithFormat:@"%d дней назад", (unsigned int)minutes];
    }
    else if (deltaMinutes < (24 * 60 * 14))
    {
        return @"На прошлой неделе";
    }
    else if (deltaMinutes < (24 * 60 * 31))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 7));
        return [NSString stringWithFormat:@"%d недель назад", (unsigned int)minutes];
    }
    else if (deltaMinutes < (24 * 60 * 61))
    {
        return @"В прошлом месяце";
    }
    else if (deltaMinutes < (24 * 60 * 365.25))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 30));
        return [NSString stringWithFormat:@"%d месяцев назад", (unsigned int)minutes];
    }
    else if (deltaMinutes < (24 * 60 * 731))
    {
        return @"В прошлом году";
    }
    
    minutes = (int)floor(deltaMinutes/(60 * 24 * 365));
    return [NSString stringWithFormat:@"%d лет назад", (unsigned int)minutes];
}


@end
