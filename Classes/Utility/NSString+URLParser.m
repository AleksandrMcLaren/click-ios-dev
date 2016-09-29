#import "NSString+URLParser.h"

@implementation NSString (NSString_URLParser)
/**
 * @warning Строка должна быть валидным URL!
 */
- (NSDictionary *)dictionaryWithUrlParams
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSURL *url = [NSURL URLWithString:self];
    
    /** Extract query string */
    NSArray *urlComponents = [url.absoluteString componentsSeparatedByString:@"?"];
    
    if (urlComponents.count > 1) {
        NSString *urlString  = [urlComponents objectAtIndex:1];
        NSArray  *components = [urlString componentsSeparatedByString:@"&"];
        
        for (NSString *pair in components) {
            if ([pair rangeOfString:@"="].location != NSNotFound) {
                NSArray *explodedPair = [pair componentsSeparatedByString:@"="];
                [result setObject:[explodedPair objectAtIndex:1]
                           forKey:[explodedPair objectAtIndex:0]];
            }
        }
    }
    return result;
}


- (NSString *)urlEncoded
{
    CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                    (CFStringRef) self,
                                                                    NULL,
                                                                    (CFStringRef) @"!*'\"();:@&=$,/?%#[]% +",
                                                                    kCFStringEncodingUTF8);
    return (__bridge NSString *) urlString;
}


@end
