#import "NSDictionary+UrlEncodedString.h"

@implementation NSDictionary (UrlEncoding)

- (NSString*)urlEncodedString
{
  NSMutableArray *parts = [NSMutableArray array];

  for (id key in self) {
    id value = [self objectForKey: key];
    NSString *part = [NSString stringWithFormat: @"%@=%@",
                      [(NSString *)key urlEncoded],
                      [(NSString *)[value description] urlEncoded]];
    [parts addObject:part];
  }
  return [parts componentsJoinedByString: @"&"];
}

@end
