#import <UIKit/UIKit.h>


@interface UIColor (hex)

+(UIColor *)colorFromHex:(unsigned int)hex;
+(UIColor *)colorFromHexString:(NSString *)hexString;
+(UIColor *)colorFromHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end
