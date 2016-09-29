//
//  UILabel+utility.m
//  click
//
//  Created by Igor Tetyuev on 10.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "UILabel+utility.h"

@implementation UILabel(utility)


+ (UILabel *)labelWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment
{
    UILabel *result = [UILabel new];
    result.text = text;
    result.lineBreakMode = NSLineBreakByWordWrapping;
    if (font) result.font = font;
    if (textColor) result.textColor = textColor;
    if (textAlignment) result.textAlignment = textAlignment;
    return result;
}

@end
