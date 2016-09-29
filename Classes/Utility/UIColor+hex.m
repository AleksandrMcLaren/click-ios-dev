#import "UIColor+hex.h"

#define UIColorFromHEX(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation UIColor (hex)

#pragma mark - Colors from hex

+ (unsigned int)intFromHexString:(NSString *)hexString
{
    unsigned int hexInt = 0;
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}

+(UIColor *)colorFromHex:(unsigned int)hex {
    return UIColorFromHEX(hex);
}

+(UIColor *)colorFromHexString:(NSString *)hexString {
    return [self colorFromHexString:hexString alpha:1.0];
}

+(UIColor *)colorFromHexString:(NSString *)hexString alpha:(CGFloat)alpha {

    unsigned int hexint = [self intFromHexString:hexString];
    return UIColorFromHEX(hexint);
}

@end
