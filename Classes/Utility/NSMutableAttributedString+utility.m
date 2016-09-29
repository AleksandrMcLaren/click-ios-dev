//
//  NSMutableAttributedString+utility.m
//  click
//
//  Created by Igor Tetyuev on 18.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "NSMutableAttributedString+utility.h"

@implementation NSMutableAttributedString(utility)

+ (NSMutableAttributedString *)withString:(NSString *)string
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:string];
    return result;
}

+ (NSAttributedString *)withImageName:(NSString *)image geometry:(CGRect)geometry
{
    return [self withImage:[UIImage imageNamed:image] geometry:geometry];
}

+ (NSAttributedString *)withImage:(UIImage *)image geometry:(CGRect)geometry
{
    NSTextAttachment *textAttachment = [NSTextAttachment new];
    textAttachment.image = image;
    textAttachment.bounds = geometry;
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    return attrStringWithImage;
}

+ (NSMutableAttributedString *)withName:(NSString *)name surname:(NSString *)surname size:(double)size
{
    if (!surname)
    {
        surname = name;
        name = nil;
    }
    NSMutableAttributedString *result = [NSMutableAttributedString new];
    
    if (name)
    {
        [result appendAttributedString:[self withString:name]];
        if (surname) [result appendAttributedString:[self withString:@" "]];
    }
    if (surname)
    {
        NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:surname attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:size]}];
        [result appendAttributedString:s];
    }
    
    return result;
}


@end
