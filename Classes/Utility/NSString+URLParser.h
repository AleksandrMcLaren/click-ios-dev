#import <Foundation/Foundation.h>

@interface NSString (NSString_URLParser)

- (NSDictionary *)dictionaryWithUrlParams;
- (NSString *)urlEncoded;

@end
