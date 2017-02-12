//
//  MLChatLib.m
//  click
//
//  Created by Александр on 11.02.17.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatLib.h"

@implementation MLChatLib

#pragma mark - NSDateFormatter

+ (NSDateFormatter *)formatterDate_HH_mm
{
    static dispatch_once_t once;
    static NSDateFormatter *_dateFormatter;
    dispatch_once(&once, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.calendar = [NSCalendar currentCalendar];
        _dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        _dateFormatter.dateFormat = @"HH:mm";
    });
    
    return _dateFormatter;
}

#pragma mark - Text size

+ (CGSize)textSizeLabel:(UILabel *)label withWidth:(CGFloat)width
{
    CGSize textSize = [label.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:label.font}
                                               context:nil].size;
    
    return textSize;
}

@end
